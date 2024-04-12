import pandas as pd

def load_dw_retail(dimension,conn,df):
    try:
        df.to_sql(dimension,conn,if_exists='append', index=False)
    except Exception as e:
        print(e)
        