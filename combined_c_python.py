import cv2
import numpy as np
import dlib
import os
import glob
import random
import hog
import matplotlib.pyplot as plt
from ctypes import *
import ctypes as cts
if __name__ == '__main__':

    image = cv2.imread("/home/catic/Documents/project/final_version/copy/disgustedrachel.jpg")
    
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    cv2.imwrite('frame_in_gray.jpg', gray)
   
    f = open("gray.txt", "w")
    for i in range(0, gray.shape[0], 1):
        for j in range(0, gray.shape[1], 1):
            f.write('%d ' % gray[i][j])
        f.write('\n')
    f.close()

    gray = gray.astype('float') / 255.0
    # Normalize image to [0,1]
    gray = (gray - np.min(gray)) / np.max(gray)
    gray_2 = gray

    dx, dy = hog.get_differential_filter()
    im_dx = hog.filter_image(gray, dx)
    im_dy = hog.filter_image(gray, dy)
    
    f = open("im_dy_py.txt", "w")
    for i in range(0, im_dy.shape[0], 1):
        for j in range(0, im_dy.shape[1], 1):
            f.write('%f ' % im_dy[i][j])
        f.write('\n')
    f.close()

    grad_mag, grad_angle = hog.get_gradient(im_dx, im_dy)

    #print("GRAD MAG!!!!", grad_mag)
    
    f = open("grad_angle_py.txt", "w")
    for i in range(0, grad_angle.shape[0], 1):
        for j in range(0, grad_angle.shape[1], 1):
            f.write('%f ' % grad_angle[i][j]) 
        f.write('\n') 
    f.close() 

    f = open("grad_mag_py.txt", "w")  
    for i in range(0, grad_mag.shape[0], 1):
        for j in range(0, grad_mag.shape[1], 1):
            f.write('%f ' % grad_mag[i][j])
        f.write('\n')
    f.close()              
    
    ori_histo = hog.build_histogram(grad_mag, grad_angle, 8)
    
    #print("ORI HISTO 1", ori_histo[0][0])
    f = open("ori_histo.txt", "w")
    for i in range(0, ori_histo.shape[0], 1):
        for j in range(0, ori_histo.shape[1], 1):
            for k in range(0, ori_histo.shape[2], 1):
                f.write('%f ' % ori_histo[i][j][k])
            f.write('\n')
        f.write('\n')
    f.close() 
    
    ori_histo_normalized = hog.get_block_descriptor(ori_histo, 2)
    
    f = open("ori_histo_normalized.txt", "w")

    for i in range(0, ori_histo_normalized.shape[0], 1):
        for j in range(0, ori_histo_normalized.shape[1], 1):
            for k in range(0, ori_histo_normalized.shape[2], 1):
                f.write('%f ' % ori_histo_normalized[i][j][k])
            f.write('\n')
        f.write('\n')
    f.close()
    
    hog_ret = np.float64(np.zeros(24*24*24))

    so_hog = "/home/catic/Documents/project/final_version/copy/hog_c.so"
    hog_lib = CDLL(so_hog)
    extract_hog_c = hog_lib.extract_hog
    extract_hog_c.restype = None
    extract_hog_c.argtypes = [
        np.ctypeslib.ndpointer(dtype=np.float64, shape = (200, 200)),
        np.ctypeslib.ndpointer(dtype=np.float64, shape = (24*24*24))
    ]
    
    gray_2 = np.float64(gray_2)
    gray_output = np.float64(np.zeros((200,200)))
    extract_hog_c(gray_2, hog_ret)
    

