#!/usr/bin/env python

"""
Author: Jerome Rajan
Usage: gcloud dataproc jobs submit pyspark --cluster poc-cluster --region us-central1 gs://bucket/code/pyspark_generate_data.py -- gs://bucket/object
Reads data from supplied path and performs some transformations, aggregations and joins. The source data will have to be generated 
in the schema generated by the pyspark_generate_data.py script
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from random import randrange
from datetime import timedelta
import random, string
from datetime import datetime
import sys
from pyspark.sql.types import *
import math


spark = SparkSession \
    .builder \
        .appName("my-notebook-app") \
            .getOrCreate()

def generatePathSuffix():
    date = datetime.strptime(str(datetime.now()), '%Y-%m-%d %H:%M:%S.%f')
    suffix = str(date.year) + str(date.month) + str(date.day) + str(date.hour) + str(date.minute) + str(date.second)
    return suffix

def processArgs():
    src_path = sys.argv[1]
    return src_path

src_path = processArgs()
suffix = generatePathSuffix()
df = spark.read.csv(src_path, inferSchema=True)
df = df.withColumnRenamed("_c0","id") .withColumnRenamed("_c1","firstname") .withColumnRenamed("_c2","middlename") .withColumnRenamed("_c3","lastname") .withColumnRenamed("_c4","dob") .withColumnRenamed("_c5","gender") .withColumnRenamed("_c6","salary") .withColumnRenamed("_c7","age")
df.createOrReplaceTempView("df")
spark.sql("select round(age,0) as age, avg(salary) as avg_sal from df group by round(age,0)").createOrReplaceTempView("df_avg_sal_by_age")
df_status = spark.sql("select \
    case \
        when age between 1 and 18 \
            then 'Needs Guardian' \
        when age between 18 and 60 \
            then 'Enjoy' \
        when age >60 \
            then 'Party!!' \
    end as status, \
        age, avg_sal \
    from df_avg_sal_by_age")

df_status.createOrReplaceTempView("df_status")
df_final = spark.sql("select firstname, lastname, df_status.age, status from df_status inner join df on df_status.age = df.age")
df_final.write.partitionBy("age").parquet("gs://datasherlock/final_data/"+suffix)