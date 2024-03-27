import cv2
import numpy as np
import pickle
import cProfile
import pstats
from time import time
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

if __name__ == '__main__':  
    pkl_file = open('/home/catic/Documents/project/AdaBoost_DLib/predicted_model/model_new.pkl', 'rb')
    model_trained = pickle.load(pkl_file)    
    pkl_file.close()    
    #with cProfile.Profile() as profile:
    testing_data = []

    time_rr = 0
    t_ngs = 0 #time
    t_fi = 0
    t_gg = 0
    t_bh = 0
    t_gbd = 0
    t_f = 0
    n_eh = 0 #number
    n_fr = 0

    image_test = cv2.imread("/home/catic/Documents/project/final_version/copy/megan.jpeg")
        #for dlib fhog recognition:
        #image_test_landmark = landmark_detector_dlib(image_test)
        #for hog recognition:
    time_start = time()
    #image_test_landmark = landmark_detector_hog(image_test)
    image_test_landmark, time_landmarks, time_rr, n_fr, n_eh, t_ngs, t_fi, t_gg, t_bh, t_gbd, t_f = landmark_detector_hog(image_test)
    time_hog = time()
    #print(len(image_test_landmark))
    image_test_distance = distance_calculator_test(image_test_landmark, landmark_pairs)
    time_distance = time()
    #print(len(image_test_distance))
        
    testing_data.append(image_test_distance)
    image_test_distance_array = np.array(testing_data)
    #image_test_distance_array = image_test_distance_array.reshape(1,-1)
    time_append = time()    
    predicted_label = model_trained.predict(image_test_distance_array)
    time_end = time()
    time_whole_sec = time_end - time_start
    time_hog_sec = time_hog-time_start
    time_hog_proc = (time_hog_sec/time_whole_sec) * 100
    time_dlib_sec = time_landmarks
    time_dlib_proc = (time_landmarks/time_whole_sec) * 100
    time_hog_asec = time_hog_sec - time_landmarks
    time_hog_aproc = (time_hog_asec/time_whole_sec) * 100
    time_distance_sec = time_distance-time_hog
    time_distance_proc = (time_distance_sec/time_whole_sec) * 100
    time_predict_sec = time_end-time_append
    time_predict_proc = (time_predict_sec/time_whole_sec) * 100

    print("Time to finish whole algorithm with ONLY PYTHON HOG: ", time_whole_sec)
    print("Time to finish HOG algorithm with DLIB landmarks: ", time_hog_sec)
    print("Time to finish HOG in percentage with DLIB landmakrs: ", time_hog_proc)
    print("Time to finish HOG algorithm alone: ", time_hog_asec)
    print("Time to finish HOG algorithm alone in percentage: ", time_hog_aproc)
    print("Time to finish DLIB landmarks: ", time_dlib_sec)
    print("Time to finish DLIB landmarks in percentage: ", time_dlib_proc)
    print("Time to calculate distance: ", time_distance_sec)
    print("Time to calculate distance in percentage: ", time_distance_proc)
    print("Time to predict expression: ", time_predict_sec)
    print("Time to predict expression in percentage: ", time_predict_proc)
    print("************************************************************** \n")
    print("Time to do face_recognition_range: ", time_rr)
    print("Time to do DLIB landmarks detection: ", time_landmarks)
    print("Number of times face_recognition was called: ", n_fr)
    print("Number of times extract_hog was called: ", n_eh)
    print("Cumulative time to do normalize and scale functions: ", t_ngs)
    print("Mean time to do normalize and scale functions: ", t_ngs/n_eh)
    print("Cumulative time to do filter image: ", t_fi)
    print("Mean time to do filter image: ", t_fi/n_eh)
    print("Cumulative time to do get_gradient: ", t_gg)
    print("Mean time to do get_gradient: ", t_gg/n_eh)
    print("Cumulative time to do build_histogram: ", t_bh)
    print("Mean time to do build_histogram: ", t_bh/n_eh)
    print("Cumulative time to do get_block_descriptor: ", t_gbd)
    print("Mean time to do get_block_descriptor: ", t_gbd/n_eh)
    print("Cumulative time to do flattening of HOG: ", t_f)
    print("Mean time to do flattening of HOG: ", t_f/n_eh)
    print("************************************************************** \n")
    tc_ngs = t_ngs/n_eh
    tc_fi = t_fi / n_eh
    tc_gg = t_gg/n_eh
    tc_bh = t_bh/n_eh
    tc_gbd = t_gbd/n_eh
    tc_f = t_f/n_eh
    f = open("timeprof_hog_with_only_python.txt", "w")
    #f.write('%d ' % gray[i][j])
    f.write("Time to finish whole algorithm with ONLY PYTHON HOG: %f \n" % time_whole_sec)
    f.write("Time to finish HOG algorithm with DLIB landmarks: %f \n" % time_hog_sec)
    f.write("Time to finish HOG algorithm with DLIB landmarks in percentage: %f \n" % time_hog_proc)
    f.write("Time to calculate HOG algorithm alone: %f \n" % time_hog_asec)
    f.write("Time to calculate HOG algorithm alone in percentage: %f \n" % time_hog_aproc)
    f.write("Time to calculate DLIB landmarks: %f \n" % time_dlib_sec)
    f.write("Time to calculate DLIB landmarks in percentage: %f \n" % time_dlib_proc)
    f.write("Time to calculate distance: %f \n" % time_distance_sec)
    f.write("Time to calculate distance in percentage: %f \n" % time_distance_proc)
    f.write("Time to predict expression: %f \n" % time_predict_sec)
    f.write("Time to predict expression in percentage: %f \n" % time_predict_proc)
    f.write('\n')    
    f.write("************************************************************** \n")
    f.write("Time to do face_recognition_range: %f \n" % time_rr)
    f.write("Number of times face_recognition was called: %f \n" % n_fr)
    f.write("Number of times extract_hog was called: %f \n" % n_eh)
    f.write("Cumulative time to do normalize and scale functions: %f \n" % t_ngs)
    f.write("Mean time to do normalize and scale functions: %f \n" % tc_ngs)
    f.write("Cumulative time to do filter image: %f \n" % t_fi)
    f.write("Mean time to do filter image: %f \n" % tc_fi)
    f.write("Cumulative time to do get_gradient: %f \n" % t_gg)
    f.write("Mean time to do get_gradient: %f \n" % tc_gg)
    f.write("Cumulative time to do build_histogram: %f \n" % t_bh)
    f.write("Mean time to do build_histogram: %f \n" % tc_bh)
    f.write("Cumulative time to do get_block_descriptor: %f \n" % t_gbd)
    f.write("Mean time to do get_block_descriptor: %f \n" % tc_gbd)
    f.write("Cumulative time to do flattening of HOG: %f \n" % t_f)
    f.write("Mean time to do flattening of HOG: %f \n" % tc_f)
    f.write("************************************************************** \n")

    f.close()
    predicted_label = predicted_label[0]
    #print("Real Label: Surprised", "Predicted Label: ", emotions[predicted_label])
    #exit()
    #results = pstats.Stats(profile)
    #results.sort_stats(pstats.SortKey.TIME)
    #results.print_stats()
    #results.dump_stats("results.prof")
