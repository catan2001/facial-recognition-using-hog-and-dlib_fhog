import cv2
import numpy as np
import hog
import matplotlib.pyplot as plt

image_test = cv2.imread("C:/Users/User/Documents/ml_projekat/HOG_FACE_DET/disgustedrachel.jpg")
gray = cv2.cvtColor(image_test, cv2.COLOR_BGR2GRAY)
#cv2.imwrite('gray.jpg', gray)
#cv2.imwrite('gray.ppm', gray)

x_filter, y_filter = hog.get_differential_filter()
dx = hog.filter_image(gray, x_filter)
#dy = hog.filter_image(gray, y_filter)
#cv2.imwrite('dx.jpg', dx)cle
print("DX: ", dx)

print("GRAY: ", gray)

print("image_test: ", image_test)

f = open("dx.txt", "w")
for i in range(0, dx.shape[0], 1):
    for j in range(0, dx.shape[1], 1):
        f.write('%d ' % dx[i][j]) 
    f.write('\n') 
f.close()

f = open("dx.txt", "r")
array = []
for line in f: # read rest of lines
    array.append([int(x) for x in line.split()])
f.close()

cv2.imwrite('python_dx.png', np.array(array))


#image_test = cv2.imread("C:/Users/User/Documents/ml_projekat/HOG_FACE_DET/gray_rachel.ppm")
#print(image_test.shape[0], image_test.shape[1])

#print((image_test[0][0]))

'''max_dim = max(image_test.shape[0], image_test.shape[1])
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
plt.savefig('arithmetic_face.png')'''