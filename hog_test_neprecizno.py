import cv2
import numpy as np
import hog
import matplotlib.pyplot as plt

'''image_test = cv2.imread("C:/Users/User/Documents/ml_projekat/HOG_FACE_DET/disgustedrachel.jpg")
gray = cv2.cvtColor(image_test, cv2.COLOR_BGR2GRAY)
#cv2.imwrite('gray.jpg', gray)
#cv2.imwrite('gray.ppm', gray)

x_filter, y_filter = hog.get_differential_filter()
#GET X GRADIENT OF THE PICTURE
dx = hog.filter_image(gray, x_filter)
#GET Y GRADIENT OF THE PICTURE
dy = hog.filter_image(gray, y_filter)

mag_matrix, angle_mat = hog.get_gradient(dx, dy)

histogramMat = hog.build_histogram(mag_matrix, angle_mat, 8)

hog_descriptors = hog.get_block_descriptor(histogramMat, 2)

hog_py = hog.extract_hog(gray)
hog.array_to_txt("hog_py.txt", hog_py);'''

#image_test = cv2.imread("C:/Users/User/Documents/ml_projekat/HOG_FACE_DET/gray_rachel.ppm")
#print(image_test.shape[0], image_test.shape[1])

#print((image_test[0][0]))

image_test = cv2.imread("C:/Users/User/Documents/ml_projekat/HOG_FACE_DET/disgustedrachel.jpg")
max_dim = max(image_test.shape[0], image_test.shape[1])
image_test = hog.resize(image_test, 200/max_dim)

gray = cv2.cvtColor(image_test, cv2.COLOR_BGR2GRAY)
cv2.imwrite('frame_in_gray.jpg', gray)

bounding_boxes, real_face = hog.face_recognition_range(gray, 1, 10)
print("bounding boxes from HOG:", bounding_boxes)

all_faces = hog.visualize_face_detection(image_test, np.array(bounding_boxes))
plt.imshow(all_faces, vmin=0, vmax=1)
plt.savefig('all_faces.png')

arithmetic_face = hog.visualize_face_detection(image_test, np.array(real_face))
plt.imshow(arithmetic_face, vmin=0, vmax=1)
plt.savefig('arithmetic_face.png')