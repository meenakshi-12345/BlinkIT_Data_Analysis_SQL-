/* =====================================================
   Project: BlinkIT Sales Data Analysis
   Author: Millie
   Description: SQL queries for data cleaning, KPI
                calculation, and business analysis
   ===================================================== */


/* =====================================================
   1. VIEW DATA & BASIC VALIDATION
   ===================================================== */

-- View all records
SELECT *
FROM BlinkIT_data;

-- Count total rows to ensure full data import
SELECT COUNT(*) AS total_records
FROM BlinkIT_data;


/* =====================================================
   2. DATA CLEANING
   ===================================================== */

-- Standardizing Item_Fat_Content values
-- LF, low fat  -> Low Fat
-- reg          -> Regular

UPDATE BlinkIT_data
SET Item_Fat_Content =
    CASE
        WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;

-- Verify cleaning
SELECT DISTINCT Item_Fat_Content
FROM BlinkIT_data;


/* =====================================================
   3. KPI METRICS
   ===================================================== */

-- 3.1 Total Sales (in Millions)
SELECT
    CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Millions
FROM BlinkIT_data;

-- 3.2 Average Sales
SELECT
    CAST(AVG(Total_Sales) AS INT) AS Avg_Sales
FROM BlinkIT_data;

-- 3.3 Number of Items
SELECT
    COUNT(*) AS Total_Items
FROM BlinkIT_data;

-- 3.4 Average Rating
SELECT
    CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating
FROM BlinkIT_data;


/* =====================================================
   4. SALES ANALYSIS
   ===================================================== */

-- 4.1 Total Sales by Fat Content
SELECT
    Item_Fat_Content,
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM BlinkIT_data
GROUP BY Item_Fat_Content;


-- 4.2 Total Sales by Item Type
SELECT
    Item_Type,
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM BlinkIT_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;


-- 4.3 Fat Content by Outlet Location (Pivot)
SELECT
    Outlet_Location_Type,
    ISNULL([Low Fat], 0) AS Low_Fat_Sales,
    ISNULL([Regular], 0) AS Regular_Sales
FROM
(
    SELECT
        Outlet_Location_Type,
        Item_Fat_Content,
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM BlinkIT_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT
(
    SUM(Total_Sales)
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;


-- 4.4 Sales Metrics by Outlet Establishment Year
SELECT
    Outlet_Establishment_Year,
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS Total_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM BlinkIT_data
GROUP BY Outlet_Establishment_Year
ORDER BY Total_Sales DESC;


-- 4.5 Percentage of Sales by Outlet Size
SELECT
    Outlet_Size,
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(
        (SUM(Total_Sales) * 100.0 /
         SUM(SUM(Total_Sales)) OVER ())
        AS DECIMAL(10,2)
    ) AS Sales_Percentage
FROM BlinkIT_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;


-- 4.6 Sales by Outlet Location Type
SELECT
    Outlet_Location_Type,
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM BlinkIT_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;


-- 4.7 All Key Metrics by Outlet Type
SELECT
    Outlet_Type,
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
    CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Avg_Item_Visibility
FROM BlinkIT_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;
