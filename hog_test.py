import cv2
import numpy as np
import hog
import matplotlib.pyplot as plt

image_test = cv2.imread("C:/Users/User/Documents/ml_projekat/data/maturskaja.jpeg")

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