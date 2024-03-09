import cv2
import numpy as np
import dlib
import os
import glob
import random
import hog
import matplotlib.pyplot as plt

#TODO: smanjiti velicinu matrice landmarks u landmark_detector_dlib sa 68 na 68-16

# Emotion list
emotions = ["anger", "contempt", "disgust", "fear", "happy", "sadness", "surprise"]

# 68 point face model
PREDICTOR_PATH = "C:/Users/User/Documents/ml_projekat/data/shape_predictor_68_face_landmarks"
# face detector
detector = dlib.get_frontal_face_detector()
# 68 points predictor
predictor = dlib.shape_predictor(PREDICTOR_PATH)

# Define landmark pairs
landmark_pairs = [(37, 41), (38, 40), (43, 47), (44, 46),
                  (21, 22), (19, 28), (20, 27), (23, 27),
                  (24, 28), (48, 29), (31, 29), (35, 29),
                  (54, 29), (60, 64), (61, 67), (51, 57),
                  (62, 66), (63, 65), (18, 29), (25, 29)
                  ] 

def load_images_from_folder(folder):
    images = []
    for filename in os.listdir(folder):
        img = cv2.imread(os.path.join(folder,filename))
        if img is not None:
            images.append(img)
    return images

def get_files(emotion): #koristi se za dobijanje skupa test i trening podataka
    images = glob.glob("C:/Users/User/Documents/ml_projekat/data/CK+48/%s//*" %emotion) #glob biblioteka->pronalazi 
    #sve datoteke u odredjenom direktorijuumu koji sadzi slike za odredjenu emociju
    #datoteke se smijestaju u listu image
    random.shuffle(images) #pronadjene slike se mijesaju da ide podjednako na test i trening
    training_set = images[:int(len(images)*0.8)]   #get 80% of image files to be trained
    #trening set 80% dataseta
    testing_set = images[-int(len(images)*0.2):]   #get 20% of image files to be tested
    return training_set, testing_set
    #20% dataseta

#Definition of a function to later use in other files
def landmark_detector_dlib(image) :
    
    #image = imutils.resize(image, width=500)
    #max_dim = max(image.shape[0], image.shape[1])
    #image = resize(image, 200/max_dim)

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    #cv2.imwrite('frame_in_gray.jpg', gray)
    
    # detect faces in the grayscale image
    faces = detector(gray, 1)
    
    #bounding_boxes = face_recognition_range(gray, 1, 75)
    #print("bounding boxes from HOG:", bounding_boxes)
    
    #visualize_face_detection(image, np.array(bounding_boxes))

    #faces = []

    #for box in bounding_boxes:
    #    face = dlib.rectangle(int(box[0]), int(box[1]), int(box[2]), int(box[3]))
    #    faces.append(face)
    
    #print("faces in dlib:", faces)

    # go through the face bounding boxes
    if len(faces) < 1:
        #In case no case selected, print "error" values
        #u slucaju da nema detektovanog lica vrati error
        #vrati landmarkse
        return np.zeros((68, 2))
    else:
        for face in faces:        
            # apply the shape predictor to the face ROI
            shape = predictor(gray, face)
        
        landmarks = np.zeros((68, 2))
        #print(result)
        for n in range(17, 68): # NIJE POTREBAN OKVIR FACE!
                x = shape.part(n).x
                y = shape.part(n).y
                #print("Landmark ID: ", n, "X coordinate: ", x, "Y coordinate: ", y)
                landmarks[n] = x, y
    
        return landmarks
    
