# Generated by Django 4.2.3 on 2023-08-09 19:10

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('randomforest', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='CellLines',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=500)),
            ],
        ),
        migrations.AddField(
            model_name='uploadedfolder',
            name='cellline',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='randomforest.celllines'),
        ),
    ]
