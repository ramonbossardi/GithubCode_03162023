from OTCCPScript.utils import Util
from random import random
from sklearn import datasets
from sklearn.model_selection import train_test_split
from randomforest.RandomForest import RandomForest
import numpy as np
from sklearn.ensemble import RandomForestClassifier  # or RandomForestRegressor for regression tasks
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score  # or other relevant metrics
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from kFDA.kfdamodel import KFDA
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
from matplotlib.colors import ListedColormap

from randomforest.models import UploadedFolder,AnalysisRun

def kfda(X,features, y,featuretype):

        print("starting")

        analysis = AnalysisRun.objects.last()
        analysis.stage = "KFDA Training"
        analysis.save()
        # X, y = make_classification(n_samples=100, n_features=2, n_classes=2, n_clusters_per_class=1, n_redundant=0, random_state=42)

        # Initialize and fit the LinearDiscriminantAnalysis model
        
        print("starting")

        X_train, X_test, y_train, y_test = train_test_split(
                X, y, test_size=0.2, random_state=1234
        )

        # Assuming X_train and y_train are NumPy matrices
        X_train_array = np.asarray(X_train)
        y_train_array = np.asarray(y_train)
         

        # Create an instance of Kfda
        kfda = KFDA(n_components=5, kernel='rbf')
        

        # Fit the model using NumPy arrays
        kfda.fit(X, y)

        y_pred = kfda.predict(X_test)
        
        accuracy = accuracy_score(y_test, y_pred)
        print(f"Accuracy: {accuracy:.2f}")  

       


        ######Confusion Matrix######
        # Generate confusion matrix     
        conf_matrix = confusion_matrix(y_test, y_pred)

        
        # Calculate classification report
        class_report = classification_report(y_test, y_pred, target_names=kfda.classes_, output_dict=True)

        # Convert classification report to a DataFrame
        class_report_df = pd.DataFrame(class_report).transpose()

        # Plot confusion matrix
        plt.figure(figsize=(8, 6))
        sns.heatmap(conf_matrix, annot=True, fmt="d", cmap="Blues",
                xticklabels=kfda
                .classes_, yticklabels=kfda.classes_)
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


        # Plot Class Centroids
        centroids = kfda.clf_.centroids_
       # Assuming you have reduced the data to 2 components (n_components=2)
        # You can create a colormap for the unique class labels
        cmap = ListedColormap(['red', 'blue', 'green', 'purple', 'orange', 'cyan', 'magenta'])

        # Scatter plot with colors based on class labels
        
        plt.figure(figsize=(10, 6))
        unique_y = np.unique(y)
        plt.scatter(centroids[:, 0], centroids[:, 1], c=np.arange(len(unique_y)), cmap=cmap, marker='x')
        plt.xlabel('Fisher Component 1')
        plt.ylabel('Fisher Component 2')
        plt.title('Class Centroids in Transformed Space')
        plt.colorbar(label='Class Label')

        # Save the plot as an image file
        plot_filename = 'feature_importance.png'
        plt.savefig(plot_filename)
        fig = plt.gcf() 
        buf = io.BytesIO()
        fig.savefig(buf,format='png')
        buf.seek(0)
        string = base64.b64encode(buf.read())
        centroiduri =  urllib.parse.quote(string)        




 
        

        
       # Create a learning curve using accuracy as the scoring metric
        train_sizes, train_scores, valid_scores = learning_curve(
        kfda, X, y, train_sizes=[0.1, 0.3, 0.5, 0.7, 0.9], cv=5, 
        scoring='accuracy', shuffle=True, random_state=42
        )
        
        # Calculate mean and standard deviation of the scores
        train_scores_mean = np.mean(train_scores, axis=1)
        train_scores_std = np.std(train_scores, axis=1)
        valid_scores_mean = np.mean(valid_scores, axis=1)
        valid_scores_std = np.std(valid_scores, axis=1)


        # Plot feature importance
        plt.figure(figsize=(10, 6))
        # Create a plot of the learning curve
        plt.figure(figsize=(10, 6))
        plt.title("Learning Curve for KFDA")
        plt.xlabel("Training Examples")
        plt.ylabel("Accuracy")
        plt.grid()
        plt.fill_between(train_sizes, 
                        train_scores_mean - train_scores_std,
                        train_scores_mean + train_scores_std, 
                        alpha=0.1, color="r")
        plt.fill_between(train_sizes, 
                        valid_scores_mean - valid_scores_std,
                        valid_scores_mean + valid_scores_std, 
                        alpha=0.1, color="g")
        plt.plot(train_sizes, train_scores_mean, 'o-', color="r", label="Training Accuracy")
        plt.plot(train_sizes, valid_scores_mean, 'o-', color="g", label="Validation Accuracy")
        plt.legend(loc="best")
        # plt.show()
        


        # Save the plot as an image file
        plot_filename = 'feature_importance.png'
        plt.savefig(plot_filename)
        fig = plt.gcf() 
        buf = io.BytesIO()
        fig.savefig(buf,format='png')
        buf.seek(0)
        string = base64.b64encode(buf.read())
        learning_curve_uri =  urllib.parse.quote(string)


        
        ######Feature Importance######
        # Get the coefficients (feature weights) of the linear discriminants
        # coefficients = kfda.coef_

        # # Compute the absolute values of the coefficients to get feature importance
        # feature_importance = np.abs(coefficients)

        # # Sort the feature importance values
        # sorted_idx = np.argsort(feature_importance)[0]  # Assuming a binary classification

        # # Get the names of the features
        # feature_names = features  # Assuming you have named columns in X_train

        # # Plot the feature importances
        # print(features.shape)
        # plt.figure(figsize=(10, 6))
        # plt.bar(range(len(sorted_idx)), feature_importance[0, sorted_idx], align="center")
        # plt.xticks(range(X_train.shape[1]), sorted_idx)
        # # plt.xticks(range(len(sorted_idx)), np.array(feature_names)[sorted_idx], rotation=90)
        # plt.xlabel("Feature")
        # plt.ylabel("Absolute Coefficient Value")
        # plt.title("Feature Importances (Absolute Coefficient Values) for kfda")
        # # plt.show()

       
        # Create a scatter plot for class separation
        plt.figure(figsize=(10, 8))

        X_test_reduced = kfda.transform(X_test)

        # Define colors for each class
        class_colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k']

        # Get unique class labels
        unique_classes = np.unique(y_test)

        # Plot data points for each class
        for class_label, color in zip(unique_classes, class_colors):
                class_data = X_test_reduced[y_test == class_label]
                plt.scatter(class_data[:, 0], class_data[:, 1], c=color, label=f'Class {class_label}')

        plt.xlabel('KFDA Component 1')
        plt.ylabel('KFDA Component 2')
        plt.title('Class Separation in KFDA Scatter Plot')
        plt.legend()
        # Save the plot as an image file
        plot_filename = 'feature_importance.png'
        plt.savefig(plot_filename)
        fig = plt.gcf() 
        buf = io.BytesIO()
        fig.savefig(buf,format='png')
        buf.seek(0)
        string = base64.b64encode(buf.read())
        class_seperation_uri =  urllib.parse.quote(string)
     
        print(featuretype)
        
        print(featuretype, "dioggtty")

        if featuretype == "dpg":
                print(featuretype, "diog")
                kfdaInstance = LastTrainingResultsKFDA(
                        dpg_accuracy = f'{accuracy *100}%',
                        dpg_roc_curve_graph  = "",
                        dpg_centroiduri = centroiduri,
                        dpg_confusion_matrix_graph = matrixuri,
                        number_of_cells = X.shape[0],
                        dpg_learning_curve_uri = learning_curve_uri,
                        dpg_class_seperation_uri = class_seperation_uri
                )

                kfdaInstance.save()

        elif featuretype == "opg":
                
                print(featuretype, "dioog")
                
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                kfdaInstance = LastTrainingResultsKFDA.objects.last()
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                kfdaInstance.opg_accuracy = f'{accuracy *100}%'
                kfdaInstance.opg_roc_curve_graph  = ""
                kfdaInstance.opg_centroiduri = centroiduri
                kfdaInstance.opg_confusion_matrix_graph = matrixuri
                kfdaInstance.number_of_cells = X.shape[0]
                kfdaInstance.opg_learning_curve_uri = learning_curve_uri
                kfdaInstance.opg_class_seperation_uri = class_seperation_uri
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                        

                kfdaInstance.save()
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                                

        else:
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                kfdaInstance = LastTrainingResultsKFDA.objects.last()
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                kfdaInstance.opg_accuracy = f'{accuracy *100}%',
                kfdaInstance.opg_roc_curve_graph  = "",
                kfdaInstance.opg_centroiduri = centroiduri,
                kfdaInstance.opg_confusion_matrix_graph = matrixuri,
                kfdaInstance.number_of_cells = X.shape[0],
                kfdaInstance.opg_learning_curve_uri = learning_curve_uri,
                kfdaInstance.opg_class_seperation_uri = class_seperation_uri
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                        

                kfdaInstance.save()
                print("CCCCCCCCCCCCCCCCRASHING OF THE")
                                

  
        print("saved")
        kfdaInstance = LastTrainingResultsKFDA.objects.last()
                        
   

      
        analysis = AnalysisRun.objects.last()
        analysis.stage ="Complete"
        analysis.kfda = kfdaInstance
        analysis.save()

        # Clear the memory
        plt.close('all')
        del kfda
        del X
        del y

        # Util.send_email(
        #         data = {
        #                 'email_subject':"Training Complete",
        #                 'email_body':f'Your samples have been run successfully. Use this  link to view the results:  https://fierce-journey-20199-e167156baf87.herokuapp.com/analysis/{analysis.id}/',
        #                 'to_email':analysis.email

        #         }
        # )




        # Project the data onto the first discriminant direction
        # X_projected = kfda.transform(X)

        # Plot the original data and the projected data
        # plt.figure(figsize=(10, 5))

        # plt.subplot(1, 2, 1)
        # plt.scatter(X[y == 0][:, 0], X[y == 0][:, 1], label='Class 0', marker='o')
        # plt.scatter(X[y == 1][:, 0], X[y == 1][:, 1], label='Class 1', marker='x')
        # plt.title('Original Data')
        # plt.legend()

        # plt.subplot(1, 2, 2)
        # plt.scatter(X_projected[y == 0], np.zeros_like(X_projected[y == 0]), label='Class 0', marker='o')
        # plt.scatter(X_projected[y == 1], np.zeros_like(X_projected[y == 1]), label='Class 1', marker='x')
        # plt.title('Projected Data')
        # plt.legend()

        # plt.tight_layout()
        # plt.show()


# {% if trained_model.roc_curve_image %}
# <img src="{{ trained_model.roc_curve_image.url }}" alt="ROC Curve">
# {% else %}
# <p>No ROC curve image available</p>
# {% endif %}