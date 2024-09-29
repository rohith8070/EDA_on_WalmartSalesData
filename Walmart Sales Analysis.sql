CREATE DATABASE IF NOT EXISTS WalmartSalesData;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- ---------------------------------------------------------------------------------------------------
-- -------------------------------------FEATURE ENGINEERING------------------------------------------- 
-- ---------------------------------------------------------------------------------------------------
-- Adding time_of_day

select time,
	(CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
    ) AS time_of_day
FROM sales;

-- Adding new column
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- Update values
UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
    );

-- Adding day_name 
SELECT date,
	DAYNAME(date)
FROM sales;
-- 
ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);
UPDATE sales
SET day_name = DAYNAME(date);

-- Adding month_name
SELECT date,
	MONTHNAME(date)
FROM sales;
-- 
ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);
UPDATE sales
SET month_name = MONTHNAME(date);

-- ---------------------------------------------------------------------------------------------------
-- ------------------------------------------GENERIC--------------------------------------------------
-- ---------------------------------------------------------------------------------------------------
-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,branch
FROM sales
ORDER BY branch;

-- ---------------------------------------------------------------------------------------------------
-- --------------------------------------------PRODUCT------------------------------------------------
-- ---------------------------------------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT 
	DISTINCT product_line
From sales;

-- What is the most common payment method?
SELECT 
	payment,
    COUNT(payment) AS Cnt
FROM sales
GROUP BY payment
ORDER BY Cnt DESC;

-- What is the most selling product line?
SELECT 
	product_line,
    COUNT(product_line) AS ProductLine
FROM sales
GROUP BY product_line
ORDER BY ProductLine DESC;

-- What is the total revenue by month?
SELECT 
	DISTINCT(month_name) AS months,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
	DISTINCT(month_name) AS months,
    SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- What product line had the largest revenue?
SELECT 
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT 
	city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT 
	product_line,
    SUM(tax_pct) AS total_tax
FROM sales
GROUP BY product_line
ORDER BY total_tax DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". 
-- Good if its greater than average sales
SELECT 
	AVG(total)
FROM sales;

ALTER TABLE sales ADD COLUMN Avg_sales_indicator VARCHAR(10);

UPDATE sales
SET Avg_sales_indicator = (
	CASE
		WHEN `total`> 322.498 THEN "Good"
        WHEN `total`< 322.498 THEN "Bad"
    END    
);

-- Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > ( SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT 
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender,product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
SELECT 
	product_line,
    ROUND(AVG(rating),2) AS average_ratings
FROM sales
GROUP BY product_line
ORDER BY average_ratings DESC;

-- ---------------------------------------------------------------------------------------------------
-- -------------------------------------------SALES---------------------------------------------------
-- ---------------------------------------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday" -- PER WEEK DAY
GROUP BY time_of_day;

-- Which of the customer types brings the most revenue?
SELECT 
	customer_type,
    SUM(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
	city,
    ROUND(AVG(tax_pct),2) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT 
	customer_type,
    SUM(tax_pct) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- --------------------------------------------------------------------------------------------
-- ----------------------------------------CUSTOMERS-------------------------------------------
-- --------------------------------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT(customer_type)
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
	DISTINCT(payment)
FROM sales;

-- What is the most common customer type?
SELECT 
	customer_type,
    COUNT(*) AS types
FROM sales
GROUP BY customer_type
ORDER BY types DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT 
	gender,
    COUNT(*) AS total_count
FROM sales
WHERE branch = 'C'
GROUP BY gender
ORDER BY total_count DESC;

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	COUNT(rating) AS MostRatings
FROM sales
GROUP BY time_of_day
ORDER BY MostRatings DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT 
	time_of_day,
    COUNT(rating) AS most_ratings
FROM sales
WHERE branch = 'C'
GROUP BY time_of_day
ORDER BY most_ratings DESC;

-- Which day of the week has the best avg ratings?
SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY avg_rating DESC;