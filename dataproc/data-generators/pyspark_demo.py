#! /usr/bin/python

"""
 Sample command for Dataproc - gcloud dataproc jobs submit pyspark --cluster poc-cluster-efm --region us-central1 gs://bucket/code/pyspark_demo.py -- 10 gs://bucket/object
 Generates a dataframe with schema as ["firstname","middlename","lastname","dob","gender","salary", "age"] and writes to specified path
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

  
spark = SparkSession.builder \
        .appName("my-demo-app") \
        .getOrCreate()

def generate_random_string(length):
    rand_string = ''.join(random.choices(string.ascii_letters + string.digits, k=length))
    return rand_string

def generate_random_gender():
    return random.choices('MF')[0]

def random_date(start, end):
    """
    This function will return a random datetime between two datetime 
    objects.
    """
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = randrange(int_delta)
    return start + timedelta(seconds=random_second)

def generate_df(rows):
    # Create SparkSession 
    d1 = datetime.strptime('1/1/1900 1:30 PM', '%m/%d/%Y %I:%M %p')
    d2 = datetime.strptime('1/1/2009 4:50 AM', '%m/%d/%Y %I:%M %p')
    columns = StructType([StructField('firstname', StringType(), False),
            StructField('middlename', StringType(), False),
            StructField('lastname', StringType(), False),
            StructField('dob', StringType(), False),
            StructField('gender', StringType(), False),
            StructField('salary', IntegerType(), False)])

    df = spark.range(1, rows)
    generate_random_string_udf = udf(lambda x: generate_random_string(x))
    random_date_udf = udf(lambda x,y: random_date(x,y), DateType())
    generate_random_gender_udf = udf(lambda x : generate_random_gender())

    df = df.withColumn('firstname',generate_random_string_udf(lit(10))) \
        .withColumn('middlename',generate_random_string_udf(lit(3))) \
            .withColumn('lastname',generate_random_string_udf(lit(5))) \
                .withColumn('dob',random_date_udf(lit(d1), lit(d2))) \
                    .withColumn('gender',generate_random_gender_udf(lit(0))) \
                        .withColumn('salary', rand(1)*1000000)
    return df



 

rows = int(sys.argv[1])
date = datetime.strptime(str(datetime.now()), '%Y-%m-%d %H:%M:%S.%f')
suffix = str(date.year) + str(date.month) + str(date.day) + str(date.hour) + str(date.minute) + str(date.second)
path = sys.argv[2] + "/" + suffix
print("Generating " + str(rows) + " Rows")
df = generate_df(rows)
df_age = df.withColumn("age", months_between(current_date(),to_timestamp("dob"))/12)
df_age.write.csv(path, compression="gzip")
print("Created " + str(rows) + " Rows at " + path)
