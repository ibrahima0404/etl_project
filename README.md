# Mise en place d'un pipeline ETL depuis une base MongoDB

Ce projet met en place un pipeline ETL (Extract, Transform, Load) utilisant Apache Airflow pour :

  - Extraire des données stockées dans MongoDB,

  - Transformer/traiter les données (via Python + Pandas),

  - Charger les données dans une base PostgreSQL.

Il inclut des scripts pour installer les bases de données, charger des données et des fichiers pour exécuter le pipeline sous Airflow ou jupyter notebook.

## Structure
```
│── etl_project/
│   ├── etl_dag.py                 # DAG Airflow
│   ├── install_postgresql.sh      # Script installation PostgreSQL
│   ├── install_mongo_db.sh        # Script installation MongoDB
│   ├── load_data_into_mongo_db.sh # Chargement de données dans MongoDB
│   ├── test_etl.ipynb             # Notebook de test du pipeline
```

### 1. Cloner le dépôt
```bash
git clone git@github.com:ibrahima0404/etl_project.git

