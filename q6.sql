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
SELECT parts.part_code, parts.manufacturer_name 
FROM parts 
LEFT JOIN repair_job_parts
	ON parts.part_code = repair_job_parts.part_code
WHERE repair_job_parts.part_code IS NULL;
-- Reasoning: We join the parts with the repair_job_parts table, on their common part_code, and the rows with a null repair_job_parts.part_code means it is unused

// Query 3
SELECT part_code, manufacturer_name, repair_job_parts.quantity as total_quantity
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

// Query 4
// Count repairs per bikes

SELECT bike_type, bike_code, manufacturer_name FROM
(
    SELECT bikes.bike_type, bikes.bike_code, bikes.manufacturer_name, Count(bikes_repaired.bike_code) as number_of_repairs,
ROW_NUMBER() OVER (PARTITION BY bikes.bike_type ORDER BY Count(bikes_repaired.bike_code) DESC) as row_no
FROM bikes 
NATURAL LEFT JOIN repair_jobs bikes_repaired
GROUP BY bikes.bike_code, bikes.bike_type, bikes.manufacturer_name
) ranked_by_repairs
WHERE row_no = 1;
-- Reasoning: We first build a query that can return the type, bike id, manufacturer's name and the number of times a particular bike is repaired
-- Building upon this we then divide the results using a partition based on type, and then order the the bikes in each type partition, ranking them
-- by the number of repairs
-- We then only select the top row from each partition

// Query 5
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
)
-- Reasoning: We look for bike ids which 1. do not have any bike manufacturer being different from the compatible parts manufacturer, as if there
-- is at least 1 compatible part with a different manufacturer, it should not be returned
-- 2. we also ensure that only bike_ids which have any compatible parts are returned, which is the reason for the 2nd condition


