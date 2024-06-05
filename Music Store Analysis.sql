Q1: Who is the senior most employee based on job title?
Select * from employee
order by levels desc
limit 1

Q2: Which countries has the most invoices?
Select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc

Q3: What are top 3 values of total invoice?   
Select total from invoice
order by total desc
limit 3
SELECT (total,2) AS Total_Invoice
FROM invoice
ORDER BY total DESC
LIMIT 3

Q4:Which city has the best customers? We would like to throw a promotional Music Festival in the city we made most money. 
Write query that returns one city that has the highest sum of invoice totals.return both city name & sum of all invoice totals.
Select SUM(total) as invoice_total, billing_city
from invoice GROUP BY billing_city
order by invoice_total desc limit 1

Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write the query that returns the person who spent the most money.
Select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1


Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email

Q7:Lets invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT  artist.name AS Artist_Name, COUNT(track.track_id) AS Total_track
FROM artist
JOIN album ON album.artist_id = artist.artist_id
JOIN track ON track.album_id = album.album_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY Artist_Name
ORDER BY Total_track DESC
LIMIT 10

Q8: Return all the track names that have a song length longer than the averagesong length. Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first.
SELECT name AS Track_Name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC

Q9:Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 
   WITH best_selling_artist AS (
	SELECT artist.artist_id, artist.name AS artist_name, 
    SUM(invoice_line.unit_price*invoice_line.quantity) AS Total_Sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
(SUM(il.unit_price*il.quantity),2) AS Total_Spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC
	

Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.
	
WITH most_popular_genre AS (
SELECT customer.country AS Country, COUNT(invoice_line.quantity) AS Purchases, 
genre.genre_id AS Genre_ID, genre.name AS Genre_Name, 
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Row_No 
FROM customer
JOIN invoice ON invoice.customer_id = invoice.invoice_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY Country, genre. genre_id, genre. name
ORDER BY Country, Purchases DESC
)
SELECT Country, Purchases, Genre_id, Genre_Name
FROM most_popular_genre WHERE Row_No <= 1

Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. 
	
  WITH Customter_with_country AS 
(
SELECT customer.customer_id, customer.first_name, customer.last_name, 
invoice.billing_country AS Country, (SUM(invoice.total),2) AS total_spent,
ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS Row_No 
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
GROUP BY 1,2,3,4
ORDER BY 4,5 DESC
)
SELECT customer_id, first_name, last_name, Country, total_spent 
FROM Customter_with_country 
WHERE Row_No <= 1
