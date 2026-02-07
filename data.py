import kagglehub
import pandas as pd 
import os
from faker import Faker #para popular dados que o excel não fornece
import random
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
fake = Faker('pt_PT')#dados em Portugues

print ("aqui , vamos começar a popular")

for index, row in df.iterrows():

    nome = fake.name() #gerar nome de paciente
    data_consult = fake.date_between(start_date='-1y', end_date= 'today') #gerar dada real de consulta (desde o ano anteriro ate agora)
    #calcular a data de nascimento aproximada com a idade da base de dados
    dob= datetime.now() -timedelta(days= int (row['age'])*365.25)
    #365.25 é para compensar anos bissextos

    cur.execute(
        #inserir dados na tabela de person
        """INSERT INTO Person (id_pacient, name, birth_date, sex, bmi)
        VALUES (%s,%s,%s,%s,%s) RETURNING id_person""",
        (int (row['patient_id']), nome, dob.date(), row['sex'], float(row['bmi']))
    )

    person_id = cur.fetchone()[0]#guarda id interno (chaves estrangueiras)

    cur.execute(
        """INSERT INTO Consult (pacient_id, consult_date, diagnosis)
        VALUES (%s,%s,%s) RETURNING id""",
        (person_id,data_consult ,row['diagnosis'])
    )
    consult_id= cur.fetchone()[0]

    leituras = [
        ('glucose', float(row['glucose']), 'mg/dl'),
        ('creatinine', float(row['creatinine']),'mg/dl'),
        ('cholesterol',float(row['cholesterol']),'mg/dl')
    ]

    for tipo, valor, unid in leituras : 
        cur.execute(
            """INSERT INTO Read_data (pacient_id, consult_id, read_type, value, unid, date_time)
            VALUES(%s,%s,%s,%s,%s,%s)""",
            (person_id, consult_id, tipo, valor, unid, data_consult)
        )

conn.commit()

cur.close()
conn.close()

print("população concluida")


