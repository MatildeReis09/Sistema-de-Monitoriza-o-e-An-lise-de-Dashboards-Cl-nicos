import kagglehub
import pandas as pd 
import os
from datetime import datetime, timedelta
import psycopg2

# Download latest version
##importar dataset retirado do kaggle 
##combinar o caminho para localizar o ficheiro e le-lo
path = kagglehub.dataset_download("uom190346a/synthetic-clinical-tabular-dataset")

file_name = "synthetic_clinical_dataset.csv"
full_path = os.path.join(path, file_name)

df = pd.read_csv(full_path)#leitura


#limpeza de dados
df = df.dropna()

## configurar a ligação ao postgreSQL 
#conn - conexão, ponte com a base de dados  
conn = psycopg2.connect(
    dbname = "ClinicalData",
    user = "postgres",
    password = "ipca",
    host = "localhost"
)

cur = conn.cursor()
# cursor - mensageiro que faz o caminho obter e entregar a informação
print ("aqui , vamos começar a popular")

for index, row in df.iterrows():