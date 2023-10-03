# Generated by Django 4.2.3 on 2023-09-08 17:07

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("randomforest", "0034_analysisrun_features_alter_analysisrun_objectid_data"),
    ]

    operations = [
        migrations.RenameField(
            model_name="lasttrainingresultskfda",
            old_name="accuracy",
            new_name="dpg_accuracy",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultskfda",
            old_name="centroiduri",
            new_name="dpg_centroiduri",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultskfda",
            old_name="class_report",
            new_name="dpg_class_report",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultskfda",
            old_name="confusion_matrix_graph",
            new_name="dpg_confusion_matrix_graph",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultskfda",
            old_name="matrix_data",
            new_name="dpg_matrix_data",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultskfda",
            old_name="roc_curve_graph",
            new_name="dpg_roc_curve_graph",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultskfda",
            old_name="roc_curve_image",
            new_name="dpg_roc_curve_image",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultsrandomforest",
            old_name="accuracy",
            new_name="dpg_accuracy",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultsrandomforest",
            old_name="class_distribution_curve_uri",
            new_name="dpg_class_distribution_curve_uri",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultsrandomforest",
            old_name="confusion_matrix_graph",
            new_name="dpg_confusion_matrix_graph",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultsrandomforest",
            old_name="feature_importance_curve_graph",
            new_name="dpg_feature_importance_curve_graph",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultsrandomforest",
            old_name="learning_curve_graph",
            new_name="dpg_learning_curve_graph",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultsrandomforest",
            old_name="roc_curve_graph",
            new_name="dpg_roc_curve_graph",
        ),
        migrations.RenameField(
            model_name="lasttrainingresultsrandomforest",
            old_name="roc_curve_image",
            new_name="dpg_roc_curve_image",
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="npg_accuracy",
            field=models.CharField(default=1, max_length=500),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="npg_centroiduri",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="npg_class_report",
            field=models.JSONField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="npg_confusion_matrix_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="npg_matrix_data",
            field=models.JSONField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="npg_roc_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="npg_roc_curve_image",
            field=models.ImageField(blank=True, null=True, upload_to="roc_curves/"),
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="opg_accuracy",
            field=models.CharField(default=1, max_length=500),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="opg_centroiduri",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="opg_class_report",
            field=models.JSONField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="opg_confusion_matrix_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="opg_matrix_data",
            field=models.JSONField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="opg_roc_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="opg_roc_curve_image",
            field=models.ImageField(blank=True, null=True, upload_to="roc_curves/"),
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="npg_accuracy",
            field=models.CharField(default=1, max_length=500),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="npg_class_distribution_curve_uri",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="npg_confusion_matrix_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="npg_feature_importance_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="npg_learning_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="npg_roc_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="npg_roc_curve_image",
            field=models.ImageField(blank=True, null=True, upload_to="roc_curves/"),
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="opg_accuracy",
            field=models.CharField(default=1, max_length=500),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="opg_class_distribution_curve_uri",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="opg_confusion_matrix_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="opg_feature_importance_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="opg_learning_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="opg_roc_curve_graph",
            field=models.CharField(default=1, max_length=500000),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="lasttrainingresultsrandomforest",
            name="opg_roc_curve_image",
            field=models.ImageField(blank=True, null=True, upload_to="roc_curves/"),
        ),
    ]