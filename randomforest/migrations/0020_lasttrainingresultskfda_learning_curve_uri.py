# Generated by Django 4.2.3 on 2023-08-27 03:35

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        (
            "randomforest",
            "0019_lasttrainingresultsrandomforest_class_distribution_curve_uri",
        ),
    ]

    operations = [
        migrations.AddField(
            model_name="lasttrainingresultskfda",
            name="learning_curve_uri",
            field=models.CharField(default=1, max_length=50000),
            preserve_default=False,
        ),
    ]
