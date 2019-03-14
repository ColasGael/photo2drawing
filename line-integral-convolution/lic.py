import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
import scipy
import scipy.signal
import tqdm

def label_regions(im, num_regions):
    # Builds an 8-connected graph of pixels, with edge weights being the
    # l2 distance between pixel colors in whatever color space they are in.
    # Then, finds the minimum-cost spanning forest with num_regions components.

    H, W, C = im.shape
    J, I = np.meshgrid(np.arange(W), np.arange(H))

    edges = []
    indices = I * W + J

    h_cost = np.sum((im[:, :-1, :] - im[:, 1:, :]) ** 2, axis=2) ** 0.5
    h_edges = list(zip(h_cost.ravel(), indices[:, :-1].ravel(), indices[:, 1:].ravel()))
    edges += h_edges

    v_cost = np.sum((im[:-1, :, :] - im[1:, :, :]) ** 2, axis=2) ** 0.5
    v_edges = list(zip(v_cost.ravel(), indices[:-1, :].ravel(), indices[1:, :].ravel()))
    edges += v_edges

    dr_cost = np.sum((im[:-1, :-1, :] - im[1:, 1:, :]) ** 2, axis=2) ** 0.5
    dr_edges = list(zip(dr_cost.ravel(), indices[:-1, :-1].ravel(), indices[1:, 1:].ravel()))
    edges += dr_edges

    ur_cost = np.sum((im[1:, :-1, :] - im[:-1, 1:, :]) ** 2, axis=2) ** 0.5
    ur_edges = list(zip(ur_cost.ravel(), indices[1:, :-1].ravel(), indices[:-1, 1:].ravel()))
    edges += ur_edges

    edges.sort()

    p, rank, components = np.arange(H * W), np.zeros(H * W), H * W

    def parent(x):
        if p[x] == x:
            return x
        p[x] = parent(p[x])
        return p[x]

    for cost, x, y in edges:
        if components <= num_regions:
            break

        x = parent(x)
        y = parent(y)
        if x == y:
            continue
        if rank[x] > rank[y]:
            x, y = y, x
        if rank[x] == rank[y]:
            rank[y] += 1
        p[x] = y
        components -= 1

    component_labels = dict()
    labels = np.zeros((H, W), dtype=np.int32)
    label_counts = []
    for i in range(H):
        for j in range(W):
            pi = parent(i * W + j)
            if pi not in component_labels:
                component_labels[pi] = len(component_labels)
                label_counts.append(0)
            labels[i, j] = component_labels[pi]
            label_counts[labels[i, j]] += 1

    return labels, label_counts

def extract_region_vector_field(im_gray, labels, label_counts,
                                preblur_sigma=2,
                                preblur_size=7,
                                var_threshold=0.5,
                                normalize=True):
    # Blur, then compute image gradients
    im_blur = cv.GaussianBlur(im_gray, (preblur_size, preblur_size), preblur_sigma)
    gradX = cv.Sobel(im_blur, cv.CV_64F, 1, 0, ksize=5)
    gradY = cv.Sobel(im_blur, cv.CV_64F, 0, 1, ksize=5)

    # Rotate gradients by 90 degrees to align with stripe direction
    vec = np.dstack([gradX, -gradY]) / 255.0

    # Constrain gradients to face right
    vec = vec * (1 - 2 * (vec[:, :, 1] < 0))[:, :, np.newaxis]

    # Compute variance of each region
    H, W = im_gray.shape
    K = len(label_counts)
    mean_vec, var_vec = np.zeros((K, 2)), np.zeros(K)
    for i in range(H):
        for j in range(W):
            mean_vec[labels[i, j]] += vec[i, j, :]
    mean_vec /= np.array(label_counts)[:, np.newaxis]
    for i in range(H):
        for j in range(W):
            l = labels[i, j]
            var_vec[l] += np.sum((vec[i, j, :] - mean_vec[l]) ** 2)
    var_vec /= np.array(label_counts)

    # Set regions with high variance to their mean vector
    for i in range(H):
        for j in range(W):
            l = labels[i, j]
            if var_vec[l] > var_threshold:
                vec[i, j, :] = mean_vec[l]

    if normalize:
        vec /= (np.sum(vec ** 2, axis=2) + 1e-2)[:, :, np.newaxis]

    return vec

