create database python_sql_project;
Use python_sql_project;
select * from df_orders ;

-- find top 10 higest revenue generating products
select product_id , sum(sale_price) as revenue
from df_orders
group by product_id
order by revenue desc
limit 10;

-- find top 5 highest selling products in each region
WITH ranked_sales AS (
    SELECT 
        region,
        product_id,
        SUM(sale_price) AS sales,
        ROW_NUMBER() OVER (
            PARTITION BY region 
            ORDER BY SUM(sale_price) DESC
        ) AS rankk
    FROM df_orders
    GROUP BY region, product_id
)

SELECT *
FROM ranked_sales
WHERE rankk <= 5;


-- find month over month grwoth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


-- For each category, which month had highest sales
WITH monthly_sales AS (
    SELECT 
        category,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, MONTH(order_date)
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY category 
               ORDER BY sales DESC
           ) AS rn
    FROM monthly_sales
)

SELECT category, order_month, sales
FROM ranked
WHERE rn = 1;

-- Which sub-category had highest profit growth (2023 vs 2022)
WITH yearly_profit AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS year,
        SUM(profit) AS profit
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
pivot AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN year = 2022 THEN profit ELSE 0 END) AS profit_2022,
        SUM(CASE WHEN year = 2023 THEN profit ELSE 0 END) AS profit_2023
    FROM yearly_profit
    GROUP BY sub_category
)

SELECT 
    sub_category,
    profit_2022,
    profit_2023,
    (profit_2023 - profit_2022) AS growth
FROM pivot
ORDER BY growth DESC
LIMIT 1;

