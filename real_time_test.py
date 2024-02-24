import cv2
import numpy as np
import pickle

from utils import landmark_detector_dlib
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
    
video_capture = cv2.VideoCapture(0) 
    
while True:
    testing_data = []
    result, video_frame = video_capture.read()  # read frames from the video
    if result is False:
        break  # terminate the loop if the frame is not read successfull
        
    #video_frame = cv2.imread("/home/catic/Documents/project/happy.jpg")
    video_frame_cpy = video_frame
    #cv2.imwrite('frame_being_analised.jpg', video_frame_cpy)
        
    video_frame_landmarks = landmark_detector_dlib(video_frame)

    if (np.all(video_frame_landmarks == 0)):
        cv2.imshow("AdaBoost Prediction ",video_frame_cpy)   
        print("Error")
    else:     
        video_frame_distance = distance_calculator_test(video_frame_landmarks, landmark_pairs)
        testing_data.append(video_frame_distance)
        video_frame_distance_array = np.array(testing_data) 
        video_frame_distance_array = video_frame_distance_array.reshape(1,-1)            
        result_prediction = model_trained.predict(video_frame_distance_array)
        #print("Emotion Prediction: ", emotions[result_prediction[0]])

        cv2.putText(video_frame_cpy ,emotions[result_prediction.item()], (30, 30), fontFace= cv2.FONT_HERSHEY_PLAIN, fontScale= 1.5, color =(0, 0, 0))
        cv2.imshow("AdaBoost Prediction ",video_frame_cpy)

    if cv2.waitKey(2) & 0xFF == ord("q"):
        break
 
video_capture.release()
cv2.destroyAllWindows()