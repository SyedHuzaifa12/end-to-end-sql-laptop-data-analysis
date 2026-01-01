SELECT * FROM laptops;

-- Create a backup table to preserve the original data
CREATE TABLE laptops_backup LIKE laptops;

-- Insert all records into the backup table
INSERT INTO laptops_backup
SELECT * FROM laptops;

-- Check memory consumption for reference
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sql_cx_live'
AND TABLE_NAME = 'laptops';

-- Drop non important columns
ALTER TABLE laptops DROP COLUMN `Unnamed: 0`;

-- Drop null values
DELETE FROM laptops
WHERE `index` IN (SELECT `index` FROM laptops
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL
AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND
WEIGHT IS NULL AND Price IS NULL);

-- Drop Duplicates
DELETE FROM laptops
WHERE (Company, TypeName, Inches, ScreenResolution, Cpu, Ram,
       Memory, Gpu, OpSys, Weight, Price) IN (
    SELECT * FROM (
        SELECT Company, TypeName, Inches, ScreenResolution, Cpu, Ram,
               Memory, Gpu, OpSys, Weight, Price
        FROM laptops
        GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram,
                 Memory, Gpu, OpSys, Weight, Price
        HAVING COUNT(*) > 1
    ) t
);

-- Reduce the Inches column to a single decimal precision
ALTER TABLE laptops MODIFY COLUMN Inches DECIMAL(10,1);

# Ram Memory Update:
-- Description: Updating the `ram_memory` column in the `laptops` table by replacing 'GB' in the `Ram` column.
UPDATE laptops
SET Ram = REPLACE(Ram, 'GB', '');

-- Convert Ram column data type from VARCHAR to INTEGER
ALTER TABLE laptops MODIFY COLUMN Ram INTEGER;

# Weight Update:
-- Description: Updating the `weight` column in the `laptopsdata` table by replacing 'kg' in the `Weight` column.
UPDATE laptops
SET weight = REPLACE(Weight, 'kg', '');

# Price Update:
-- Description: Updating the `price` column in the `laptopsdata` table by rounding the `Price` column.
UPDATE laptops
SET price = ROUND(Price);

-- Converting 'Price' column datatype from varchar to integer
ALTER TABLE laptops MODIFY COLUMN Price INTEGER;

-- Standardize operating system values for consistency
UPDATE laptops
SET OpSys =
CASE
WHEN OpSys LIKE '%mac%' THEN 'macos'
WHEN OpSys LIKE 'windows%' THEN 'windows'
WHEN OpSys LIKE '%linux%' THEN 'linux'
WHEN OpSys = 'No OS' THEN 'N/A'
ELSE 'other'
END;

-- Create gpu_brand and gpu_name columns by splitting GPU information
ALTER TABLE laptops
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

# GPU Name & GPU Brand Update:
-- Updating the `gpu_brand` column in the `laptopsdata` table by removing the `gpu_name` from the `Gpu` column.
UPDATE laptops
SET gpu_brand = SUBSTRING_INDEX(Gpu, ' ', 1);

-- Updating the `gpu_name` column in the `laptopsdata` table by removing the `gpu_brand` from the `Gpu` column.
UPDATE laptops
SET gpu_name = REPLACE(Gpu, gpu_brand, '');

-- Remove the original Gpu column after extraction
ALTER TABLE laptops DROP COLUMN Gpu;

-- Create cpu_brand, cpu_name, and cpu_speed columns for CPU feature extraction
ALTER TABLE laptops
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

SELECT * FROM laptops;

# CPU Brand Update:
-- Updating the `cpu_brand` column in the `laptopsdata` table by extracting the brand from the `Cpu` column.
UPDATE laptops
SET cpu_brand = SUBSTRING_INDEX(Cpu, ' ', 1);

-- Updating the `cpu_speed` column in the `laptopsdata` table by extracting the brand from the `Cpu` column.
UPDATE laptops
SET cpu_speed = CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '') AS
DECIMAL(10,2));

-- Updating the `cpu_name` column in the `laptopsdata` table by extracting the brand from the `Cpu` column.
UPDATE laptops
SET cpu_name = REPLACE(REPLACE(Cpu, cpu_brand, ''),
SUBSTRING_INDEX(REPLACE(Cpu, cpu_brand, ''), ' ', -1), '');

-- Drop the original Cpu column after feature extraction
ALTER TABLE laptops DROP COLUMN Cpu;

-- Create resolution_width and resolution_height columns from ScreenResolution
ALTER TABLE laptops
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

SELECT * FROM laptops;

-- Split screen resolution into width and height values
UPDATE laptops
SET
    resolution_width  = CAST(SUBSTRING_INDEX(REGEXP_SUBSTR(ScreenResolution, '[0-9]+x[0-9]+'), 'x', 1) AS UNSIGNED),
    resolution_height = CAST(SUBSTRING_INDEX(REGEXP_SUBSTR(ScreenResolution, '[0-9]+x[0-9]+'), 'x', -1) AS UNSIGNED)
WHERE ScreenResolution REGEXP '[0-9]+x[0-9]+';

-- Add touchscreen column to identify touch-enabled displays
ALTER TABLE laptops
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

SELECT ScreenResolution LIKE '%Touch%' FROM laptops;

-- Update touchscreen column based on ScreenResolution text
UPDATE laptops
SET touchscreen = ScreenResolution LIKE '%Touch%';

SELECT * FROM laptops

-- Remove ScreenResolution column after extracting features
ALTER TABLE laptops
DROP COLUMN ScreenResolution;

SELECT * FROM laptops;

-- Standardize cpu_name values by keeping only the main identifier
UPDATE laptops
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

SELECT DISTINCT cpu_name FROM laptops;

SELECT Memory FROM laptops;

-- Create memory_type, primary_storage, and secondary_storage columns
ALTER TABLE laptops
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

-- Categorize memory configurations (SSD, HDD, Hybrid, etc.)
SELECT Memory,
CASE
WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
WHEN Memory LIKE '%SSD%' THEN 'SSD'
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
ELSE NULL
END AS 'memory_type'
FROM laptops;

-- Update memory_type column based on Memory values
UPDATE laptops
SET memory_type = CASE
WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
WHEN Memory LIKE '%SSD%' THEN 'SSD'
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
ELSE NULL
END;

-- Extract primary and secondary storage values from Memory column
SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptops;

-- Update primary_storage and secondary_storage columns
UPDATE laptops
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;
 
-- Normalize storage values by converting TB to GB where required
SELECT
primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE
secondary_storage END
FROM laptops;

-- Apply normalized storage values to the table
UPDATE laptops
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE
primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024
ELSE secondary_storage END;

-- Drop gpu_name column as it is no longer required
ALTER TABLE laptops DROP COLUMN gpu_name;

SELECT * FROM laptops;
