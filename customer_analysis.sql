-- Create table 'customer_behavior' under schema 'shopping_data'
CREATE TABLE shopping_data.customer_behavior (
    customer_id VARCHAR PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    item_purchased VARCHAR(100),
    category VARCHAR(50),
    purchase_amount_usd INT,
    location VARCHAR(100),
    size VARCHAR(10),
    color VARCHAR(30),
    season VARCHAR(20),
    review_rating FLOAT,
    subscription_status VARCHAR(20),
    shipping_type VARCHAR(30),
    discount_applied VARCHAR(10),
    promo_code_used VARCHAR(10),
    previous_purchases INT,
    payment_method VARCHAR(50),
    frequency_of_purchases VARCHAR(30),
    rating_category VARCHAR(15),
    age_group VARCHAR(15)
);

SELECT *
FROM shopping_data.customer_behavior
LIMIT 5;

-- Quality verification

--- Check for missing values
SELECT 
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS valid_customers,
    COUNT(*) - COUNT(customer_id) AS missing_customers
FROM shopping_data.customer_behavior;

-- Detect duplicates
SELECT customer_id, COUNT(*) 
FROM shopping_data.customer_behavior
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Detect outliers in purchase amount
SELECT
	MIN("purchase_amount_(usd)") AS min_purchase,
	MAX("purchase_amount_(usd)") AS max_purchase, 
	AVG("purchase_amount_(usd)") AS avg_purchase
FROM shopping_data.customer_behavior;

-- Customer Demographics Analysis

--- Age distribution
SELECT
	age_group,
	COUNT(*) AS num_customers
FROM shopping_data.customer_behavior
GROUP BY age_group
ORDER BY num_customers DESC;

--- Gender balance
SELECT
	gender,
	COUNT(*) AS num_customers
FROM shopping_data.customer_behavior
GROUP BY gender;

SELECT
	age_group,
	gender,
	COUNT(*) AS num_customers
FROM shopping_data.customer_behavior
GROUP BY age_group, gender
ORDER BY num_customers DESC

--- Top locations by total spending
SELECT
	location,
	SUM("purchase_amount_(usd)") AS total_generated
FROM shopping_data.customer_behavior
GROUP BY location
ORDER BY total_spent DESC
LIMIT 10;

--Product & Category Insights

--- Top 10 purchased items
SELECT 
	item_purchased,
	COUNT(*) AS item_count,
	SUM("purchase_amount_(usd)") AS total_revenue
FROM shopping_data.customer_behavior
GROUP BY item_purchased
ORDER BY total_revenue DESC
LIMIT 10;

---Popular categories
SELECT
	category,
	COUNT(*) num_of_items,
	ROUND(AVG(review_rating), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY category
ORDER BY num_of_items DESC

--- Size and color preferences
SELECT size, COUNT(*) AS size_count
FROM shopping_data.customer_behavior
GROUP BY size
ORDER BY size_count DESC;

SELECT color, COUNT(*) AS color_count
FROM shopping_data.customer_behavior
GROUP BY color
ORDER BY color_count DESC;