from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
# Create your models here.

class CellLines(models.Model):
    name = models.CharField(max_length = 500)
    
    def __str__(self):
        return f"{self.name}"

class UploadedFolder(models.Model):
    folder = models.FileField(upload_to='uploaded_folders/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    cellline = models.ForeignKey(CellLines,null = True, blank = True,on_delete =  models.CASCADE)

    def __str__(self):
        return f"{self.folder.name} - {self.uploaded_at}"

class LastTrainingResultsRandomForest(models.Model):
    time = models.DateTimeField(auto_now_add=True)
    # graph = models.CharField(max_length = 50000)
    class_report = models.JSONField()
    matrix_data = models.JSONField()
    number_of_cells =  models.CharField(max_length = 500)
    dpg_accuracy = models.CharField(max_length = 500)
    dpg_npg_accuracy = models.CharField(max_length = 500)
    dpg_opg_accuracy = models.CharField(max_length = 500)
    opg_npg_accuracy = models.CharField(max_length = 500)
    all_params_accuracy = models.CharField(max_length = 500)
    
    all_params_confusion_matrix_graph = models.CharField(max_length = 500000)
    dpg_opg_confusion_matrix_graph = models.CharField(max_length = 500000)
    dpg_npg_confusion_matrix_graph = models.CharField(max_length = 500000)
    npg_opg_confusion_matrix_graph = models.CharField(max_length = 500000)
    dpg_confusion_matrix_graph = models.CharField(max_length = 500000)
    npg_confusion_matrix_graph = models.CharField(max_length = 500000)
    opg_confusion_matrix_graph = models.CharField(max_length = 500000)


    all_params_feature_importance_curve_graph = models.CharField(max_length = 500000)
    dpg_feature_importance_curve_graph = models.CharField(max_length = 500000)
    opg_feature_importance_curve_graph = models.CharField(max_length = 500000)
    npg_feature_importance_curve_graph = models.CharField(max_length = 500000)
    npg_opg_feature_importance_curve_graph = models.CharField(max_length = 500000)
    npg_dpg_feature_importance_curve_graph = models.CharField(max_length = 500000)
    dpg_opg_feature_importance_curve_graph = models.CharField(max_length = 500000)


    #Other  graphs not currently included
    dpg_roc_curve_graph = models.CharField(max_length = 500000)
    dpg_roc_curve_image = models.ImageField(upload_to='roc_curves/', null=True, blank=True)
    dpg_learning_curve_graph =  models.CharField(max_length = 500000)
    dpg_class_distribution_curve_uri =  models.CharField(max_length = 500000)
    npg_accuracy = models.CharField(max_length = 500)
    npg_roc_curve_graph = models.CharField(max_length = 500000)
    npg_roc_curve_image = models.ImageField(upload_to='roc_curves/', null=True, blank=True)
    npg_learning_curve_graph =  models.CharField(max_length = 500000)
    npg_class_distribution_curve_uri =  models.CharField(max_length = 500000)
    opg_accuracy = models.CharField(max_length = 500)
    opg_roc_curve_graph = models.CharField(max_length = 500000)
    opg_roc_curve_image = models.ImageField(upload_to='roc_curves/', null=True, blank=True)
    opg_learning_curve_graph =  models.CharField(max_length = 500000)
    opg_class_distribution_curve_uri =  models.CharField(max_length = 500000)


    

    # def __str__(self):
    #     return f"{self.folder.name} - {self.uploaded_at}"
    

class LastTrainingResultsKFDA(models.Model):
    time = models.DateTimeField(auto_now_add=True)
    number_of_cells =  models.CharField(max_length = 500)
    class_report = models.JSONField(blank = True, null = True)
    dpg_learning_curve_uri = models.CharField(max_length = 500000)
    dpg_class_seperation_uri = models.CharField(max_length = 500000)
    dpg_accuracy = models.CharField(max_length = 500)
    dpg_roc_curve_graph = models.CharField(max_length = 500000)
    dpg_confusion_matrix_graph = models.CharField(max_length = 500000)
    dpg_centroiduri = models.CharField(max_length = 500000)
    dpg_roc_curve_image = models.ImageField(upload_to='roc_curves/', null=True, blank=True)
    dpg_matrix_data = models.JSONField(blank = True, null = True)   
    npg_learning_curve_uri = models.CharField(max_length = 500000)
    npg_class_seperation_uri = models.CharField(max_length = 500000)
    npg_accuracy = models.CharField(max_length = 500)
    npg_roc_curve_graph = models.CharField(max_length = 500000)
    npg_confusion_matrix_graph = models.CharField(max_length = 500000)
    npg_centroiduri = models.CharField(max_length = 500000)
    npg_roc_curve_image = models.ImageField(upload_to='roc_curves/', null=True, blank=True)
    npg_class_report = models.JSONField(blank = True, null = True)
    npg_matrix_data = models.JSONField(blank = True, null = True)
    opg_learning_curve_uri = models.CharField(max_length = 500000)
    opg_class_seperation_uri = models.CharField(max_length = 500000)
    opg_accuracy = models.CharField(max_length = 500)
    opg_roc_curve_graph = models.CharField(max_length = 500000)
    opg_confusion_matrix_graph = models.CharField(max_length = 500000)
    opg_centroiduri = models.CharField(max_length = 500000)
    opg_roc_curve_image = models.ImageField(upload_to='roc_curves/', null=True, blank=True)
    opg_class_report = models.JSONField(blank = True, null = True)
    opg_matrix_data = models.JSONField(blank = True, null = True)    

    # def __str__(self):
    #     return f"{self.folder.name} - {self.uploaded_at}"
    

class AnalysisRun(models.Model):
    kfda =  models.ForeignKey(LastTrainingResultsKFDA, on_delete = models.CASCADE, default = 10)
    random_forest =  models.ForeignKey(LastTrainingResultsRandomForest, on_delete = models.CASCADE, default = 1)
    number_of_objects =  models.CharField(max_length = 50, blank = True, null = True)
    current_segment =  models.CharField(max_length = 500, blank = True, null = True)
    progress =  models.DecimalField(max_digits =  5, decimal_places  = 2)
    stage = models.CharField(max_length = 500, blank = True, null = True)
    comp_options = models.TextField()
    param_options = models.TextField()
    features = models.TextField()
    celllines = models.ManyToManyField(CellLines, blank = True, null = True)
    cellnum = models.CharField(max_length =50)
    objectnum =  models.CharField(max_length =50)
    inProgress = models.BooleanField(default = False)
    email = models.CharField(max_length =70)
    datetime = models.DateTimeField(auto_now_add = True, blank = True, null = True)
    X_data = models.BinaryField(blank = True, null = True)
    y_data = models.BinaryField(blank = True, null = True)
    objectId_data = models.TextField()


