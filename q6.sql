// Query 1
SELECT cpr_number 
FROM customers 
WHERE cpr_number IN (
    SELECT customer_cpr 
    FROM repair_jobs 
    GROUP BY customer_cpr
    HAVING COUNT(*) > 1
);

// Query 2
SELECT parts.partcode, manufacturer_name 
FROM parts 
LEFT JOIN repair_job_parts part_codes_used
ON parts.partcode = repair_job_parts.partcode
WHERE part_codes_used IS NULL;

// Query 3
SELECT partcode, manufacturer_name, 
COUNT(pu.partcode) as total_quantity
FROM parts
NATURAL LEFT JOIN repair_job_parts pu
WHERE YEAR(pu.DATE) = 2024
GROUP BY partcode, manufacturer_name;

// Query 4
// Count repairs per bikes

SELECT Type, bike_id, manufacturer_name FROM
(
    SELECT bikes.bike_type, bikes.bike_id, bikes.manufacturer_name, Count(bikes_repaired.bike_id) as number_of_repairs,
ROW_NUMBER() OVER (PARTITION BY bikes.Type ORDER BY Count(bikes_repaired.bike_id) DESC) as row_no
FROM bikes 
NATURAL LEFT JOIN repair_jobs bikes_repaired
GROUP BY bikes.bike_id, bikes.Type, bikes.manufacturer_name
) ranked_by_repairs
WHERE row_no = 1;


// Query 5
SELECT DISTINCT bike_id, manufacturer_name 
FROM compatible 
JOIN bikes on compatible.bike_id = bikes.bike_id
JOIN parts ON compatible_parts.partcode = parts.partcode
WHERE bikes.manufacturer_name = parts.manufacturer_name