def landmark_detector_hog(image) :

    max_dim = max(image.shape[0], image.shape[1])
    image = hog.resize(image, 200/max_dim)

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    
    bounding_boxes, real_face = hog.face_recognition_range(gray, 10)
    print("bounding boxes from HOG:", bounding_boxes)
    print("face found by HOG:", real_face)

    all_faces = hog.visualize_face_detection(image, np.array(bounding_boxes))
    plt.imshow(all_faces, vmin=0, vmax=1)
    plt.savefig('all_face.png')
    
    arithmetic_face = hog.visualize_face_detection(image, np.array(real_face))
    plt.imshow(arithmetic_face, vmin=0, vmax=1)
    plt.savefig('arithmetic_face.png')

    face = dlib.rectangle(int(real_face[0][0]), int(real_face[0][1]), int(real_face[0][2]), int(real_face[0][3]))
    

    # go through the face bounding boxes
    if face.is_empty():
        #In case no case selected, print "error" values
        #u slucaju da nema detektovanog lica vrati error
        #vrati landmarkse
        return np.zeros((68, 2))
    else:    
        # apply the shape predictor to the face ROI
        shape = predictor(gray, face)
        
        landmarks = np.zeros((68, 2))
        #print(result)
        for n in range(17, 68): # NIJE POTREBAN OKVIR FACE!
                x = shape.part(n).x
                y = shape.part(n).y
                #print("Landmark ID: ", n, "X coordinate: ", x, "Y coordinate: ", y)
                landmarks[n] = x, y
    
        return landmarks
    
def make_sets(): #generise skup podataka za treniranje i testiranje
    training_data = []
    training_label = []
    testing_data = []
    testing_label = [] #liste za ove skupove podataka
    for emotion in emotions: #iteracija kroz listu emocija
        training_set, testing_set = get_files(emotion) #dodavanje trening i test setova
        #za odredjenu emociju
        #add data to training and testing dataset, and generate labels 0-4
        #print("EMOTION: ", emotion)
        #print("Length of training set: ", len(training_set), "Length of testing_set", len(testing_set))
        for item in training_set:
            #print("Emotion: ", emotion, "Item_index:", training_set.index(item))
            #read image
            img = cv2.imread(item)
            #convert to grayscale
            #gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            #clahe_img = clahe.apply(gray_img) #poboljsanje kontrasta na sivoj slici
            landmarks_vec = landmark_detector_dlib(img) #stavaljaju se landmarks na sliku

            if np.all(landmarks_vec <= 0):
                pass
            else:
                #landmarks se stavljaju na trening set
                training_data.append(landmarks_vec)
                training_label.append(emotions.index(emotion)) #indeks emocije

        #analogno za test set
        for item in testing_set:
            img = cv2.imread(item)
            #gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            #clahe_img = clahe.apply(gray_img)
            landmarks_vec = landmark_detector_dlib(img)
            if np.all(landmarks_vec <= 0):
                pass
            else:
                testing_data.append(landmarks_vec)
                testing_label.append(emotions.index(emotion))
#vraca sve cetiri liste
    return training_data, training_label, testing_data, testing_label


# Calculate distances for each face
def distance_calculator(training_data, testing_data, landmark_pairs):
    feature_vectors_training = []
    for landmarks_for_face in training_data:
        distances = [np.sqrt((landmarks_for_face[p1][0] - landmarks_for_face[p2][0])**2 +
                            (landmarks_for_face[p1][1] - landmarks_for_face[p2][1])**2)
                    for p1, p2 in landmark_pairs]
        feature_vectors_training.append(distances)

    feature_vectors_testing = []
    for landmarks_for_face in testing_data:
        distances = [np.sqrt((landmarks_for_face[p1][0] - landmarks_for_face[p2][0])**2 +
                            (landmarks_for_face[p1][1] - landmarks_for_face[p2][1])**2)
                    for p1, p2 in landmark_pairs]
        feature_vectors_testing.append(distances)
    return feature_vectors_training, feature_vectors_testing

def distance_calculator_test(frame, landmark_pairs): 
    distances = [np.sqrt((frame[p1][0] - frame[p2][0])**2 +
                        (frame[p1][1] - frame[p2][1])**2)
                for p1, p2 in landmark_pairs]
    return distances