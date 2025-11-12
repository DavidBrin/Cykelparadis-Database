USE bikeshop;


DROP FUNCTION IF EXISTS get_repair_parts_cost;
DELIMITER //
CREATE FUNCTION get_repair_parts_cost(
	p_bike_code INT, p_job_datetime DATETIME
) RETURNS DECIMAL(10, 2)

BEGIN
	DECLARE total_parts_cost DECIMAL(10, 2);
    SELECT SUM(p.unit_price * rjp.quantity) INTO 
    total_parts_cost FROM repair_job_parts rjp JOIN parts p
    ON rjp.manufacturer_name = p.manufacturer_name AND rjp.part_code = p.part_code
    WHERE rjp.bike_code = p_bike_code AND rjp.job_datetime = p_job_datetime;
    RETURN total_parts_cost;
END//

DELIMITER ;

SELECT get_repair_parts_cost(101, '2024-02-10 09:30:00');
SELECT get_repair_parts_cost(104, '2024-09-12 16:45:00');

DROP PROCEDURE IF EXISTS add_to_rjp;
DELIMITER //
CREATE PROCEDURE add_to_rjp(
	IN p_part_code VARCHAR(40), IN p_manufacturer_name VARCHAR(255), 
    IN p_quantity INT, IN p_job_datetime DATETIME,
    IN p_bike_code INT
)
BEGIN
	DECLARE compatible INT DEFAULT 0;
    DECLARE row_exists INT DEFAULT 0;
    SELECT COUNT(*) INTO compatible FROM compatible_parts cp WHERE 
    cp.bike_code = p_bike_code AND cp.part_code = p_part_code AND
    cp.manufacturer_name = p_manufacturer_name;
    
    IF compatible > 0 THEN 
		SELECT COUNT(*) INTO row_exists FROM repair_job_parts rjp WHERE
        rjp.bike_code = p_bike_code
		AND rjp.job_datetime = p_job_datetime
		AND rjp.manufacturer_name = p_manufacturer_name
		AND rjp.part_code = p_part_code;
        
        IF row_exists > 0 THEN
			UPDATE repair_job_parts rjp SET rjp.quantity = rjp.quantity + p_quantity
			WHERE rjp.bike_code = p_bike_code 
            AND rjp.job_datetime = p_job_datetime 
            AND rjp.part_code = p_part_code
            AND rjp.manufacturer_name = p_manufacturer_name;
        ELSE 
			INSERT INTO repair_job_parts(
				bike_code,
                job_datetime, 
                manufacturer_name, 
                part_code,
                quantity
            ) VALUES (
				p_bike_code,
                p_job_datetime, 
                p_manufacturer_name, 
                p_part_code,
                p_quantity
            );
        END IF;
    END IF;
END//

DELIMITER ;

SELECT * FROM repair_job_parts;
CALL add_to_rjp('G001', 'Giant', 1, '2025-01-20 11:15:00', '103');
SELECT * FROM repair_job_parts;

CALL add_to_rjp('SP01', 'Specialized', 2, '2025-01-20 11:15:00', '103');
SELECT * FROM repair_job_parts;

CALL add_to_rjp('T001', 'Trek', 1, '2025-01-20 11:15:00', '103');
SELECT * FROM repair_job_parts;


DROP TRIGGER IF EXISTS add_repair_job;
DELIMITER //
CREATE TRIGGER add_repair_job BEFORE INSERT ON repair_jobs
FOR EACH ROW
BEGIN
	IF NEW.duration_min > 4320 OR NEW.cost > 100000 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Error: Repair job cannot exceed 72 hours or 100000 DKK";
	END IF;
END//

DELIMITER ;


-- Query 1
SELECT cpr_number 
FROM customers 
WHERE cpr_number IN (
    SELECT customer_cpr 
    FROM repair_jobs 
    GROUP BY customer_cpr
    HAVING COUNT(*) > 1
);

-- Query 2
SELECT parts.part_code, parts.manufacturer_name 
FROM parts 
LEFT JOIN repair_job_parts
	ON parts.part_code = repair_job_parts.part_code
WHERE repair_job_parts.part_code IS NULL;
-- Reasoning: We join the parts with the repair_job_parts table, on their common part_code, and the rows with a null repair_job_parts.part_code means it is unused

-- Query 3
SELECT part_code, manufacturer_name, SUM(repair_job_parts.quantity) as total_quantity
FROM parts
NATURAL LEFT JOIN repair_job_parts
JOIN repair_jobs
	ON repair_jobs.bike_code = repair_job_parts.bike_code
    AND repair_jobs.job_datetime = repair_job_parts.job_datetime
WHERE YEAR(repair_jobs.job_datetime) = 2024
GROUP BY part_code, manufacturer_name;
-- Reasoning: We first join the parts table and repair_job_parts table and repair_jobs table, this allows to get the job_date from repair_jobs
-- While we can get the quantity of the parts from repair_jobs_parts table
-- 

-- Query 4
-- Count repairs per bikes

SELECT bike_type, bike_code, manufacturer_name FROM
(
    SELECT bikes.bike_type, bikes.bike_code, bikes.manufacturer_name, Count(bikes_repaired.bike_code) as number_of_repairs,
ROW_NUMBER() OVER (PARTITION BY bikes.bike_type ORDER BY Count(bikes_repaired.bike_code) DESC) as row_no
FROM bikes 
 LEFT JOIN repair_jobs bikes_repaired
GROUP BY bikes.bike_code, bikes.bike_type, bikes.manufacturer_name
) ranked_by_repairs
WHERE row_no = 1;
-- Reasoning: We first build a query that can return the type, bike id, manufacturer's name and the number of times a particular bike is repaired
-- Building upon this we then divide the results using a partition based on type, and then order the the bikes in each type partition, ranking them
-- by the number of repairs
-- We then only select the top row from each partition

-- Query 5
SELECT DISTINCT bikes.bike_code, bikes.manufacturer_name 
FROM bikes
WHERE bikes.bike_code NOT IN (
	SELECT compatible_parts.bike_code
	FROM compatible_parts 
	JOIN parts ON compatible_parts.part_code = parts.part_code
    WHERE bikes.manufacturer_name != parts.manufacturer_name
) AND bikes.bike_code IN (
	SELECT bike_code
    FROM compatible_parts
);
-- Reasoning: We look for bike ids which 1. do not have any bike manufacturer being different from the compatible parts manufacturer, as if there
-- is at least 1 compatible part with a different manufacturer, it should not be returned
-- 2. we also ensure that only bike_ids which have any compatible parts are returned, which is the reason for the 2nd condition



SELECT * FROM repair_jobs;
-- Commented those lines since execution will lead to an error
-- INSERT INTO repair_jobs (bike_code, job_datetime, customer_cpr, duration_min, cost)
-- VALUES (102, '2025-11-11 10:00:00', '222222-2222', 5000, 500.00);

INSERT INTO repair_jobs (bike_code, job_datetime, customer_cpr, duration_min, cost)
VALUES (102, '2025-11-11 10:00:00', '222222-2222', 50, 500.00);

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

