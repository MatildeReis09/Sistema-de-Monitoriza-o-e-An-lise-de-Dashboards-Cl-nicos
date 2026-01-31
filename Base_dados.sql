
CREATE TABLE Person (
id serial primary key,
name varchar (200) NOT NULL, 
age Date, 
sex varchar
);


CREATE TABLE Consult(
id serial primary key,
pacient_id int, 
consult_date DATE,
CONSTRAINT FK_pacient_id FOREIGN KEY (pacient_id) REFERENCES Person (id)
);

CREATE TABLE Read_data(
id serial primary key,
pacient_id int,
consult_id int,
read_type varchar(200),
unid varchar(20),
value decimal(10,2),
date_time TIMESTAMP default current_timestamp,
CONSTRAINT FK_pacient_id FOREIGN KEY (pacient_id) REFERENCES Person (id),
CONSTRAINT FK_consult_id FOREIGN KEY (consult_id) REFERENCES Consult (id)
);

CREATE TABLE Alert(
id serial primary key,
read_id int,
message TEXT,
CONSTRAINT FK_read_id FOREIGN KEY (read_id) REFERENCES Read_data (id)
);

-- trigger de alertas 