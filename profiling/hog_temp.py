import cv2
import numpy as np
import matplotlib.pyplot as plt
from ctypes import *
import ctypes as cts
from time import time
import skimage.feature as skim

def get_differential_filter(): #sobel kernels 
    # 3 x 3 Sobel filter
    filter_x = np.array([[1,0,-1],[2,0,-2],[1,0,-1]]) # Dx = filter_x conv D
    filter_y = np.array([[1,2,1],[0,0,0],[-1,-2,-1]]) # Dy = filter_y conv D
    return filter_x, filter_y


def filter_image(im, filter): #this function will go through X gradient filter and the Y gradient filter
    im_filtered = np.zeros_like(im) #create empty array where we'll store the filtered image
    filter_flattened = filter.flatten() #flatten the filter into one dimension
    height = len(im)
    width = len(im[0])
    im_padded = np.pad(im,1) 

    for i in range(height):
        for j in range(width):
            im_window = im_padded[i:i+3,j:j+3].flatten()
            im_filtered[i][j] = np.dot(im_window, filter_flattened) #im_window(3*3 matrix)*filter_flattened

    return im_filtered


def get_gradient(im_dx, im_dy):
    height = len(im_dx) #height of im_dx
    width = len(im_dy[0]) #width of im_dy
    grad_mag = np.zeros_like(im_dx,dtype=float) #dunno why they didn't just use np.zeros but it's an empty matrix the same size and shape as im_dx
    grad_angle = np.zeros_like(im_dx,dtype=float) #same goes for this young fella
    for i in range(height):
        grad_mag[i] = [np.linalg.norm([dX,dY]) for (dX,dY) in zip(im_dx[i],im_dy[i])] #(dX^2+dY^2)^1/2
        for j in range(width):
            dX = im_dx[i][j]
            dY = im_dy[i][j]
            if abs(dX) > 0.00001:
                grad_angle[i][j] = np.arctan(float(dY/dX)) + (np.pi/2)
            else:
                if dY < 0 and dX < 0:
                    grad_angle[i][j] = 0
                else:
                    grad_angle[i][j] = np.pi
    return grad_mag, grad_angle

#THE THREE ABOVE FUNCTIONS DO THIS IN ORDER:
#1. DEFINE THE SOBEL KERNELS, OUR FILTERS THAT WILL EXTRACT THE EDGES OF A GRAY IMAGE
#2. APPLYING THE FILTER TO THE IMAGE IN ONE AXIS, THAT IS CONV A KERNEL AND IMAGE
#3. GETTING THE AMPLITUDE AND PHASE MATRIX OF THE FILTERED IMAGE


def build_histogram(grad_mag, grad_angle, cell_size):
    height = len(grad_mag)
    width = len(grad_mag[0])
    nBins = 6
    x_corner = 0
    y_corner = 0
    ori_histo = np.zeros((int(height / cell_size), int(width / cell_size), nBins), dtype=float) #cube x y z
    while (x_corner + cell_size) <= height:
        while (y_corner + cell_size) <= width:
            hist = np.zeros((6), dtype=float)
            magROI = grad_mag[x_corner:x_corner+cell_size, y_corner:y_corner+cell_size].flatten()
            angleROI = grad_angle[x_corner:x_corner+cell_size, y_corner:y_corner+cell_size].flatten()
            for i in range(cell_size*cell_size):
                angleInDeg = angleROI[i] * (180 / np.pi)
                if angleInDeg >=0 and angleInDeg < 30:
                    hist[0] += magROI[i]
                elif angleInDeg >=30 and angleInDeg < 60:
                    hist[1] += magROI[i]
                elif angleInDeg >=60 and angleInDeg < 90:
                    hist[2] += magROI[i]
                elif angleInDeg >=90 and angleInDeg < 120:
                    hist[3] += magROI[i]
                elif angleInDeg >=120 and angleInDeg < 150:
                    hist[4] += magROI[i]
                else:
                    hist[5] += magROI[i]
            ori_histo[int(x_corner/cell_size),int(y_corner/cell_size),:] = hist #we are writing along the z axis (0,0,:) -> ... -> (0, n, :) -> (1, 0, :) -> ... -> (1, n, :)
            y_corner += cell_size 
        x_corner += cell_size
        y_corner = 0
    return ori_histo

