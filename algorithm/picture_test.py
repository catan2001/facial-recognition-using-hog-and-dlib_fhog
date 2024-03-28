import cv2
import numpy as np
import pickle
 
from utils import landmark_detector_dlib
from utils import landmark_detector_hog
from utils import distance_calculator_test

emotions = ["anger", "contempt", "disgust", "fear", "happy", "sadness", "surprise"]

landmark_pairs = [(37, 41), (38, 40), (43, 47), (44, 46),
                  (21, 22), (19, 28), (20, 27), (23, 27),
                  (24, 28), (48, 29), (31, 29), (35, 29),
                  (54, 29), (60, 64), (61, 67), (51, 57),
                  (62, 66), (63, 65), (18, 29), (25, 29)
                  ]

    
pkl_file = open('C:/Users/User/Documents/ml_projekat/ada_dlib/model.pkl', 'rb')
model_trained = pickle.load(pkl_file)    
pkl_file.close()
    
testing_data = []
image_test = cv2.imread("C:/Users/User/Documents/ml_projekat/data/monica.jpg")
#for dlib fhog recognition:
#image_test_landmark = landmark_detector_dlib(image_test)
#for hog recognition:
image_test_landmark = landmark_detector_hog(image_test)
print(len(image_test_landmark))
image_test_distance = distance_calculator_test(image_test_landmark, landmark_pairs)
print(len(image_test_distance))
testing_data.append(image_test_distance)
image_test_distance_array = np.array(testing_data)
#image_test_distance_array = image_test_distance_array.reshape(1,-1)
predicted_label = model_trained.predict(image_test_distance_array)
predicted_label = predicted_label[0]
print("Real Label: Surprised", "Predicted Label: ", emotions[predicted_label])