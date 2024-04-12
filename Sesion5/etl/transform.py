import pandas as pd

def transform_time_from_order(table, query):

    return pd.read_sql(table, query) 
