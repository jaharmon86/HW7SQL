use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT a.first_name, a.last_name
FROM actor a

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT( a.first_name," ",a.last_name) AS 'Actor Name' FROM actor a;
-- ALTER TABLE actor a CHANGE actor_name `Actor Name` INT NOT NULL;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.first_name = 'JOE';
-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT a.actor_id, a.first_name, a.last_name 
FROM actor a
WHERE a.last_name LIKE '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT a.actor_id, a.first_name, a.last_name 
FROM actor a
WHERE a.last_name LIKE '%LI%'
ORDER BY 3, 2;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT c.country_id, c.country
FROM country c
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
SELECT * FROM actor;

ALTER TABLE actor
ADD COLUMN description BLOB;
-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT a.last_name, COUNT(*) AS `Count`
FROM actor a
GROUP BY 1;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT a.last_name, COUNT(*) AS `Count`
FROM actor a
GROUP BY a.last_name
HAVING Count > 2;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor a
SET a.first_name= 'HARPO'
WHERE a.first_name='GROUCHO' AND a.last_name='WILLIAMS';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor a
SET a.first_name= 'GROUCHO'
WHERE a.first_name='HARPO' AND a.last_name='WILLIAMS';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

--   * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
DESCRIBE sakila.address

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address
FROM staff s LEFT JOIN address a ON s.address_id = a.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT s.first_name, s.last_name, SUM(p.amount) AS 'TOTAL'
FROM staff s LEFT JOIN payment p  ON s.staff_id = p.staff_id
GROUP BY 1, 2;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(a.actor_id) AS 'TOTAL'
FROM film f INNER JOIN film_actor a ON f.film_id = a.film_id
GROUP BY 1;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id)
FROM film f INNER JOIN inventory i ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'TOTAL'
FROM payment p INNER JOIN customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY 2

--   ![Total amount paid](Images/total_payment.png)

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT f.title
FROM film f
WHERE (f.title LIKE 'K%' OR f.title LIKE 'Q%') 
AND f.language_id=(SELECT f.language_id FROM language where name='English')

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.actor_id
	IN (SELECT fa.actor_id FROM film_actor fa WHERE fa.film_id 
		IN (SELECT f.film_id from film f where title='Alone Trip'))
        
-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email 
FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city ci ON (a.city_id=ci.city_id)
JOIN country ct ON (ci.country_id=ct.country_id)

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title from film f
JOIN film_category fc on (f.film_id=fc.film_id)
JOIN category c on (fc.category_id=c.category_id);

-- * 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.film_id) AS 'Count of Rented Movies'
FROM film f
JOIN inventory i ON (f.film_id= i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY 1
ORDER BY 2 DESC

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) 
FROM payment p
JOIN staff s ON (p.staff_id=s.staff_id)
GROUP BY 1;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ci.city, ct.country
FROM store s
JOIN address a ON (s.address_id = a.address_id)
JOIN city ci ON (ci.city_id = a.city_id)
JOIN country ct ON (ct.country_id = ci.country_id)

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five AS
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five;