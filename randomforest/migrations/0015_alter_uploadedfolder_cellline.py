# Generated by Django 4.2.3 on 2023-08-16 17:24

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ("randomforest", "0014_alter_uploadedfolder_cellline"),
    ]

    operations = [
        migrations.AlterField(
            model_name="uploadedfolder",
            name="cellline",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                to="randomforest.celllines",
            ),
        ),
    ]