#BUILD HISTOGRAM BASED ON THE MAG PHASE AND CELL SIZE^

def get_block_descriptor(ori_histo, block_size):
    x_window = 0
    y_window = 0
    height = len(ori_histo)
    width = len(ori_histo[0])
    ori_histo_normalized = np.zeros(((height-(block_size-1)), (width-(block_size-1)), (6*(block_size**2))), dtype=float)
    while x_window + block_size <= height:
        while y_window + block_size <= width:
            concatednatedHist = ori_histo[x_window:x_window + block_size, y_window:y_window + block_size,:].flatten()
            histNorm = np.sqrt(np.sum(np.square(concatednatedHist)) + 0.001)
            ori_histo_normalized[x_window,y_window,:] = [(h_i / histNorm) for h_i in concatednatedHist]
            y_window += block_size
        x_window += block_size
        y_window = 0
    return ori_histo_normalized

def extract_hog(im):

    time_start = time()
    # convert grey-scale image to double format
    im = im.astype('float') / 255.0
    # Normalize image to [0,1]
    im = (im - np.min(im)) / np.max(im)
    time_ngs = time()
    '''
    box_h, box_w = im.shape
    so_hog = "/home/catic/Documents/project/final_version/copy/hog_c.so"
    hog_lib = CDLL(so_hog)
    filterc = hog_lib.filter_image
    filterc.restype = None
    filterc.argtypes = [
        np.ctypeslib.ndpointer(dtype=np.float64, shape = (box_h, box_w)),
        np.ctypeslib.ndpointer(dtype=np.float64, shape = (box_h, box_w)),
        np.ctypeslib.ndpointer(dtype=np.int32, shape = 9)
    ]
    init_function = hog_lib.init
    init_function.restype = None
    init_function.argtypes = [
        cts.c_int32,
        cts.c_int32
    ]

    xfilter = np.int32([1,0,-1, 2,0,-2, 1,0,-1])
    yfilter = np.int32([1,2,1, 0,0,0, -1,-2,-1])

    init_function(box_h, box_w)
    '''
    #filterc()
    #GET KERNELS
    x_filter, y_filter = get_differential_filter()
    #GET X GRADIENT OF THE PICTURE
    dx = filter_image(im, x_filter)
    dy = filter_image(im, y_filter)
    '''
    dx = np.float64(np.zeros((box_h, box_w)))#filter_image(im, x_filter)
    #GET Y GRADIENT OF THE PICTURE
    dy = np.float64(np.zeros((box_h, box_w))) 
    im2 = np.float64(im)
    filterc(im2, dx, xfilter)
    filterc(im2, dy, yfilter)
    '''
    time_fi = time()

    mag_matrix, angle_mat = get_gradient(dx, dy)
    time_gg = time()
    
    histogramMat = build_histogram(mag_matrix, angle_mat, 8)
    time_bh = time()

    hog_descriptors = get_block_descriptor(histogramMat, 2)
    time_gbd = time()

    #print("hog_descriptors", hog_descriptors)
    hog = hog_descriptors.flatten()
    time_f = time()

    t_ngs = time_ngs - time_start
    t_fi = time_fi - time_ngs
    t_gg = time_gg - time_fi
    t_bh = time_bh - time_gg
    t_gbd = time_gbd - time_bh
    t_f = time_f - time_gbd

    #print("\n hog", hog)
    #resized = cv2.resize(im, (400, 400), interpolation = cv2.INTER_AREA)
    # VISUALIZATION CODE FOR HOG. UNCOMMENT IF NEEDED
    #visualize_hog(im, hog, 8, 2)
    return hog, t_ngs, t_fi, t_gg, t_bh, t_gbd, t_f 

