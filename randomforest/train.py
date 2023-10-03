from random import random
from sklearn import datasets
from sklearn.model_selection import train_test_split
from randomforest.RandomForest import RandomForest
import numpy as np
from sklearn.ensemble import RandomForestClassifier  # or RandomForestRegressor for regression tasks
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score  # or other relevant metrics
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from kfda import Kfda
from sklearn.datasets import make_classification
from sklearn.metrics import roc_curve, auc
import matplotlib.pyplot as plt
import seaborn as sns
from randomforest.models import LastTrainingResultsKFDA, LastTrainingResultsRandomForest
from sklearn.metrics import confusion_matrix, classification_report
import pandas as pd
import base64
from io import BytesIO
import io
import urllib, base64
from sklearn.preprocessing import label_binarize
from sklearn.model_selection import learning_curve
import threading
from randomforest.models import *
# data = datasets.load_breast_cancer()
# X = data.data
# y = data.target



def accuracy(y_true, y_pred):
        accuracy = np.sum(y_true == y_pred) / len(y_true)
        return accuracy

def train(X,features, y, featuretypes):
    
        X_train, X_test, y_train, y_test = train_test_split(
                X, y, test_size=0.2, random_state=1234
        )

        # Convert string labels to binary labels
        n_classes = len(set(y_train))  # Number of unique classes
        y_train_bin = label_binarize(y_train, classes=range(n_classes))
        y_test_bin = label_binarize(y_test, classes=range(n_classes))


        # Create a Random Forest model
        model = RandomForestClassifier(n_estimators=400, random_state=42)  # You can adjust parameters
       
        # Train the model
        model.fit(X_train, y_train)


        ###########################Feature Importance#############################
        # Get feature importances 
        feature_importances = model.feature_importances_

        # Sort feature importances in descending order
        sorted_indices = np.argsort(feature_importances)[::-1]
        sorted_importances = feature_importances[sorted_indices]
        featurevalues = []
        for index in sorted_indices:
                print(features)
                print(sorted_indices)
                try:
                        featurevalues.append(features[int(index)])
                except:
                        
                        featurevalues.append(int)
        # Plot feature importances
        plt.figure(figsize=(10, 6))
        plt.switch_backend('agg')
        plt.bar(range(X_train.shape[1]), sorted_importances)
        plt.xticks(range(X_train.shape[1]), featurevalues)
        plt.xlabel('Feature Index')
        plt.ylabel('Feature Importance')
        plt.title('Feature Importance Plot')

        # Save the plot as an image file
        plot_filename = 'featureimportance.png'
        plt.savefig(plot_filename)
        fig = plt.gcf() 
        buf = io.BytesIO()
        fig.savefig(buf,format='png')
        buf.seek(0)
        string = base64.b64encode(buf.read())
        featureuri =  urllib.parse.quote(string)
        

 

        # Make predictions on the test set
        y_pred = model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        print(f"Accuracy: {accuracy:.2f}")


      
        y_score = model.predict_proba(X_test)
        class_labels = np.unique(np.concatenate((y_train, y_test), axis=None))
    
        #########Confusion Matrix###################
        # Generate confusion matrix     
        conf_matrix = confusion_matrix(y_test, y_pred)

        
        # Calculate classification report
        class_report = classification_report(y_test, y_pred, target_names=model.classes_, output_dict=True)

        # Convert classification report to a DataFrame
        class_report_df = pd.DataFrame(class_report).transpose()


        # Plot confusion matrix
        plt.figure(figsize=(10, 6))
        plt.switch_backend('agg')
        sns.heatmap(conf_matrix, annot=True, fmt="d", cmap="Blues",
                xticklabels=model.classes_, yticklabels=model.classes_)
        plt.xlabel('Predicted Labels')
        plt.ylabel('True Labels')
        plt.title('Confusion Matrix')
        # Save the plot as an image file
        plot_filename = 'confusion_matrix_plot.png'
        plt.savefig(plot_filename)
        fig = plt.gcf() 
        buf = io.BytesIO()
        fig.savefig(buf,format='png')
        buf.seek(0)
        string = base64.b64encode(buf.read())
        matrixuri =  urllib.parse.quote(string)
     
        # Save the figure to a BytesIO object
      
        # string = base64.b64encode(buf.read())

       
       
        
        
        # # #########ROC CURVES###################   
        # # # Assuming you have your model already trained and X_test contains test data
        # y_scores = model.predict_proba(X_test) # Probabilities of positive class
        # # print(y_scores.shape)
        # n_classes = y_scores.shape[1]  # Number of classes

        # fpr = dict()
        # tpr = dict()
        # roc_auc = dict()
        # # print(y_test)
        # # Binarize the class labels
        # y_test_binarized = label_binarize(y_test, classes=np.unique(y_test))
        # # print(y_test_binarized.shape)

        # # Create an empty list to store the ROC AUC values
        # roc_auc_values = []
        
        # plt.figure(figsize=(10, 6))
        # plt.switch_backend('agg')
        # # print(y_test_binarized.shape)
        # # print(n_classes)
        # for i in range(n_classes):
        #         fpr[i], tpr[i], _ = roc_curve(y_test_binarized[:, i], y_scores[:, i])
        #         roc_auc[i] = auc(fpr[i], tpr[i])
        #         roc_auc_values.append(roc_auc)
        #         # Plot ROC curve for each class
        #         # print("yes sir yes sir")

        #         # Plot ROC curve for each class
        #         # label = f'ROC curve (class {class_labels[i]}) - AUC = {i}'
        #         label = f'ROC curve (class {class_labels[i]})'

        #         plt.plot(fpr[i], tpr[i], label=label)



        # # Plot the diagonal line (random classifier)
        # plt.plot([0, 1], [0, 1], 'k--')

        # plt.xlabel('False Positive Rate')
        # plt.ylabel('True Positive Rate')
        # plt.title('ROC Curve')
        # plt.legend(loc='best')
        # # Save the plot as an image file
        # roc_image_path = 'path_to_save_image.png'
        # plt.savefig(roc_image_path)
        # fig = plt.gcf() 
        # buf = io.BytesIO()
        # fig.savefig(buf,format='png')
        # buf.seek(0)
        # string = base64.b64encode(buf.read())
        # roc_curve_uri =  urllib.parse.quote(string)

        # # Display ROC AUC values for each class
        # for i, auc_value in enumerate(roc_auc_values):
        #         print('ROC AUC (Class {class_labels[i]}): {auc_value}')





        
        # #########Learning Curve###################
        # # Create a learning curve
        # train_sizes, train_scores, test_scores = learning_curve(model, X_train, y_train, cv=5, n_jobs=-1, train_sizes=np.linspace(0.1, 1.0, 10))

        # # Calculate the mean and standard deviation of training and test scores
        # train_mean = np.mean(train_scores, axis=1)
        # train_std = np.std(train_scores, axis=1)
        # test_mean = np.mean(test_scores, axis=1)
        # test_std = np.std(test_scores, axis=1)

        # # Plot the learning curve
        # plt.figure(figsize=(10, 6))
        # plt.switch_backend('agg')
        # plt.plot(train_sizes, train_mean, color='blue', marker='o', markersize=5, label='Training accuracy')
        # plt.fill_between(train_sizes, train_mean + train_std, train_mean - train_std, alpha=0.15, color='blue')
        # plt.plot(train_sizes, test_mean, color='green', linestyle='--', marker='s', markersize=5, label='Validation accuracy')
        # plt.fill_between(train_sizes, test_mean + test_std, test_mean - test_std, alpha=0.15, color='green')

        # plt.xlabel('Number of Training Examples')
        # plt.ylabel('Accuracy')
        # plt.title('Learning Curve')
        # plt.legend(loc='lower right')
        # plt.grid()

        # # Save the plot as an image file
        # roc_image_path = 'learning_curve.png'
        # plt.savefig(roc_image_path)
        # fig = plt.gcf() 
        # buf = io.BytesIO()
        # fig.savefig(buf,format='png')
        # buf.seek(0)
        # string = base64.b64encode(buf.read())
        # learning_curve_uri =  urllib.parse.quote(string)



        # ########Class Distribution Curve########################
        # # Create a list of class labels
        

        # # Calculate the actual class distribution
        # actual_class_distribution = [np.sum(y_train == label) + np.sum(y_test == label) for label in class_labels]

        # # Calculate the predicted class distribution
        # y_pred = model.predict(X)#factoring the whole data
        # predicted_class_distribution = [np.sum(y_pred == label) for label in class_labels]

        # # Plot the class distribution
        # plt.figure(figsize=(10, 6))
        # plt.switch_backend('agg')
        # plt.bar(class_labels, actual_class_distribution, width=0.4, label='Actual', align='center', alpha=0.7)
        # plt.bar(class_labels, predicted_class_distribution, width=0.4, label='Predicted', align='edge', alpha=0.7)
        # plt.xlabel('Class Label')
        # plt.ylabel('Count')
        # plt.title('Class Distribution Plot')
        # plt.xticks(class_labels)
        # plt.legend()

        # # Save the plot as an image file
        # image_path = 'class_distribution_curve.png'
        # plt.savefig(image_path)
        # fig = plt.gcf() 
        # buf = io.BytesIO()
        # fig.savefig(buf,format='png')
        # buf.seek(0)
        # string = base64.b64encode(buf.read())
        # class_distribution_curve_uri =  urllib.parse.quote(string)
      
        if featuretypes == "dpg":
                
                print("dpg")
                
                rfTrainingModel = LastTrainingResultsRandomForest(
                        dpg_accuracy = f'{accuracy * 100}%',
                        matrix_data=conf_matrix.tolist(),
                        class_report=class_report_df.to_json(),
                        dpg_confusion_matrix_graph = matrixuri,
                        dpg_feature_importance_curve_graph =  featureuri,   
                )
                rfTrainingModel.save()


        elif featuretypes == "npg":
                
                print("npg")
                
                rfTrainingModel =   LastTrainingResultsRandomForest.objects.last()
                rfTrainingModel.npg_accuracy = f'{accuracy * 100}%'
                rfTrainingModel.matrix_data=conf_matrix.tolist()
                rfTrainingModel.class_report=class_report_df.to_json()
                rfTrainingModel.npg_confusion_matrix_graph = matrixuri
                rfTrainingModel.npg_feature_importance_curve_graph =  featureuri                     

                rfTrainingModel.save()

        elif featuretypes == "opg":
                rfTrainingModel =   LastTrainingResultsRandomForest.objects.last()
                            
                rfTrainingModel.opg_accuracy = f'{accuracy * 100}%'
                rfTrainingModel.matrix_data=conf_matrix.tolist()
                rfTrainingModel.class_report=class_report_df.to_json()
                rfTrainingModel.opg_confusion_matrix_graph = matrixuri
                rfTrainingModel.opg_feature_importance_curve_graph =  featureuri
              
                        
                
                rfTrainingModel.save()

        elif featuretypes == "npg_dpg":

                
                rfTrainingModel =   LastTrainingResultsRandomForest.objects.last()
                            
                rfTrainingModel.dpg_npg_accuracy = f'{accuracy * 100}%'
                rfTrainingModel.matrix_data=conf_matrix.tolist()
                rfTrainingModel.class_report=class_report_df.to_json()
                rfTrainingModel.dpg_npg_confusion_matrix_graph = matrixuri
                rfTrainingModel.npg_dpg_feature_importance_curve_graph =  featureuri
              
                        
                
                rfTrainingModel.save()

        elif featuretypes == "npg_opg":

                
                rfTrainingModel =   LastTrainingResultsRandomForest.objects.last()
                            
                rfTrainingModel.opg_npg_accuracy = f'{accuracy * 100}%'
                rfTrainingModel.matrix_data=conf_matrix.tolist()
                rfTrainingModel.class_report=class_report_df.to_json()
                rfTrainingModel.npg_opg_confusion_matrix_graph = matrixuri
                rfTrainingModel.npg_opg_feature_importance_curve_graph =  featureuri
              
                        
                
                rfTrainingModel.save()

        elif featuretypes == "dpg_opg":

                
                rfTrainingModel =   LastTrainingResultsRandomForest.objects.last()
                            
                rfTrainingModel.dpg_opg_accuracy = f'{accuracy * 100}%'
                rfTrainingModel.matrix_data=conf_matrix.tolist()
                rfTrainingModel.class_report=class_report_df.to_json()
                rfTrainingModel.dpg_opg_confusion_matrix_graph = matrixuri
                rfTrainingModel.dpg_opg_feature_importance_curve_graph =  featureuri
              
                        
                
                rfTrainingModel.save()

        elif featuretypes == "all":

                
                rfTrainingModel =   LastTrainingResultsRandomForest.objects.last()
                            
                rfTrainingModel.all_params_accuracy= f'{accuracy * 100}%'
                rfTrainingModel.matrix_data=conf_matrix.tolist()
                rfTrainingModel.class_report=class_report_df.to_json()
                rfTrainingModel.all_params_confusion_matrix_graph = matrixuri
                rfTrainingModel.all_params_feature_importance_curve_graph  =  featureuri
              
                
                rfTrainingModel.save()
                analysis = AnalysisRun.objects.last()
                analysis.stage = "Complete"  
                


        rf= LastTrainingResultsRandomForest.objects.last()
        analysis = AnalysisRun.objects.last()
        analysis.random_forest = rf
        analysis.save()

        # Clear the memory
        del model
        del X
        del y

        
        # Clear all existing Matplotlib plots
        plt.close('all')
     

        




