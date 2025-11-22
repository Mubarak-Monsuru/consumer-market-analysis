-- 1. Create table 'customer_behavior' under schema 'shopping_data'
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

-- 2. Quality verification
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

-- 3. Customer Demographics Analysis
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
ORDER BY num_customers DESC;

--- Top locations by total spending
SELECT
	location,
	SUM("purchase_amount_(usd)") AS total_generated
FROM shopping_data.customer_behavior
GROUP BY location
ORDER BY total_spent DESC
LIMIT 10;

-- 4. Product & Category Insights
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
	ROUND(CAST(AVG(review_rating) AS numeric), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY category
ORDER BY num_of_items DESC;

--- Size and color preferences
SELECT size, COUNT(*) AS size_count
FROM shopping_data.customer_behavior
GROUP BY size
ORDER BY size_count DESC;

SELECT color, COUNT(*) AS color_count
FROM shopping_data.customer_behavior
GROUP BY color
ORDER BY color_count DESC;

-- 5. Customer Behavior Analysis
--- Spending distribution by frequency
SELECT 
	frequency_of_purchases,
	ROUND(AVG("purchase_amount_(usd)"), 2) avg_amount,
	COUNT(*) total_purchases
FROM shopping_data.customer_behavior
GROUP BY frequency_of_purchases
ORDER BY avg_amount DESC;

--- Customer segment based on previous purchases
SELECT previous_purchases,
CASE
	WHEN previous_purchases < 5 THEN 'New'
	WHEN previous_purchases BETWEEN 5 AND 10 THEN 'Occasional'
	WHEN previous_purchases BETWEEN 11 AND 20 THEN 'Regular'
	ELSE 'Loyal'
END AS customer_segment
FROM shopping_data.customer_behavior;

ALTER TABLE shopping_data.customer_behavior
ADD customer_segment VARCHAR(15);

UPDATE shopping_data.customer_behavior
SET customer_segment = CASE WHEN previous_purchases < 5 THEN 'New'
	WHEN previous_purchases BETWEEN 5 AND 10 THEN 'Occasional'
	WHEN previous_purchases BETWEEN 11 AND 20 THEN 'Regular'
	ELSE 'Loyal'
	END;

SELECT
	customer_segment,
	COUNT(*) AS num_customers,
    ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_spending,
    ROUND(CAST(AVG(review_rating) AS numeric), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY customer_segment
ORDER BY num_customers DESC;

-- 6. Marketing Efforts on Sales
--- Impact of subsription, discount and promo on purchases
SELECT
	subscription_status,
	COUNT(*),
	ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_spend,
	ROUND(CAST(AVG(review_rating) AS numeric), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY subscription_status;

SELECT
	discount_applied,
	COUNT(*) AS num_purchases,
	ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_spend,
	ROUND(CAST(AVG(review_rating) AS numeric), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY discount_applied;

SELECT
	promo_code_used,
	COUNT(*) AS num_purchases,
	ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_spend,
	ROUND(CAST(AVG(review_rating) AS numeric), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY promo_code_used;

--- Adoption of promo and discount in each customer segment
SELECT
	customer_segment,
	COUNT(*) AS total_customers,
	SUM(CASE WHEN promo_code_used = 'Yes' THEN 1 ELSE 0 END) AS promo_users,
    ROUND(100.0 * SUM(CASE WHEN promo_code_used = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS promo_usage_rate,
	SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discount_users,
    ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_usage_rate,
	ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_purchase_usd
FROM shopping_data.customer_behavior
GROUP BY customer_segment
ORDER BY promo_users DESC;

--- Discount and promo overlap
SELECT
    SUM(CASE WHEN discount_applied = 'Yes' AND promo_code_used = 'Yes' THEN 1 ELSE 0 END) AS both_used,
    SUM(CASE WHEN discount_applied = 'Yes' AND promo_code_used = 'No' THEN 1 ELSE 0 END) AS discount_only,
    SUM(CASE WHEN discount_applied = 'No'  AND promo_code_used = 'Yes' THEN 1 ELSE 0 END) AS promo_only,
    SUM(CASE WHEN discount_applied = 'No'  AND promo_code_used = 'No' THEN 1 ELSE 0 END) AS none
FROM shopping_data.customer_behavior;

SELECT
    CASE
        WHEN discount_applied = 'Yes' AND promo_code_used = 'Yes' THEN 'Both Used'
        WHEN discount_applied = 'Yes' THEN 'Discount Only'
        WHEN promo_code_used = 'Yes' THEN 'Promo Only'
        ELSE 'No Discount/Promo'
    END AS promo_behavior,
    COUNT(*) AS transactions,
    ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_spend,
	ROUND(CAST(AVG(review_rating) AS numeric), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY promo_behavior
ORDER BY avg_spend DESC;

-- 7. Operational Preferences (Shipping and Payment)
--- Shipping type usage
SELECT
	shipping_type,
	COUNT(*) AS num_orders,
	ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_spend
FROM shopping_data.customer_behavior
GROUP BY shipping_type
ORDER BY num_orders DESC;

---Payment method usage
SELECT
	payment_method,
	COUNT(*) AS num_payments,
	ROUND(AVG("purchase_amount_(usd)"), 2) AS avg_spend
FROM shopping_data.customer_behavior
GROUP BY payment_method
ORDER BY num_payments DESC;

-- 8. Seasonality & Trend Analysis
--- Purchases by season
SELECT
	season,
	category,
	item_purchased,
	COUNT(*) AS num_purchases,
	SUM("purchase_amount_(usd)") AS total_revenue
FROM shopping_data.customer_behavior
GROUP BY season, category, item_purchased
ORDER BY season, num_purchases DESC;

--- Ratings by season
SELECT
	season,
	ROUND(CAST(AVG(review_rating) AS numeric), 2) AS avg_rating
FROM shopping_data.customer_behavior
GROUP BY season
ORDER BY avg_rating DESC;
