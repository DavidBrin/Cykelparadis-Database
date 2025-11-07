DROP DATABASE IF EXISTS bikeshop;
CREATE DATABASE bikeshop;
USE bikeshop;

create table manufacturers (
    manufacturer_name   varchar(255) primary key,
    country				varchar(100)
);

create table bikes (
		bike_code int primary key,
        bike_type varchar(50) not null, 
        speeds int not null check (speeds>=0),
        weight_kg decimal(5, 2) not null check(weight_kg>0), 
        wheel_diameter decimal(4, 1) not null check(wheel_diameter>0), 
        manufacturer_name varchar(255) not null,
        constraint fk_bikes_manufacturer
			foreign key (manufacturer_name) references manufacturers (manufacturer_name)
            on update cascade
            on delete restrict
);  

create table parts (
	manufacturer_name varchar(255) not null,
    part_code varchar(40) not null, 
    part_description varchar(255) not null, 
    unit_price decimal (10, 2) not null check (unit_price>=0), 
    primary key (manufacturer_name, part_code),
    constraint fk_parts_manufacturer
		foreign key (manufacturer_name) references manufacturers (manufacturer_name)
        on update cascade
        on delete cascade
);

create table compatible_parts(
	bike_code int not null,
    manufacturer_name varchar(255) not null,
    part_code varchar(40) not null, 
    primary key (bike_code, manufacturer_name, part_code),
    constraint fk_cp_bike
		foreign key (bike_code) references bikes(bike_code)
        on update cascade
        on delete cascade,
	constraint fk_cp_part
		foreign key (manufacturer_name, part_code) references parts(manufacturer_name, part_code)
        on update cascade
        on delete cascade
);

create table customers(
	cpr_number varchar(20) primary key,
    full_name varchar(100) not null,
    street varchar(100) not null,
    city varchar(100) not null,
    postal_code varchar(20) not null,
    phone varchar(20) not null,
    email varchar(100) not null
);

create table owns (
	cpr_number varchar(20) not null,
    bike_code int not null, 
    since_date date not null,
    primary key (cpr_number, bike_code, since_date),
    constraint fk_own_customer
		foreign key (cpr_number) references customers(cpr_number)
        on update cascade
        on delete cascade, 
	constraint fk_owns_bike
		foreign key(bike_code) references bikes(bike_code)
        on update cascade
        on delete cascade
);

create table repair_jobs (
	bike_code int not null, 
    job_datetime datetime not null, 
    customer_cpr varchar(20) not null,
    duration_min int not null check(duration_min>=0), 
    cost decimal(10, 2) not null check (cost>=0),
    primary key (bike_code, job_datetime),
    constraint fk_rj_bike
		foreign key (bike_code) references bikes(bike_code)
        on update cascade
        on delete restrict,
	constraint fk_rj_customer
		foreign key (customer_cpr) references customers(cpr_number)
        on update cascade
        on delete restrict
);

create table repair_job_parts (
	bike_code int not null, 
    job_datetime datetime not null,
    manufacturer_name varchar(255) not null, 
    part_code varchar(40) not null, 
    quantity int not null check (quantity>0), 
    primary key (bike_code, job_datetime, manufacturer_name, part_code),
    constraint fk_rjp_job
		foreign key(bike_code, job_datetime) references repair_jobs(bike_code, job_datetime)
        on update cascade
        on delete cascade, 
	constraint fk_rjp_part
		foreign key (manufacturer_name, part_code) references parts(manufacturer_name, part_code)
        on update cascade
        on delete cascade
);

insert into manufacturers (manufacturer_name, country) values
('Trek', 'USA'),
('Giant', 'Taiwan'),
('Shimano', 'Japan'),
('Specialized', 'USA'),
('SRAM', 'Germany');

insert into bikes(bike_code, bike_type, speeds, weight_kg, wheel_diameter, manufacturer_name) values
(101, 'Mountain', 21, 13.5, 27.5, 'Trek'),
(106, 'Mountain', 21, 13.5, 29.5, 'Trek'),
(102, 'Road', 18, 9.8, 28.0, 'Giant'),
(103, 'Hybrid', 7, 12.3, 28.0, 'Specialized'),
(104, 'Electric', 10, 22.0, 29.0, 'Trek'),
(105, 'BMX', 1, 11.2, 20.0, 'Giant');

