import numpy as np
from sklearn.ensemble import AdaBoostClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score
import os
import pickle

from utils import make_sets
from utils import distance_calculator

emotions = ["anger", "contempt", "disgust", "fear", "happy", "sadness", "surprise"]

landmark_pairs = [(37, 41), (38, 40), (43, 47), (44, 46),
                  (21, 22), (19, 28), (20, 27), (23, 27),
                  (24, 28), (48, 29), (31, 29), (35, 29),
                  (54, 29), (60, 64), (61, 67), (51, 57),
                  (62, 66), (63, 65), (18, 29), (25, 29)
                  ]

accuracy_array=[]
adaboost_classifier_array=[]

for i in range(0, 10):
    training_data, training_label, testing_data, testing_label = make_sets()
    feature_vectors_training, feature_vectors_testing = distance_calculator(training_data, testing_data, landmark_pairs)

    # Convert to numpy array
    feature_array_training = np.array(feature_vectors_training)
    feature_array_testing = np.array(feature_vectors_testing)
        
    # Train the model
        
    # Create a weak classifier (e.g., decision tree)
    base_classifier = DecisionTreeClassifier(max_depth=2)
    # Create AdaBoost classifier
    adaboost_classifier = AdaBoostClassifier(base_classifier, n_estimators=100, random_state=42)
    adaboost_classifier.fit(feature_array_training, training_label)
    # Make predictions
    label_prediction = adaboost_classifier.predict(feature_array_testing)
    accuracy = round(100*accuracy_score(testing_label, label_prediction), 2)

    adaboost_classifier_array.append(adaboost_classifier)
    accuracy_array.append(accuracy)

max_accuracy = np.max(accuracy_array)
best_classifier = adaboost_classifier_array[accuracy_array.index(max_accuracy)]
print(f" Max_accuracy: {max_accuracy}%")
 
try:
    os.remove('C:/Users/User/Documents/ml_projekat/ada_dlib/model.pkl')
except OSError:
    pass
output = open('C:/Users/User/Documents/ml_projekat/ada_dlib/model.pkl', 'wb')
pickle.dump(best_classifier, output)
output.close()