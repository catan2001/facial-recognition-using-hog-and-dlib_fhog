#import hog_with_c_functions
import hog
import cv2

I_target = cv2.imread("/home/koshek/Desktop/ml_projekat/data/disgustedrachel.jpg", 1)
#I_template = cv2.imread("/home/koshek/Desktop/ml_projekat/data/template.png", 0)

#hog_py = hog.extract_hog(I_target)
def array_to_txt(name_txt, matrix):
    f = open(name_txt, "w")
    for i in range(0, len(matrix), 1):
        #f.write('%f ' % matrix[i]) 
        f.write("%s" % matrix[i])
    f.close()

def matrix_to_txt(name_txt, matrix):
    f = open(name_txt, "w")
    for i in range(0, matrix.shape[0], 1):
        for j in range(0, matrix.shape[1], 1):
            f.write('%s ' % matrix[i][j]) 
        f.write('\n') 
    f.close()

#matrix_to_txt('targethog_py.txt', I_target)

found_faces, real_face = hog.face_recognition_range(I_target, 10)

print(found_faces)

all_faces = hog.visualize_face_detection(I_target, found_faces, 150)
cv2.imwrite('all_faces.jpg', all_faces)

face = hog.visualize_face_detection(I_target, real_face, 150)
cv2.imwrite('face.jpg', face)


cv2.destroyAllWindows()