insert into parts (manufacturer_name, part_code, part_description, unit_price) values
('Shimano', 'S001', 'Brake Set', 49.99),
('Shimano', 'S002', 'Gear Shifter', 89.50),
('SRAM', 'SR01', 'Chain', 35.00),
('SRAM', 'SR02', 'Crankset', 120.00),
('Giant', 'G001', 'Handlebar', 45.00),
('Trek', 'T001', 'Seat Post', 55.00),
('Specialized', 'SP01', 'Pedals', 25.00);

insert into compatible_parts(bike_code, manufacturer_name, part_code) values
(101, 'Shimano', 'S001'),
(101, 'SRAM', 'SR01'),
(102, 'Shimano', 'S002'),
(102, 'SRAM', 'SR02'),
(103, 'Specialized', 'SP01'),
(104, 'Trek', 'T001'),
(104, 'SRAM', 'SR02'),
(105, 'SRAM', 'SR01');

insert into customers (cpr_number, full_name, street, city, postal_code, phone, email) values
('111111-1111', 'Alice Jensen', 'Birch Street 5', 'Aarhus', '8000', '22334455', 'alice@mail.com'),
('222222-2222', 'Bob Nielsen', 'Oak Road 12', 'Copenhagen', '2100', '33445566', 'bob@mail.com'),
('333333-3333', 'Clara Pedersen', 'Pine Avenue 8', 'Odense', '5000', '44556677', 'clara@mail.com'),
('444444-4444', 'David Hansen', 'Elm Street 22', 'Aalborg', '9000', '55667788', 'david@mail.com');

insert into owns (cpr_number, bike_code, since_date) values
('111111-1111', 101, '2023-03-01'),
('111111-1111', 104, '2024-06-10'),
('222222-2222', 102, '2022-05-15'),
('333333-3333', 103, '2023-08-01'),
('444444-4444', 105, '2024-01-20');

insert into repair_jobs (bike_code, job_datetime, customer_cpr, duration_min, cost) values
(101, '2024-02-10 09:30:00', '111111-1111', 90, 350.00),
(101, '2025-03-15 10:00:00', '111111-1111', 45, 200.00),
(102, '2024-04-05 14:00:00', '222222-2222', 60, 275.00),
(103, '2025-01-20 11:15:00', '333333-3333', 75, 180.00),
(104, '2024-09-12 16:45:00', '111111-1111', 120, 500.00),
(105, '2025-05-22 13:10:00', '444444-4444', 30, 90.00),
(106, '2025-05-15 10:00:00', '111111-1111', 45, 200.00),
(106, '2025-04-15 10:00:00', '111111-1111', 45, 200.00),
(106, '2025-06-15 10:00:00', '111111-1111', 45, 200.00);

-- We will search for the corresponding parts in the repair_job_parts, a repair job is unique because of its bike and job_datetime 

insert into repair_job_parts (bike_code, job_datetime, manufacturer_name, part_code, quantity) values
(101, '2024-02-10 09:30:00', 'Shimano', 'S001', 2),
(101, '2024-02-10 09:30:00', 'SRAM', 'SR01', 1),
(101, '2025-03-15 10:00:00', 'Shimano', 'S001', 1),
(102, '2024-04-05 14:00:00', 'SRAM', 'SR02', 1),
(103, '2025-01-20 11:15:00', 'Giant', 'G001', 1),
(104, '2024-09-12 16:45:00', 'Trek', 'T001', 2),
(104, '2024-09-12 16:45:00', 'SRAM', 'SR02', 1),
(105, '2025-05-22 13:10:00', 'SRAM', 'SR01', 1);

show tables;
select*from manufacturers;
select*from bikes;
select*from parts;
select*from compatible_parts;
select*from customers;
select*from owns;
select*from repair_jobs;
select*from repair_job_parts;


