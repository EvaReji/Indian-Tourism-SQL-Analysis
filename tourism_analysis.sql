-- Project: Indian Tourism Analysis 2025
-- Author: Eva Reji
-- Tools: MySQL

-- Step 1: Create Database
CREATE DATABASE India_Tourism_2025;
USE India_Tourism_2025;



-- Step 2: Create Raw Table

CREATE TABLE Tourism_Raw (
    State VARCHAR(100),
    Month VARCHAR(20),
    Date DATE,
    Month_Number INT,
    Domestic_Tourists BIGINT,
    Foreign_Tourists BIGINT,
    Total_Tourists BIGINT,
    Tourism_Revenue DECIMAL(10,2),
    Revenue_Per_Tourist DECIMAL(10,2),
    Domestic_Spend_Per_Person_Crore DECIMAL(12,10),
    Foreign_Spend_Per_Person_Crore DECIMAL(12,10),
    Est_Domestic_Revenue_Crore DECIMAL(10,2),
    Est_Foreign_Revenue_Crore DECIMAL(10,2),
    Domestic_Revenue_Percent DECIMAL(5,2),
    Foreign_Revenue_Percent DECIMAL(5,2),
    Annual_Avg_Revenue DECIMAL(10,2),
    Seasonality_Index DECIMAL(10,2),
    Seasonality_Ratio DECIMAL(10,2),
    Purpose_of_Visit VARCHAR(50),
    Growth_Percent DECIMAL(5,2)
);

-- Step 3: Import CSV Data

-- Step 4: Verify Import
SELECT COUNT(*) FROM Tourism_Raw;
SELECT * FROM Tourism_Raw LIMIT 10;

-- Step 5: Create States Table
CREATE TABLE States (
    state_id INT PRIMARY KEY AUTO_INCREMENT,
    state_name VARCHAR(100) UNIQUE
);

-- Step 6: Create Calendar Table
CREATE TABLE Calendar (
    calendar_id INT PRIMARY KEY AUTO_INCREMENT,
    month_name VARCHAR(20),
    month_number INT,
    date DATE
);

-- Step 7: Create Tourism_Purpose Table
CREATE TABLE Tourism_Purpose (
    purpose_id INT PRIMARY KEY AUTO_INCREMENT,
    purpose_name VARCHAR(50)
);

-- Step 8: Create Fact Table (Tourism_Stats)
CREATE TABLE Tourism_Stats (
    stat_id INT PRIMARY KEY AUTO_INCREMENT,
    state_id INT,
    calendar_id INT,
    purpose_id INT,
    domestic_tourists BIGINT,
    foreign_tourists BIGINT,
    total_tourists BIGINT,
    tourism_revenue DECIMAL(10,2),
    revenue_per_tourist DECIMAL(10,2),
    domestic_spend_per_person DECIMAL(12,10),
    foreign_spend_per_person DECIMAL(12,10),
    est_domestic_revenue DECIMAL(10,2),
    est_foreign_revenue DECIMAL(10,2),
    domestic_revenue_percent DECIMAL(5,2),
    foreign_revenue_percent DECIMAL(5,2),
    annual_avg_revenue DECIMAL(10,2),
    seasonality_index DECIMAL(10,2),
    seasonality_ratio DECIMAL(10,2),
    growth_percent DECIMAL(5,2),
    FOREIGN KEY (state_id) REFERENCES States(state_id),
    FOREIGN KEY (calendar_id) REFERENCES Calendar(calendar_id),
    FOREIGN KEY (purpose_id) REFERENCES Tourism_Purpose(purpose_id)
);

-- Step 9: Populate States Table
INSERT INTO States (state_name)
SELECT DISTINCT State FROM Tourism_Raw;

-- Step 10: Populate Calendar Table
INSERT INTO Calendar (month_name, month_number, date)
SELECT DISTINCT Month, Month_Number, Date FROM Tourism_Raw;

-- Step 11: Populate Tourism_Purpose Table
INSERT INTO Tourism_Purpose (purpose_name)
SELECT DISTINCT Purpose_of_Visit FROM Tourism_Raw;

