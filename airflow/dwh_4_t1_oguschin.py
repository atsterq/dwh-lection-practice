from datetime import datetime

from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook


def generate_data(**kwargs):
    import random

    import pandas as pd

    data = {
        "id": range(1, 101),
        "value": [f"value_{random.randint(1, 100)}" for _ in range(1, 101)],
    }
    df = pd.DataFrame(data)

    file_path = "/tmp/data_dwh_4_t1_oguschin.csv"

    df.to_csv(file_path, index=False)

    kwargs["task_instance"].xcom_push(key="file_path", value=file_path)


def load_data(**kwargs):
    import pandas as pd
    from sqlalchemy import create_engine

    df = pd.read_csv("/tmp/processed_data/data_dwh_4_t1_oguschin.csv")

    pg_hook = PostgresHook(postgres_conn_id="dwh_4_t1_oguschin_pg")

    create_table_sql = """
    CREATE TABLE IF NOT EXISTS test_data_dwh_4_t1_oguschin (
        id INTEGER PRIMARY KEY,
        value VARCHAR(50)
    );
    """
    pg_hook.run(create_table_sql)

    conn_uri = pg_hook.get_uri()
    engine = create_engine(conn_uri)

    df.to_sql(
        "test_data_dwh_4_t1_oguschin", engine, if_exists="replace", index=False
    )

    kwargs["task_instance"].xcom_push(key="record_count", value=len(df))


def log_record_count(**kwargs):
    record_count = kwargs["task_instance"].xcom_pull(
        task_ids="load_data", key="record_count"
    )
    print(f"Loaded{record_count} records.")


@dag(
    dag_id="dwh_4_t1_oguschin",
    schedule_interval=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
)
def generate_and_load_data():
    generate = PythonOperator(
        task_id="generate_data",
        python_callable=generate_data,
    )

    move = BashOperator(
        task_id="move_file",
        bash_command='mkdir -p /tmp/processed_data && mv {{ task_instance.xcom_pull(task_ids="generate_data", key="file_path") }} /tmp/processed_data/data_dwh_4_t1_oguschin.csv',
    )

    load = PythonOperator(
        task_id="load_data",
        python_callable=load_data,
    )

    log = PythonOperator(
        task_id="log_count",
        python_callable=log_record_count,
    )

    generate >> move >> load >> log


dag = generate_and_load_data()
