-- Insert a new customer
INSERT Customer VALUES ('1230450697', 'testdummy@hotmail.com', '+45 99 23 44 02', 'Tester Dumminus');

-- Insert a new Bike
INSERT Bike VALUES ('B008', 'Mountin', '3', '6.5', '26');

-- Insert a new Repair Job
INSERT Repair Jobs VALUES ('1/12/2026', '2', '1500', '1230450697', 'B008', 'P008', '5');

-- Insert new Parts Used for the Repair Job
INSERT Parts Used VALUES ('P008', 'P108'),
                         ('P008', 'P103'),
                         ('P008', 'P102'),
                         ('P008', 'P109'),
                         ('P008', 'P101');

-- Insert a new Part
INSERT Parts VALUES ('P108', 'Front Basket', '200', 'Kildemose');

INSERT Owns VALUES ('1230450697', 'B008');

INSERT Compatible VALUES ('P108', 'B008');

-- Update the customer's email address
UPDATE Customer 
SET email = 'tester.dumminus@gmail.com' 
WHERE customer_id = '1230450697';

-- Update the repair job cost
UPDATE Repair_Jobs 
SET cost = '1650' 
WHERE repair_id = 'P008';

-- Update the part price
UPDATE Parts 
SET price = '225' 
WHERE part_id = 'P108';

-- Delete the part 
DELETE FROM Parts 
WHERE part_id = 'P108';