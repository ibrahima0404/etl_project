from datetime import timedelta, datetime
from dateutil.relativedelta import relativedelta
from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator

HOST = "34.155.6.23"
MONGO_PORT = 27017
PSQL_PORT = 5432
DB_USER = "pacha"
DB_PASSWORD = "passer"

default_args = {
    "owner": "Pacha",
    "retries": 1,
    "retry_delay": timedelta(seconds=5)
}

def extract_from_mongo_and_load_to_postgresql(**kwargs):
    from sqlalchemy import create_engine
    import pandas as pd
    from pymongo import MongoClient

    date = datetime.fromisoformat(kwargs['ts'])
    six_months_ago = date - relativedelta(months=6)

    # --- Connexion à MongoDB et chargement des données---
    client = MongoClient(f"mongodb://{HOST}:{MONGO_PORT}/") 
    db = client["videoGames"]
    collection = db["games"]
    cursor = collection.find()
    df = pd.DataFrame(list(cursor))

    # --- Aggrégation ---
    df["review_date"] = pd.to_datetime(df["reviewTime"], format="%m %d, %Y", utc=True)
    df_last_6_months = df[(df["review_date"] >= six_months_ago) & (df["review_date"] <= date)]
    df_agg = df_last_6_months.groupby("asin").agg(
        average_rating=("overall", "mean"),
        rating_count=("reviewerID", "count"),
        oldest_rating=("review_date", "min"),
        latest_rating=("review_date", "max")
    )

    df_agg = df_agg.rename_axis("game_id").reset_index()

    # --- Insertion dans la DB ---
    engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{HOST}:{PSQL_PORT}/video_games")
    df_agg.to_sql("top_rated_games", engine, if_exists="append", index=False)



    
with DAG(
    dag_id="etl_dag",
    default_args=default_args,
    schedule="@daily",
    start_date=datetime(2025, 9, 17),
    catchup=False
) as dag:
    
    task_extract = PythonOperator(
        task_id='extract_load',
        python_callable=extract_from_mongo_and_load_to_postgresql
    )

    task_extract
