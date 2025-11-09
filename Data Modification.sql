USE bikeshop;

INSERT INTO customers VALUES ('555555-5555', 'Watson Smith', 'Bellevue Esplanade', 'Aarhus', '7700', '66778899', 'smith@gmail.com');

INSERT INTO bikes VALUES (106, 'Gravel', 11, 10.2, 28.0, 'Specialized');

INSERT INTO owns VALUES ('555555-5555', 106, '2025-02-10');

INSERT INTO parts VALUES ('Specialized', 'SP02', 'Gravel Tyre', 65.00);

INSERT INTO compatible_parts VALUES (106, 'Specialized', 'SP02');

INSERT INTO repair_jobs VALUES (106,  '2025-03-03 12:00:00', '555555-5555', 45, 150.00);

INSERT INTO repair_job_parts VALUES (
    106,
    '2025-03-03 12:00:00',    
    'Specialized',             
    'SP02',              
    2 	                   
);

INSERT INTO manufacturers (manufacturer_name, country) 
VALUES 
('Ritchey', 'USA');

INSERT INTO parts (manufacturer_name, part_code, part_description, unit_price) 
VALUES 
('Ritchey', 'RCH-01', 'Carbon Seatpost', 110.00);

INSERT INTO compatible_parts VALUES (101, 'Ritchey', 'RCH-01');

UPDATE parts SET unit_price = 50.00 WHERE 
manufacturer_name = 'SRAM' AND part_code = 'SR01';

UPDATE customers SET street = 'New Street 15',
city = 'Copenhagen', postal_code = '7000', phone = '11223344' WHERE
cpr_number = '111111-1111'
; 

UPDATE parts SET unit_price = unit_price * 1.15
WHERE manufacturer_name = 'Shimano';

UPDATE repair_jobs SET job_datetime = '2025-03-16 10:00:00'
WHERE bike_code = 101 AND job_datetime = '2025-03-15 10:00:00';
    
SET SQL_SAFE_UPDATES = 0;
UPDATE repair_jobs rj JOIN bikes b ON 
rj.bike_code = b.bike_code
SET rj.cost = rj.cost + 10.00 WHERE b.bike_type = 'Electric';
SET SQL_SAFE_UPDATES = 1;

DELETE FROM repair_jobs
WHERE bike_code = 105 AND job_datetime = '2025-05-22 13:10:00';

DELETE FROM parts
WHERE manufacturer_name = 'Specialized' AND part_code = 'SP01';