-- Step 12: Populate Fact Table (Tourism_Stats)
INSERT INTO Tourism_Stats (
    state_id, calendar_id, purpose_id,
    domestic_tourists, foreign_tourists, total_tourists,
    tourism_revenue, revenue_per_tourist,
    domestic_spend_per_person, foreign_spend_per_person,
    est_domestic_revenue, est_foreign_revenue,
    domestic_revenue_percent, foreign_revenue_percent,
    annual_avg_revenue, seasonality_index, seasonality_ratio,
    growth_percent
)
SELECT s.state_id, c.calendar_id, p.purpose_id,
       r.Domestic_Tourists, r.Foreign_Tourists, r.Total_Tourists,
       r.Tourism_Revenue, r.Revenue_Per_Tourist,
       r.Domestic_Spend_Per_Person_Crore, r.Foreign_Spend_Per_Person_Crore,
       r.Est_Domestic_Revenue_Crore, r.Est_Foreign_Revenue_Crore,
       r.Domestic_Revenue_Percent, r.Foreign_Revenue_Percent,
       r.Annual_Avg_Revenue, r.Seasonality_Index, r.Seasonality_Ratio,
       r.Growth_Percent
FROM Tourism_Raw r
JOIN States s ON r.State = s.state_name
JOIN Calendar c ON r.Month = c.month_name AND r.Date = c.date
JOIN Tourism_Purpose p ON r.Purpose_of_Visit = p.purpose_name;


-- Verify row count
SELECT COUNT(*) FROM Tourism_Stats;

-- Preview first 10 rows
SELECT * FROM Tourism_Stats LIMIT 10;

SELECT * FROM Tourism_stats;

-- Query 1: Check Duplicates
SELECT State, Date, COUNT(*)
FROM Tourism_Raw
GROUP BY State, Date
HAVING COUNT(*) > 1;

-- Query 2: Check NULL Values
SELECT *
FROM Tourism_Raw
WHERE Domestic_Tourists IS NULL
   OR Foreign_Tourists IS NULL
   OR Tourism_Revenue IS NULL;
   
-- Query 3: Add Indexes
CREATE INDEX idx_state ON Tourism_Stats(state_id);
CREATE INDEX idx_calendar ON Tourism_Stats(calendar_id);
CREATE INDEX idx_purpose ON Tourism_Stats(purpose_id);

-- Query 4: List all states
SELECT state_name FROM States;

-- Query 5: Show all months with their number
SELECT month_name, month_number FROM Calendar;

-- Query 6: Count total records in Tourism_Stats
SELECT COUNT(*) AS total_records FROM Tourism_Stats;

-- Query 7: Find total tourists grouped by state
SELECT s.state_name, SUM(ts.total_tourists) AS total_tourists
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
ORDER BY total_tourists DESC;

-- Query 8: Show tourism revenue grouped by purpose of visit
SELECT p.purpose_name, SUM(ts.tourism_revenue) AS total_revenue
FROM Tourism_Stats ts
INNER JOIN Tourism_Purpose p ON ts.purpose_id = p.purpose_id
GROUP BY p.purpose_name
ORDER BY total_revenue DESC;

-- Query 9: States with total tourism revenue greater than 4000
SELECT s.state_name, SUM(ts.tourism_revenue) AS total_revenue
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
HAVING SUM(ts.tourism_revenue) > 4000
ORDER BY total_revenue DESC;

-- Query 10: Top 5 states ranked by foreign tourists 
SELECT s.state_name, SUM(ts.foreign_tourists) AS total_foreign
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
ORDER BY total_foreign DESC
LIMIT 5;

-- Query 11: Show the 6th to 10th states ranked by tourism revenue
SELECT s.state_name, SUM(ts.tourism_revenue) AS total_revenue
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
ORDER BY total_revenue DESC
LIMIT 5 OFFSET 5;

-- Query 12: Find states whose names start with 'K'
SELECT state_name
FROM States
WHERE state_name LIKE 'K%';