# visualize histogram of each block
def visualize_hog(im, hog, cell_size, block_size):
    num_bins = 6
    max_len = 7  # control sum of segment lengths for visualized histogram bin of each block
    im_h, im_w = im.shape

    img = np.zeros_like(im)

    num_cell_h, num_cell_w = int(im_h / cell_size), int(im_w / cell_size)
    num_blocks_h, num_blocks_w = num_cell_h - block_size + 1, num_cell_w - block_size + 1
    histo_normalized = hog.reshape((num_blocks_h, num_blocks_w, block_size**2, num_bins))
    histo_normalized_vis = np.sum(histo_normalized**2, axis=2) * max_len  # num_blocks_h x num_blocks_w x num_bins
    angles = np.arange(0, np.pi, np.pi/num_bins)


    mesh_x, mesh_y = np.meshgrid(np.r_[cell_size: cell_size*num_cell_w: cell_size], np.r_[cell_size: cell_size*num_cell_h: cell_size])
    mesh_u = histo_normalized_vis * np.sin(angles).reshape((1, 1, num_bins))  # expand to same dims as histo_normalized
    mesh_v = histo_normalized_vis * -np.cos(angles).reshape((1, 1, num_bins))  # expand to same dims as histo_normalized
    plt.imshow(img, cmap='gray', vmin=0, vmax=1)
    for i in range(num_bins):
        plt.quiver(mesh_x - 0.5 * mesh_u[:, :, i], mesh_y - 0.5 * mesh_v[:, :, i], mesh_u[:, :, i], mesh_v[:, :, i],
                   color='white', headaxislength=0, headlength=0, scale_units='xy', scale=1, width=0.002, angles='xy')
    plt.axis('off')
    plt.savefig('hog.jpg', bbox_inches='tight', pad_inches=0)

def box_iou(box1,box2, boxSize):
    # boxes have same area - boxSize ** 2 in our case
    sumOfAreas = 2*(boxSize**2)
    #        X min    Y min    X max              Y max
    box_1 = [box1[0], box1[1], box1[0] + boxSize, box1[1] + boxSize]
    box_2 = [box2[0], box2[1], box2[0] + boxSize, box2[1] + boxSize]
    intersectionArea = (min(box_1[2],box_2[2]) - max(box_1[0], box_2[0])) * (min(box_1[3],box_2[3]) - max(box_1[1], box_2[1]))
    return float(intersectionArea / (sumOfAreas - intersectionArea))

#GIVES US THE RELATIONSHIP BETWEEN TWO BOXES BASED ON HOW MUCH THEY INTERSECT
#A FULL MATCH RETURNS 1 AND NO INTERSECTION GIVES 0^
#WE WILL THRESHOLD LATER, IF THE BOXES COVER EACH OTHER BY A THIRD OR MORE THEN THROW OUT ONE OF THE BOXES BECAUSE THEY ARE DETECTING THE SAME THING

