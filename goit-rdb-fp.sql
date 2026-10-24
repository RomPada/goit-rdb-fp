-- TASK 1.

CREATE DATABASE pandemic;
USE pandemic;

SELECT *
FROM infectious_cases
LIMIT 10;


SELECT COUNT(*)
FROM infectious_cases;

-- TASK 2

CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL,
    Code VARCHAR(50)
);

INSERT INTO entities (Entity, Code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

SELECT COUNT(*) FROM entities;
SELECT * FROM entities LIMIT 10;

CREATE TABLE infectious_cases_normalized AS
SELECT
    e.id AS entity_id,
    i.Year,
    i.Number_yaws,
    i.polio_cases,
    i.cases_guinea_worm,
    i.Number_rabies,
    i.Number_malaria,
    i.Number_hiv,
    i.Number_tuberculosis,
    i.Number_smallpox,
    i.Number_cholera_cases
FROM infectious_cases AS i
JOIN entities AS e
    ON i.Entity = e.Entity
    AND (i.Code <=> e.Code);

ALTER TABLE infectious_cases_normalized
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST,
ADD CONSTRAINT fk_entity
    FOREIGN KEY (entity_id)
    REFERENCES entities(id),
ADD CONSTRAINT uq_entity_year
    UNIQUE (entity_id, Year);

SELECT
    (SELECT COUNT(*) FROM infectious_cases) AS original_count,
    (SELECT COUNT(*) FROM entities) AS entities_count,
    (SELECT COUNT(*) FROM infectious_cases_normalized) AS normalized_count;

SELECT
    e.Entity,
    e.Code,
    n.Year,
    n.Number_rabies
FROM infectious_cases_normalized AS n
JOIN entities AS e
    ON n.entity_id = e.id
LIMIT 10;

-- TASK 3

SELECT
    e.Entity,
    e.Code,
    AVG(CAST(n.Number_rabies AS DECIMAL(20,12))) AS avg_rabies,
    MIN(CAST(n.Number_rabies AS DECIMAL(20,12))) AS min_rabies,
    MAX(CAST(n.Number_rabies AS DECIMAL(20,12))) AS max_rabies,
    SUM(CAST(n.Number_rabies AS DECIMAL(20,12))) AS sum_rabies
FROM infectious_cases_normalized AS n
JOIN entities AS e
    ON n.entity_id = e.id
WHERE n.Number_rabies IS NOT NULL
    AND TRIM(n.Number_rabies) <> ''
GROUP BY e.id, e.Entity, e.Code
ORDER BY avg_rabies DESC
LIMIT 10;

-- TASK 4

SELECT
    Year,
    MAKEDATE(Year, 1) AS year_start_date,
    CURDATE() AS current_date_value,
    TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(Year, 1),
        CURDATE()
    ) AS years_difference
FROM infectious_cases_normalized;

-- TASK 5

DROP FUNCTION IF EXISTS years_since;

DELIMITER $$

CREATE FUNCTION years_since(input_year INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(input_year, 1),
        CURDATE()
    );
END$$

DELIMITER ;

SELECT years_since(1996) AS years_difference;

SELECT
    Year,
    MAKEDATE(Year, 1) AS year_start_date,
    CURDATE() AS current_date_value,
    years_since(Year) AS years_difference
FROM infectious_cases_normalized
LIMIT 10;