def generate_noise_image(im_gray, labels, label_counts,
                         lambda_1=0.7, min_1=0, max_1=255,
                         lambda_2=0.3, min_2=0, max_2=255):
    im_gray = im_gray / 255.0
    H, W = im_gray.shape
    im_noise = np.zeros(im_gray.shape)

    K = len(label_counts)
    R = np.zeros(K)
    for i in range(H):
        for j in range(W):
            R[labels[i, j]] += im_gray[i, j]
    R /= np.array(label_counts)

    T_1 = lambda_1 * (1.0 - im_gray) ** 2.0
    T_2 = lambda_2 * (1.0 - im_gray) ** 2.0
    P = np.random.uniform(0, 1, (H, W))
    C_1 = min_1 * (P <= T_1) + max_1 * (P > T_1)
    C_2 = min_2 * (P <= T_2) + max_2 * (P > T_2)

    I = np.zeros((H, W))
    for i in range(H):
        for j in range(W):
            I[i, j] = im_gray[i, j] <= R[labels[i, j]]

    im_noise = C_1 * I + C_2 * (1.0 - I)
    return im_noise

def bilerp(F, x, normalize=True):
    if len(F.shape) == 2:
        F = F[:, :, np.newaxis]
    H, W, D = F.shape
    u = int(np.floor(x[0] - 0.5))
    v = int(np.floor(x[1] - 0.5))
    fu = x[0] - 0.5 - u
    fv = x[1] - 0.5 - v

    u, up = np.clip([u, u + 1], 0, H - 1)
    v, vp = np.clip([v, v + 1], 0, W - 1)

    f1 = F[u, v, :] * (1 - fv) + F[u, vp, :] * fv
    f2 = F[up, v, :] * (1 - fv) + F[up, vp, :] * fv
    result = f1 * (1 - fu) + f2 * fu

    if normalize:
        result /= np.sum(result ** 2) + 1e-2
    if len(result) == 1:
        result = result[0]
    return result

def line_integral_convolution(im_noise, vec, R=40, KW=7, use_tqdm=False):
    L = 2 * R
    H, W = im_noise.shape
    num_hits = np.zeros((H, W), dtype=np.int32)
    result = np.zeros((H, W))

    #kernel = np.ones(KW) / KW
    # Triangular kernel
    kernel = np.arange(KW) + 1
    kernel = np.minimum(kernel, kernel[::-1])
    kernel = kernel / np.sum(kernel)
    odeopts = {'rtol': 1e-2, 'atol': 1e-2}
    df = lambda y, t: bilerp(vec, y)

    skipped = 0
    pixels = [(i, j) for i in range(H) for j in range(W)]
    work = list(enumerate(np.random.permutation(pixels)))
    if use_tqdm:
        work = tqdm.tqdm(work)

    import time
    int_time = 0.0
    int2_time = 0.0
    conv_time = 0.0
    acc_time = 0.0

    df2 = lambda t, y: bilerp(vec, y)

    for pixel_num, pixel in work:
        i, j = pixel
        if num_hits[i, j] > 0:
            skipped += 1
            continue

        if not use_tqdm and pixel_num % H == 0:
            print("Integrating {} {} ({}/{}, skipped {})".format(i, j, pixel_num, H * W, skipped))

        line_s = np.zeros((L + 1, 2))
        line_s[R, :] = [i + 0.5, j + 0.5]

        st=time.time()
        forward = scipy.integrate.odeint(df, line_s[R, :], np.arange(R + 1), **odeopts)
        backward = scipy.integrate.odeint(df, line_s[R, :], -np.arange(R + 1), **odeopts)
        line_s[R:, :] = forward
        line_s[:R, :] = backward[1:][::-1]
        int_time += time.time() - st

        st=time.time()
        #f2 = scipy.integrate.solve_ivp(df2, (0, R), line_s[R, :], t_eval=np.arange(R + 1)).y.T
        #b2 = scipy.integrate.solve_ivp(df2, (0, -R), line_s[R, :], t_eval=-np.arange(R + 1)).y.T
        #line_s[R:, :] = f2
        #line_s[:R, :] = b2[1:][::-1]
        int2_time += time.time() - st

        st=time.time()
        samples = np.array([bilerp(im_noise, line_s[i, :], False) for i in range(L + 1)])
        samples_conv = scipy.signal.convolve(samples, kernel, mode='same')
        conv_time += time.time() - st

        st=time.time()
        line_si = np.floor(line_s[KW-1:-(KW-1), 0]).astype(np.int32)
        line_sj = np.floor(line_s[KW-1:-(KW-1), 1]).astype(np.int32)
        usable_samples = samples_conv[KW-1:(-KW-1)]
        for si, sj, sample in zip(line_si, line_sj, usable_samples):
            if 0 <= si and si < H and 0 <= sj and sj < W:
                num_hits[si, sj] += 1
                result[si, sj] += sample
        acc_time += time.time() - st

    print("int_time {}".format(int_time))
    print("int2_time {}".format(int2_time))
    print("conv_time {}".format(conv_time))
    print("acc_time {}".format(acc_time))
    result /= num_hits
    return result
