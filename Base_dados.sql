

CREATE TABLE Person (
id_person serial primary key,
id_pacient int, 
name varchar (200), 
birth_date Date, 
sex varchar,
BMI decimal(5,2)
);


CREATE TABLE Consult(
id serial primary key,
pacient_id int, 
consult_date DATE,
diagnosis varchar(20)
CONSTRAINT FK_pacient_id FOREIGN KEY (pacient_id) REFERENCES Person (id_person)
);

CREATE TABLE Read_data(
id serial primary key,
pacient_id int,
consult_id int,
read_type varchar(200),
unid varchar(20),
value decimal(10,2),
date_time TIMESTAMP default current_timestamp,
CONSTRAINT FK_pacient_id FOREIGN KEY (pacient_id) REFERENCES Person (id_person),
CONSTRAINT FK_consult_id FOREIGN KEY (consult_id) REFERENCES Consult (id)
);

CREATE TABLE Alert(
id serial primary key,
read_id int,
message TEXT,
CONSTRAINT FK_read_id FOREIGN KEY (read_id) REFERENCES Read_data (id)
);

-- Funçao trigger de alertas 
CREATE OR REPLACE Function FN_Critical_Alert()
Returns trigger as $$
declare p_sex varchar;
Begin 

--declarar sexo do paciente para depois o podermos usar 
SELECT sex INTO p_sex FROM Person WHERE id_person = NEW.pacient_id;


if --alerta de açucares no sangue em jejum 
New.read_type = 'glucose' Then

if New.value <= 70 then
insert into Alert (read_id, message)
value (new.id, 'Atenção, Hipoglicémia Detetada ('|| New.value|| 'mg/dl)');

elseif 
new.read_type = 'glucose' and New.value >100 & < 125 then 
insert into Alert ( read_id, message)
value ( new.id, 'Atenção, Pré-Diabetes ('|| new.value||' mg/dl');

elseif
new.read_type = 'glucose' and New.value > 126 then
insert into Alert ( read_id, message)
value ( new.id, 'Atenção, Hiperglicémia Detetada (Diabetes) (' || new.value|| 'mg/dl)');

end if; 

-- alertas para valores de creatina 
elseif new.read_type = 'creatinine' then 

if (p_sex = 'Female' and new.value >1,2) or (p_sex= 'Male' and new.value > 1,3) then 
insert into Alert ( read_type, message)
value ( new.id, 'Atenção, Nivéis de Creatina elevados (' || new.value|| 'mg/dl)');

end if;

elseif new.read_type = 'cholesterol' and New.value > 200 then
insert into Alert (read_id, message)
value( new.id, 'Atenção,  Nivéis de Colesterol Elevado('|| New.value|| 'mg/dl)');

end if; 

Return new;
end;
$$Language plpgsql;

Create Trigger TG_Critical_Alert
after insert or update on Read_data
for each row
execute function FN_Critical_Alert();
-- depois de inserir linha na tabela read_data,aciona a função e insere os alerta na tabela alert
