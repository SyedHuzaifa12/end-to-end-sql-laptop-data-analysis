-- View complete dataset
SELECT * FROM laptops;

--------------------------------------------------
-- 1. Head, Tail, and Random Sample
--------------------------------------------------

-- Head: First 5 records based on index
SELECT * FROM laptops
ORDER BY `index`
LIMIT 5;

-- Tail: Last 5 records based on index
SELECT * FROM laptops
ORDER BY `index` DESC
LIMIT 5;

-- Random sample of 5 records
SELECT * FROM laptops
ORDER BY RAND()
LIMIT 5;

--------------------------------------------------
-- 2. Numerical Columns Analysis (Price)
--------------------------------------------------

-- 8-number summary: count, min, max, mean, std, Q1, median, Q3
SELECT
    COUNT(Price) OVER() AS count_,
    MIN(Price) OVER() AS min_,
    MAX(Price) OVER() AS max_,
    AVG(Price) OVER() AS mean_,
    STD(Price) OVER() AS std_,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price) OVER() AS Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Price) OVER() AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) OVER() AS Q3
FROM laptops
ORDER BY `index`
LIMIT 1;

-- Missing values in Price column
SELECT COUNT(*) AS missing_price_count
FROM laptops
WHERE Price IS NULL;

-- Outlier detection using IQR method
SELECT *
FROM (
    SELECT *,
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price) OVER() AS Q1,
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) OVER() AS Q3
    FROM laptops
) t
WHERE Price < Q1 - 1.5 * (Q3 - Q1)
   OR Price > Q3 + 1.5 * (Q3 - Q1);

-- Histogram-style bucket distribution for Price
SELECT bucket, REPEAT('*', COUNT(*) / 5) AS frequency
FROM (
    SELECT Price,
           CASE
               WHEN Price BETWEEN 0 AND 25000 THEN '0–25K'
               WHEN Price BETWEEN 25001 AND 50000 THEN '25K–50K'
               WHEN Price BETWEEN 50001 AND 75000 THEN '50K–75K'
               WHEN Price BETWEEN 75001 AND 100000 THEN '75K–100K'
               ELSE '>100K'
           END AS bucket
    FROM laptops
) t
GROUP BY bucket;

--------------------------------------------------
-- 3. Categorical Columns Analysis
--------------------------------------------------

-- Value counts for Company (categorical distribution)
SELECT Company, COUNT(*) AS count_
FROM laptops
GROUP BY Company;

-- Missing values in categorical columns
SELECT COUNT(*) AS missing_company
FROM laptops
WHERE Company IS NULL;

--------------------------------------------------
-- 4. Numerical–Numerical Analysis
--------------------------------------------------

-- Numerical relationship between CPU speed and Price
SELECT cpu_speed, Price
FROM laptops;

-- Correlation analysis (manual inspection via scatter-style output)
SELECT resolution_width, resolution_height, Price
FROM laptops;

--------------------------------------------------
-- 5. Categorical–Categorical Analysis
--------------------------------------------------

-- Contingency table: Company vs Touchscreen availability
SELECT Company,
       SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS touchscreen_yes,
       SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS touchscreen_no
FROM laptops
GROUP BY Company;

-- Contingency table: Company vs CPU brand
SELECT Company,
       SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS intel,
       SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS amd,
       SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS samsung
FROM laptops
GROUP BY Company;

--------------------------------------------------
-- 6. Numerical–Categorical Analysis
--------------------------------------------------

-- Compare price distribution across companies
SELECT Company,
       MIN(Price) AS min_price,
       MAX(Price) AS max_price,
       AVG(Price) AS avg_price,
       STD(Price) AS std_price
FROM laptops
GROUP BY Company;

--------------------------------------------------
-- 8. Missing Value Treatment
--------------------------------------------------

-- Identify rows with missing price
SELECT * FROM laptops
WHERE Price IS NULL;

-- Replace missing price with overall mean
UPDATE laptops
SET Price = (SELECT AVG(Price) FROM laptops)
WHERE Price IS NULL;

-- Replace missing price with company-wise mean
UPDATE laptops l1
SET Price = (
    SELECT AVG(Price)
    FROM laptops l2
    WHERE l2.Company = l1.Company
)
WHERE l1.Price IS NULL;

--------------------------------------------------
-- 9. Feature Engineering
--------------------------------------------------

-- Create Pixels Per Inch (PPI) feature
ALTER TABLE laptops ADD COLUMN ppi INT;

UPDATE laptops
SET ppi = ROUND(
    SQRT(resolution_width * resolution_width +
         resolution_height * resolution_height) / Inches
);

-- Create screen size category feature
ALTER TABLE laptops ADD COLUMN screen_size VARCHAR(255) AFTER Inches;

UPDATE laptops
SET screen_size =
CASE
    WHEN Inches < 14 THEN 'small'
    WHEN Inches >= 14 AND Inches < 17 THEN 'medium'
    ELSE 'large'
END;

-- Analyze price by screen size category
SELECT screen_size, AVG(Price) AS avg_price
FROM laptops
GROUP BY screen_size;

--------------------------------------------------
-- 10. One-Hot Encoding (GPU Brand)
--------------------------------------------------

-- One-hot encoded representation of GPU brands
SELECT gpu_brand,
       CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS intel,
       CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS amd,
       CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS nvidia,
       CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0 END AS arm
FROM laptops;
