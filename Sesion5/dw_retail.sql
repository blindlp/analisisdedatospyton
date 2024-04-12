-- Active: 1712881959339@@172.16.5.4@3310@retail_db
DROP DATABASE IF EXISTS dw_retail;

CREATE DATABASE dw_retail;

USE dw_retail;

-- Crear la tabla de dimensiones
CREATE TABLE dimension_customer (
    customer_id INT PRIMARY KEY,
    customer_fname VARCHAR(45) NOT NULL,
    customer_lname VARCHAR(45) NOT NULL,
    customer_email VARCHAR(45) NOT NULL,
    customer_street VARCHAR(255) NOT NULL,
    customer_city VARCHAR(45) NOT NULL,
    customer_state VARCHAR(45) NOT NULL,
    customer_zipcode VARCHAR(45) NOT NULL
);

CREATE TABLE dimension_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(45) NOT NULL
);

CREATE TABLE dimension_category (
    category_id INT PRIMARY KEY,
    category_department_id INT NOT NULL,
    category_name VARCHAR(45) NOT NULL,
    FOREIGN KEY (category_department_id) REFERENCES dimension_department(department_id)
);

CREATE TABLE dimension_product (
    product_id INT PRIMARY KEY,
    product_category_id INT NOT NULL,
    product_name VARCHAR(45) NOT NULL,
    product_description VARCHAR(255) NOT NULL,
    product_price FLOAT NOT NULL,
    product_image VARCHAR(255) NOT NULL,
    FOREIGN KEY (product_category_id) REFERENCES dimension_category(category_id)
);

CREATE TABLE dimension_order (
    order_id INT PRIMARY KEY,
    order_date DATETIME NOT NULL,
    order_customer_id INT NOT NULL,
    order_status VARCHAR(45) NOT NULL,
    FOREIGN KEY (order_customer_id) REFERENCES dimension_customer(customer_id)
);

CREATE TABLE dimension_order_item (
    order_item_id INT PRIMARY KEY,
    order_item_order_id INT NOT NULL,
    order_item_product_id INT NOT NULL,
    order_item_quantity TINYINT NOT NULL,
    order_item_subtotal FLOAT NOT NULL,
    order_item_product_price FLOAT NOT NULL,
    FOREIGN KEY (order_item_order_id) REFERENCES dimension_order(order_id),
    FOREIGN KEY (order_item_product_id) REFERENCES dimension_product(product_id)
);

-- Crear la tabla de hechos (fact table)
CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    order_date DATETIME NOT NULL,
    order_customer_id INT NOT NULL,
    order_status VARCHAR(45) NOT NULL,
    total_items INT NOT NULL,
    total_amount FLOAT NOT NULL,
    FOREIGN KEY (order_customer_id) REFERENCES dimension_customer(customer_id)
);

CREATE TABLE dimension_time (
    time_id INT PRIMARY KEY,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    day_of_year INT NOT NULL,
    week_of_year INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);


ALTER TABLE fact_orders ADD COLUMN time_id INT;

use retail_db;
UPDATE products set product_category_id = 58
where product_category_id = 59;


INSERT INTO 'departments' VALUES(8, 'Sports');


use dw_retail;


select * from dimension_order;


select * from products
where product_category_id = 58;



use dw_retail;
 INSERT INTO dimension_time (time_id, year, quarter, month, day, day_of_week, day_of_year, week_of_year, is_weekend)
SELECT
    DISTINCT DATE_FORMAT(order_date, '%Y%m%d') AS time_id,
    YEAR(order_date) AS year,
    QUARTER(order_date) AS quarter,
    MONTH(order_date) AS month,
    DAY(order_date) AS day,
    DAYOFWEEK(order_date) AS day_of_week,
    DAYOFYEAR(order_date) AS day_of_year,
    WEEK(order_date) AS week_of_year,
    CASE WHEN DAYOFWEEK(order_date) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend
FROM retail_db.orders;



INSERT INTO fact_orders (order_id, order_date, order_customer_id, order_status, total_items, total_amount, time_id)
SELECT o.order_id, o.order_date, o.order_customer_id, o.order_status, SUM(oi.order_item_quantity) AS total_items, SUM(oi.order_item_subtotal) AS total_amount, DATE_FORMAT(o.order_date, '%Y%m%d') as time_id
FROM retail_db.orders o
INNER JOIN retail_db.order_items oi ON o.order_id = oi.order_item_order_id
INNER JOIN dimension_time dt ON DATE_FORMAT(o.order_date, '%Y%m%d') = dt.time_id
GROUP BY o.order_id;
