--Create a CTE named top_customers that lists the top 10 customers based on the total number 
--of distinct films they've rented.
--For each customer from top_customers, retrieve their average payment amount and the count of rentals they've made.

WITH CTE_TOP_CUSTOMERS  AS
(
	SELECT 	se_customer.first_name AS first_name,
	        se_customer.last_name AS last_name,
		    COUNT( DISTINCT se_film.film_id) AS total_distinct_films,
		    COUNT(se_rental.rental_id) AS total_rental,
            ROUND(AVG(se_payment.amount),2) AS average_payment 
	FROM customer AS se_customer
	INNER JOIN rental AS se_rental
		ON se_customer.customer_id = se_rental.customer_id
	INNER JOIN payment AS se_payment
		ON se_customer.customer_id = se_payment.customer_id
	INNER JOIN inventory AS se_inventory
		ON se_rental.inventory_id = se_inventory.inventory_id
	INNER JOIN film AS se_film
		ON se_inventory.film_id = se_film.film_id
	GROUP BY se_customer.first_name, se_customer.last_name
	ORDER BY total_distinct_films DESC
	LIMIT 10
)	
	
SELECT first_name, 
	   last_name, 
	   total_rental, 
	   average_payment
FROM CTE_TOP_CUSTOMERS

-----------------------------------------------------------------------	
--Create a Temporary Table named film_inventory that stores film titles and their corresponding 
--available inventory count.

DROP TABLE IF EXISTS temp_film_inventory;
CREATE TEMPORARY TABLE temp_film_inventory AS
(   
	SELECT se_film.title as title,
		   COUNT(se_inventory.inventory_id)	AS inventory_count
	FROM inventory AS se_inventory
	INNER JOIN film AS se_film
	ON se_inventory.film_id = se_film.film_id
    GROUP BY se_film.title

);

CREATE INDEX idx_temp_film_inventory_title ON temp_film_inventory(title);
SELECT * FROM 	temp_film_inventory
--Populate the film_inventory table with data from the DVD rental database, considering both rentals and returns.	

DROP TABLE IF EXISTS temp_film_inventory;
CREATE TEMPORARY TABLE temp_film_inventory AS
(
	SELECT 	se_film_inventory.title,
		    se_film_inventory.inventory_count,
	        se_rental.rental_id,
	        se_rental.return_date
	FROM temp_film_inventory AS se_film_inventory
	INNER JOIN film AS se_film
		ON se_film_inventory.title = se_film.title
	INNER JOIN inventory AS se_inventory
		ON se_film.film_id = se_inventory.film_id
	INNER JOIN rental AS se_rental
		ON se_inventory.inventory_id = se_rental.inventory_id 
	
)
CREATE INDEX idx_temp_film_inventory_title ON temp_film_inventory(title)
SELECT * FROM 	temp_film_inventory

--Retrieve the film title with the lowest available inventory count from the film_inventory table.

		
SELECT 	title,inventory_count FROM TEMP_FILM_INVENTORY
order by inventory_count, title
LIMIT 1
	
	
	
--Create a Temporary Table named store_performance that stores store IDs,
-- revenue, and the average payment amount per rental.	
	
DROP TABLE IF EXISTS temp_store_performance ;
CREATE TEMPORARY TABLE temp_store_performance  AS
(   
	SELECT se_store.store_id,
		   SUM(se_payment.amount) AS store_revenue,
	       ROUND(AVG(se_payment.amount),2) AS average_per_rental
	       
	FROM store AS se_store
	INNER JOIN staff AS se_staff
	ON se_store.store_id = se_staff.store_id
	INNER JOIN payment AS se_payment
	ON se_staff.staff_id = se_payment.staff_id
	GROUP BY se_store.store_id
  

);

CREATE INDEX idx_temp_store_performance_store_id ON temp_store_performance(store_id);	
	