def face_recognition(I_target, I_template):
    template_HOG, t_ngs2, t_fi2, t_gg2, t_bh2, t_gbd2, t_f2 = extract_hog(I_template)
    
    n_eh = 0
    t_ngs = 0
    t_fi = 0
    t_gg = 0
    t_bh = 0
    t_gbd = 0
    t_f = 0
    
    n_eh = n_eh + 1
    t_ngs = t_ngs + t_ngs2
    t_fi = t_fi + t_fi2
    t_gg = t_gg + t_gg2
    t_bh = t_bh + t_bh2
    t_gbd = t_gbd + t_gbd2
    t_f = t_f + t_f2
    
    template_HOG = template_HOG - np.mean(template_HOG) # Normalize
    template_HOG_norm = np.linalg.norm(template_HOG)
    img_h, img_w = I_target.shape
    box_h, box_w = I_template.shape
    x = 0
    y = 0
    ## FIND ALL BOUNDING BOXES ##
    all_bounding_boxes = []
    while x + box_h <= img_h:
        #print(".")
        while y + box_w <= img_w:
            img_window = I_target[x:x+box_h, y:y+box_w]
            img_HOG, t_ngs2, t_fi2, t_gg2, t_bh2, t_gbd2, t_f2 = extract_hog(img_window)
            n_eh = n_eh + 1
            t_ngs = t_ngs + t_ngs2
            t_fi = t_fi + t_fi2
            t_gg = t_gg + t_gg2
            t_bh = t_bh + t_bh2
            t_gbd = t_gbd + t_gbd2
            t_f = t_f + t_f2

            img_HOG = img_HOG - np.mean(img_HOG) # Normalize
            img_HOG_norm = np.linalg.norm(img_HOG)
            score = float(np.dot(template_HOG, img_HOG) / (template_HOG_norm*img_HOG_norm))
            all_bounding_boxes.append([y,x,score])
            y += 3 # A stride of 3 is enough to produce a good result for the target. Change as needed
        x += 3
        y = 0
    #print("Search complete. Computing scores.")
    # Sort by score
    bounding_boxes = []
    all_bounding_boxes = sorted(list(all_bounding_boxes),key=lambda box: box[2], reverse=True) #true => descending and key lambda means we are sorting by score

    ## THRESHOLDING ##
    thresholded_boxes = []
    for box in all_bounding_boxes:
        if box[2] >= 0.5: # Thresholding
            thresholded_boxes.append(box)
    ## NON MAXIMUM SUPPRESSION ##
    while thresholded_boxes != []:
        currBox = thresholded_boxes[0]
        bounding_boxes.append(currBox)
        toRemove = []
        for box in thresholded_boxes:
            if box_iou(currBox, box, box_w) >= 0.5:
                toRemove.append(box)
        for remBox in toRemove:
            thresholded_boxes.remove(remBox)

    
    
    #print("Number of boxes: ", len(bounding_boxes))
    return np.array(bounding_boxes), t_ngs, t_fi, t_gg, t_bh, t_gbd, t_f, n_eh 




def visualize_face_detection(I_target,bounding_boxes):

    #max_dim = max(I_target.shape[0], I_target.shape[1])
    #I_target = resize(I_target, 200/max_dim)
    hh,ww,cc=I_target.shape

    fimg=I_target.copy()
    for ii in range(bounding_boxes.shape[0]):

        #print("\n BOX dimenzije: ", bounding_boxes[ii])

        x1 = bounding_boxes[ii,0]
        x2 = bounding_boxes[ii, 2]
        y1 = bounding_boxes[ii, 1]
        y2 = bounding_boxes[ii, 3]

        if x1<0:
            x1=0
        if x1>ww-1:
            x1=ww-1
        if x2<0:
            x2=0
        if x2>ww-1:
            x2=ww-1
        if y1<0:
            y1=0
        if y1>hh-1:
            y1=hh-1
        if y2<0:
            y2=0
        if y2>hh-1:
            y2=hh-1

        fimg = cv2.rectangle(fimg, (int(x1),int(y1)), (int(x2),int(y2)), (255, 0, 0), 1)
        cv2.putText(fimg, "%.2f"%bounding_boxes[ii,0], (int(x1)+1, int(y1)-5), cv2.FONT_HERSHEY_SIMPLEX , 0.2, (0, 0, 0), 1, cv2.LINE_AA)
        cv2.putText(fimg, "%.2f"%bounding_boxes[ii,1], (int(x1)+20, int(y1)-5), cv2.FONT_HERSHEY_SIMPLEX , 0.2, (0, 0, 0), 1, cv2.LINE_AA)

    fimg = cv2.cvtColor(fimg, cv2.COLOR_BGR2RGB)


    '''plt.figure(3)
    plt.imshow(fimg, vmin=0, vmax=1)
    plt.savefig('output_HOG_face_detection.png')'''

    return fimg


