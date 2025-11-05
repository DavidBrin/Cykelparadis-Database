CREATE DATABASE IF NOT EXISTS bikeshop 
  DEFAULT CHARACTER SET utf8mb4 
  DEFAULT COLLATE utf8mb4_general_ci;
USE bikeshop;

SET foreign_key_checks = 0;

DROP TABLE IF EXISTS repair_job_parts;
DROP TABLE IF EXISTS compatible_parts;
DROP TABLE IF EXISTS repair_jobs;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS parts;
DROP TABLE IF EXISTS bikes;
DROP TABLE IF EXISTS manufacturers;

SET foreign_key_checks = 1;

-- Manufacturers
CREATE TABLE manufacturers (
  manufacturer_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (manufacturer_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bikes
CREATE TABLE bikes (
  bike_id            INT AUTO_INCREMENT PRIMARY KEY,
  manufacturer_name  VARCHAR(255) NULL,
  bike_type          VARCHAR(100),
  speeds             INT,
  weight_kg          DECIMAL(6,2),
  wheel_diameter     DECIMAL(5,2),
  KEY idx_bikes_manufacturer_name (manufacturer_name),
  CONSTRAINT fk_bikes_manufacturer_name
    FOREIGN KEY (manufacturer_name)
    REFERENCES manufacturers (manufacturer_name)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Parts
CREATE TABLE parts (
  manufacturer_name  VARCHAR(255) NOT NULL,
  part_code          VARCHAR(40)  NOT NULL,
  part_description   TEXT,
  price              DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  PRIMARY KEY (manufacturer_name, part_code),
  KEY idx_parts_price (price),
  CONSTRAINT fk_parts_manufacturer_name
    FOREIGN KEY (manufacturer_name)
    REFERENCES manufacturers (manufacturer_name)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Customers
CREATE TABLE customers (
  cpr_number   VARCHAR(20)  PRIMARY KEY,
  email        VARCHAR(254),
  telephone    VARCHAR(40),
  full_name    VARCHAR(255),
  street_name  VARCHAR(255),
  civic_number VARCHAR(50),
  city         VARCHAR(120),
  zip_code     VARCHAR(20),
  country      VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ownership
CREATE TABLE owns (
  cpr_number VARCHAR(20) NOT NULL,
  bike_id    INT NOT NULL,
  since_data DATE NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (bike_id),
  KEY idx_owns_cpr (cpr_number),
  CONSTRAINT fk_owns_customer
    FOREIGN KEY (cpr_number) REFERENCES customers(cpr_number)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_owns_bike
    FOREIGN KEY (bike_id) REFERENCES bikes(bike_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Parts used in a repair 
CREATE TABLE repair_job_parts (
  listid             INT NOT NULL,
  manufacturer_name  VARCHAR(255) NOT NULL,
  part_code          VARCHAR(40)  NOT NULL,
  qty                INT NOT NULL CHECK (qty > 0),
  PRIMARY KEY (listid),
  KEY idx_rjp_part (manufacturer_name, part_code),
  CONSTRAINT fk_rjp_part
    FOREIGN KEY (manufacturer_name, part_code)
    REFERENCES parts(manufacturer_name, part_code)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Repair jobs 
CREATE TABLE repair_jobs (
  job_date     DATE NOT NULL,
  duration_min INT CHECK (duration_min >= 0),
  cost         DECIMAL(10,2) CHECK (cost >= 0),
  customer_cpr VARCHAR(20) NOT NULL,
  bike_id      INT NOT NULL,
  parts_list_id INT,
  KEY idx_rj_customer (customer_cpr),
  KEY idx_rj_bike (bike_id),
  PRIMARY KEY (job_date, customer_cpr, bike_id),
  CONSTRAINT fk_rj_customer_cpr
    FOREIGN KEY (customer_cpr) REFERENCES customers(cpr_number)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rj_bike_id
    FOREIGN KEY (bike_id) REFERENCES bikes(bike_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rj_parts_list_id
	FOREIGN KEY (parts_list_id) REFERENCES repair_job_parts(listid)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Compatibility (parts that fit bikes)
CREATE TABLE compatible_parts (
  bike_id            INT NOT NULL,
  manufacturer_name  VARCHAR(255) NOT NULL,
  part_code          VARCHAR(40)  NOT NULL,
  PRIMARY KEY (bike_id, manufacturer_name, part_code),
  KEY idx_comp_part (manufacturer_name, part_code),
  CONSTRAINT fk_comp_bike
    FOREIGN KEY (bike_id) REFERENCES bikes(bike_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_comp_part
    FOREIGN KEY (manufacturer_name, part_code)
    REFERENCES parts(manufacturer_name, part_code)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data
INSERT INTO customers (cpr_number, email, telephone, full_name, street_name, civic_number, city, zip_code, country)
VALUES
  ('123456-7890', 'john.doe@gmail.com',        '22223333', 'John Doe',         'Elm Street',     '12', 'Copenhagen',   '2100',  'Hovedstaden'),
  ('234567-8901', 'anna.smith@gmail.com',      '33334444', 'Anna Smith',       'Oak Road',       '45', 'Aarhus',       '8000',  'Midtjylland'),
  ('345678-9012', 'mike.jensen@gmail.com',     '44445555', 'Mike Jensen',      'Birch Lane',     '8',  'Odense',       '5000',  'Syddanmark'),
  ('250388-5678', 'sofie_p@mail.com',          '60224466', 'Sofie Petersen',   'Vestergade',     '7',  'Odense',       '5000',  'Syddanmark'),
  ('100795-1234', 'elias.jorgensen@mail.dk',   '50112233', 'Elias Jørgensen',  'Falkoner Allé',  '69', 'Frederiksberg', '2000',  'Hovedstaden'),
  ('011175-9012', 'lars.hansen@email.dk',      '71335577', 'Lars Hansen',      'Fysikvej',       '3',  'Lyngby',       '2800',  'Hovedstaden'),
  ('150600-3456', 'ida.nielsen@post.dk',       '80446688', 'Ida Nielsen',      'Skovvej',        '2',  'Aarhus',       '8000',  'Midtjylland');

INSERT INTO manufacturers (manufacturer_name)
VALUES ('Trek'), ('Giant'), ('Avenue'), ('Kildemose'), ('Batavus'), ('Shimano');

INSERT INTO bikes (bike_id, bike_type, speeds, weight_kg, wheel_diameter, manufacturer_name)
VALUES 
  (001, 'Road',     21,  8.2, 28.0, 'Avenue'),
  (002, 'City',      7, 10.5, 27.5, 'Kildemose'),
  (003, 'Mountain', 18,  9.1, 28.0, 'Trek'),
  (004, 'BMX',       7,  5.3, 20.0, 'Giant'),
  (005, 'Kid',       3,  5.5, 18.0, 'Batavus'),
  (006, 'City',     13, 10.0, 28.0, 'Kildemose'),
  (007, 'Mountain', 21,  8.2, 24.0, 'Batavus');

INSERT INTO parts (part_code, part_description, price, manufacturer_name)
VALUES
  ('P001', 'Brake Pad Set (Hydraulic)', 250, 'Trek'),
  ('P002', '10-Speed Chain',            180, 'Avenue'),
  ('P003', 'Inner Tube',                120, 'Batavus'),
  ('P004', 'Rear Rack (Steel)',         350, 'Kildemose'),
  ('P005', 'Gear Cable',                150, 'Shimano'),
  ('P006', 'Pedal',                     129, 'Shimano'),
  ('P007', 'Handlebar',                 600, 'Giant');

INSERT INTO owns (cpr_number, bike_id)
VALUES
  ('123456-7890', 001),
  ('234567-8901', 002),
  ('345678-9012', 003),
  ('250388-5678', 004),
  ('100795-1234', 005),
  ('011175-9012', 006),
  ('150600-3456', 007);

INSERT INTO repair_job_parts (listid, manufacturer_name, part_code, qty)
VALUES
  (001, 'Trek',      'P001', 2),
  (002, 'Avenue',    'P002', 1),
  (003, 'Batavus',   'P003', 1),
  (004, 'Kildemose', 'P004', 1),
  (005, 'Shimano',   'P005', 3),
  (006, 'Shimano',   'P006', 2),
  (007, 'Giant',     'P007', 1);


-- Use ISO dates and valid days
INSERT INTO repair_jobs (job_date, duration_min, cost, customer_cpr, bike_id, parts_list_id)
VALUES  
  ('2025-04-01',  90, 1450, '123456-7890', 001, 001),
  ('2025-06-30', 120, 1800, '234567-8901', 002, 002),  
  ('2025-09-22',  30,  345, '345678-9012', 003, 003),
  ('2025-08-09', 180, 2547, '250388-5678', 004, 004),
  ('2025-07-25',  60,  780, '100795-1234', 005, 005),
  ('2025-10-03', 150, 1950, '011175-9012', 006, 006),
  ('2025-10-30', 120, 2000, '234567-8901', 002, 002),  
  ('2025-11-03',  90, 1120, '150600-3456', 007, 007);

INSERT INTO compatible_parts (bike_id, manufacturer_name, part_code)
VALUES
  (001, 'Trek',      'P001'),
  (003, 'Avenue',    'P002'),
  (003, 'Batavus',   'P003'),
  (002, 'Kildemose', 'P004'),
  (007, 'Shimano',   'P005'),
  (001, 'Shimano',   'P006'),
  (006, 'Giant',     'P007');

SELECT * FROM compatible_parts;
