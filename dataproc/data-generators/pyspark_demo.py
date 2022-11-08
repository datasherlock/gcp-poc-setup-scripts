#! /usr/bin/python

"""
 Sample command for Dataproc - gcloud dataproc jobs submit pyspark --cluster poc-cluster-efm --region us-central1 gs://bucket/code/pyspark_demo.py -- 10 gs://bucket/object
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from random import randrange
from datetime import timedelta
import random, string
from datetime import datetime
import sys
  

def generate_random_string(length):
    rand_string = ''.join(random.choices(string.ascii_letters + string.digits, k=length))
    return rand_string

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
    data=[]
    d1 = datetime.strptime('1/1/1900 1:30 PM', '%m/%d/%Y %I:%M %p')
    d2 = datetime.strptime('1/1/2009 4:50 AM', '%m/%d/%Y %I:%M %p')
    columns = ["firstname","middlename","lastname","dob","gender","salary"]
    for i in range(1,rows):
        data.append((generate_random_string(10), \
                  generate_random_string(3), \
                  generate_random_string(5), \
                  random_date(d1, d2), \
                  random.choices('MF')[0], \
                  random.randint(-10,10000000) \
                 ))
    return spark.createDataFrame(data=data, schema = columns)

spark = SparkSession.builder \
        .appName("my-demo-app") \
        .getOrCreate() 

 

rows = int(sys.argv[1])
path = sys.argv[2]
print("Generating " + str(rows) + " Rows")
df = generate_df(rows)
df_age = df.withColumn("age", months_between(current_date(),to_timestamp("dob"))/12)
df_age.write.csv(path)
print("Created " + str(rows) + " Rows at " + path)