def face_recognition_range(I_target, step):
    time_start = time()
    found_faces = []

    real_face = []
    x1=[]
    y1=[]
    x2=[]
    y2=[]

    I_template = cv2.imread('new.jpeg', 0)
    I_template = resize(I_template, 1) #increase template size to 150x150
    I_resized = I_template

    lower_boundary = I_template.shape[0] #TEMPLATE is a square so no need for min
    #print("\n lower_boundary = ", lower_boundary)

    #max_dim = max(I_target.shape[0], I_target.shape[1])
    #I_target = resize(I_target, 200/max_dim) #resize so the max dimension is 200
    upper_boundary = min(I_target.shape[0], I_target.shape[1])
    #upper_boundary = 200

    #print("\n upper_boundary = ", upper_boundary)
    t_ngs = 0 #time
    t_fi = 0
    t_gg = 0
    t_bh = 0
    t_gbd = 0
    t_f = 0
    n_eh = 0 #number
    n_fr = 0
    t_ngs2 = 0 #time
    t_fi2 = 0
    t_gg2 = 0
    t_bh2 = 0
    t_gbd2 = 0
    t_f2 = 0
    n_eh2 = 0 #number
    #n_fr = 0
 
    for ii in range(upper_boundary, lower_boundary-1, -step):

        I_resized = resize(I_template, (ii/lower_boundary))
        #print("\n template size:", I_resized.shape[0])
        
        found_boxes, t_ngs2, t_fi2, t_gg2, t_bh2, t_gbd2, t_f2, n_eh2 = face_recognition(I_target, I_resized)
        n_fr = n_fr + 1
        t_ngs = t_ngs + t_ngs2
        t_fi = t_fi2 + t_fi
        t_gg = t_gg2 + t_gg
        t_bh = t_bh2 + t_bh
        t_gbd = t_gbd2 + t_gbd
        t_f = t_f2 + t_f
        n_eh = n_eh2 + n_eh
        if(len(found_boxes)):
            for box in found_boxes:
                found_faces.append([box[0], box[1], box[0]+I_resized.shape[0], box[1]+I_resized.shape[0], box[2]])
                x1.append(box[0]) #x1
                y1.append(box[1]) #y1
                x2.append(box[0]+I_resized.shape[0]) #x2
                y2.append(box[1]+I_resized.shape[0]) #y2

                #print("a face: \n", box)


    found_faces = sorted(list(found_faces),key=lambda box: box[4], reverse=True)
    
    num_faces = len(found_faces)

    if num_faces>4:
        real_face.append([sum(x1)/num_faces, sum(y1)/num_faces, sum(x2)/num_faces, sum(y2)/num_faces])
    else:
        real_face.append([found_faces[0][0], found_faces[0][1], found_faces[0][2], found_faces[0][3]])

    time_end = time()
    time_rr = time_end - time_start
    return found_faces, real_face, time_rr, n_fr, n_eh, t_ngs, t_fi, t_gg, t_bh, t_gbd, t_f


def weighed_mean(coordinates):

    coordinates = sorted(list(coordinates), reverse=True)
    true_mean = sum(coordinates)/len(coordinates)

    for i in range(0, len(coordinates)-1):
        t=(1-abs(true_mean-coordinates[i])/abs(true_mean-coordinates[0]))
        coordinates[i] = t*coordinates[i]

    new_mean = sum(coordinates)/len(coordinates)

    return new_mean



def resize(img, scale_percent):
    width = int(img.shape[1] * scale_percent)
    height = int(img.shape[0] * scale_percent)
    dim = (width, height)

    return cv2.resize(img, dim, interpolation = cv2.INTER_AREA)