-- Query 13: Average revenue per tourist grouped by purpose 
SELECT p.purpose_name, AVG(ts.revenue_per_tourist) AS avg_revenue_per_tourist
FROM Tourism_Stats ts
INNER JOIN Tourism_Purpose p ON ts.purpose_id = p.purpose_id
GROUP BY p.purpose_name;

-- Query 14: Rank states by domestic tourists 
SELECT s.state_name,
       SUM(ts.domestic_tourists) AS total_domestic,
       RANK() OVER (ORDER BY SUM(ts.domestic_tourists) DESC) AS rank_domestic
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name;





-- Query 15: Monthly growth percent for each state
SELECT state_name, month_name,
       total_tourists,
       LAG(total_tourists) OVER (PARTITION BY state_name ORDER BY month_number) AS prev,
       ROUND(
           (total_tourists - LAG(total_tourists) OVER (PARTITION BY state_name ORDER BY month_number))
           * 100.0 /
           LAG(total_tourists) OVER (PARTITION BY state_name ORDER BY month_number),
       2) AS growth_percent
FROM (
    SELECT s.state_name, c.month_name, c.month_number,
           SUM(ts.total_tourists) AS total_tourists
    FROM Tourism_Stats ts
    JOIN States s ON ts.state_id = s.state_id
    JOIN Calendar c ON ts.calendar_id = c.calendar_id
    GROUP BY s.state_name, c.month_name, c.month_number
) t;

-- Query 16: Show all states even if no stats 
SELECT s.state_name, COALESCE(SUM(ts.total_tourists),0) AS total_tourists
FROM States s
LEFT JOIN Tourism_Stats ts ON s.state_id = ts.state_id
GROUP BY s.state_name;

-- Query 17: Show all purposes even if no stats 
SELECT p.purpose_name, COALESCE(SUM(ts.total_tourists),0) AS total_tourists
FROM Tourism_Purpose p
LEFT JOIN Tourism_Stats ts ON p.purpose_id = ts.purpose_id
GROUP BY p.purpose_name;

-- Query 18: Show all months even if no stats (RIGHT JOIN)
SELECT c.month_name, COALESCE(SUM(ts.total_tourists),0) AS total_tourists
FROM Tourism_Stats ts
RIGHT JOIN Calendar c ON ts.calendar_id = c.calendar_id
GROUP BY c.month_name;

-- Query 19: Show all states with average revenue
SELECT s.state_name, COALESCE(AVG(ts.tourism_revenue),0) AS avg_revenue
FROM Tourism_Stats ts
RIGHT JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name;

-- Query 20: Show all combinations of states and purposes 
SELECT s.state_name, p.purpose_name
FROM States s
CROSS JOIN Tourism_Purpose p;

-- Query 21: Find states with similar name length
SELECT a.state_name AS state1, b.state_name AS state2
FROM States a
JOIN States b ON LENGTH(a.state_name) = LENGTH(b.state_name)
WHERE a.state_id <> b.state_id;

-- Query 22: Combine domestic and foreign tourist totals 
SELECT 'Domestic' AS category, SUM(domestic_tourists) AS total
FROM Tourism_Stats
UNION ALL
SELECT 'Foreign', SUM(foreign_tourists)
FROM Tourism_Stats;

-- Query 23: Find states whose total tourists are above the overall average 
SELECT s.state_name, SUM(ts.total_tourists) AS total_tourists
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
HAVING SUM(ts.total_tourists) > (
    SELECT AVG(total_tourists)
    FROM (
        SELECT SUM(total_tourists) AS total_tourists
        FROM Tourism_Stats
        GROUP BY state_id
    ) AS sub
);

-- Query 24: Find the state(s) with the maximum tourism revenue (Subquery)
SELECT s.state_name, SUM(ts.tourism_revenue) AS total_revenue
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
HAVING SUM(ts.tourism_revenue) = (
    SELECT MAX(total_revenue)
    FROM (
        SELECT SUM(tourism_revenue) AS total_revenue
        FROM Tourism_Stats
        GROUP BY state_id
    ) AS sub
);

