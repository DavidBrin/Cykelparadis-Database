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
	IF NEW.duration_min >= 4320 OR NEW.cost > 100000 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Error: Repair job cannot exceed 72 hours or 100000 DKK";
	END IF;
END//

DELIMITER ;

SELECT * FROM repair_jobs;
INSERT INTO repair_jobs (bike_code, job_datetime, customer_cpr, duration_min, cost)
VALUES (102, '2025-11-11 10:00:00', '222222-2222', 5000, 500.00);

INSERT INTO repair_jobs (bike_code, job_datetime, customer_cpr, duration_min, cost)
VALUES (102, '2025-11-11 10:00:00', '222222-2222', 50, 500.00);

SELECT * FROM repair_jobs;