-- Query 25: Show states in uppercase 
SELECT UPPER(state_name) AS state_upper FROM States;

-- Query 26: Row number for states by revenue 
SELECT s.state_name,
       SUM(ts.tourism_revenue) AS total_revenue,
       ROW_NUMBER() OVER (ORDER BY SUM(ts.tourism_revenue) DESC) AS row_num
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name;

-- Query 27: Find states that have at least one month with more than 1 million tourists
SELECT s.state_name
FROM States s
WHERE EXISTS (
    SELECT 1
    FROM Tourism_Stats ts
    WHERE ts.state_id = s.state_id
    AND ts.total_tourists > 1000000
);

-- Query 28: Show month-to-month change in total tourists
SELECT month_name,
       total_tourists,
       LAG(total_tourists) OVER (ORDER BY month_number) AS prev_month_tourists
FROM (
    SELECT c.month_name, c.month_number,
           SUM(ts.total_tourists) AS total_tourists
    FROM Tourism_Stats ts
    JOIN Calendar c ON ts.calendar_id = c.calendar_id
    GROUP BY c.month_name, c.month_number
) t
ORDER BY month_number;

-- Query 29: Find tourist stats for specific states (Kerala, Karnataka, Tamil Nadu)
SELECT s.state_name, SUM(ts.total_tourists) AS total_tourists
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
WHERE s.state_name IN ('Kerala', 'Karnataka', 'Tamil Nadu')
GROUP BY s.state_name;

-- Query 30: Categorize states by tourism revenue
-- Query (CASE WHEN): Categorize states by tourism revenue
SELECT s.state_name,
       SUM(ts.tourism_revenue) AS total_revenue,
       CASE
         WHEN SUM(ts.tourism_revenue) >= 5000 THEN 'High Revenue'
         WHEN SUM(ts.tourism_revenue) BETWEEN 4000 AND 4999 THEN 'Medium Revenue'
         ELSE 'Low Revenue'
       END AS revenue_category
FROM Tourism_Stats ts
INNER JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
ORDER BY total_revenue DESC;

-- Query 31: Top State per Month
SELECT month_name, state_name, total_tourists
FROM (
    SELECT c.month_name, s.state_name,
           SUM(ts.total_tourists) AS total_tourists,
           RANK() OVER (PARTITION BY c.month_name ORDER BY SUM(ts.total_tourists) DESC) AS rank_
    FROM Tourism_Stats ts
    JOIN States s ON ts.state_id = s.state_id
    JOIN Calendar c ON ts.calendar_id = c.calendar_id
    GROUP BY c.month_name, s.state_name
) t
WHERE rank_ = 1;

-- Query 32: Contribution % by State
SELECT s.state_name,
       SUM(ts.total_tourists) AS total,
       ROUND(
    SUM(ts.total_tourists) * 100.0 / 
    (SELECT SUM(total_tourists) FROM Tourism_Stats)
, 2) AS contribution_percent
FROM Tourism_Stats ts
JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
ORDER BY contribution_percent DESC;

-- Query 33: Find Peak Tourism Month
SELECT month_name, total_tourists
FROM (
    SELECT c.month_name,
           SUM(ts.total_tourists) AS total_tourists,
           RANK() OVER (ORDER BY SUM(ts.total_tourists) DESC) AS rank_
    FROM Tourism_Stats ts
    JOIN Calendar c ON ts.calendar_id = c.calendar_id
    GROUP BY c.month_name
) t
WHERE rank_ = 1;

-- Query 34: Domestic vs Foreign Tourists Comparison
SELECT 
    SUM(domestic_tourists) AS total_domestic,
    SUM(foreign_tourists) AS total_foreign
FROM Tourism_Stats;

-- Query 35: Seasonality Analysis
SELECT s.state_name,
       AVG(ts.seasonality_index) AS avg_seasonality
FROM Tourism_Stats ts
JOIN States s ON ts.state_id = s.state_id
GROUP BY s.state_name
ORDER BY avg_seasonality DESC;
