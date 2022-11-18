

/** Data Exploration of Chinbook Music **/

--Which countries have the most Invoices?-----------------------------------------------------------------------------

SELECT billingcountry,
       count(invoiceid) AS invoices
FROM invoice
GROUP BY billingcountry
ORDER BY invoices DESC

--Which city has the best customers?----------------------------------------------------------------------------------

SELECT billingcity,
       sum(total) AS it
FROM invoice
GROUP BY billingcity
ORDER BY 2 DESC
LIMIT 1

--Who is the best customer?--------------------------------------------------------------------------------------------

SELECT c.customerid,
       sum(il.quantity*il.unitprice) amountspent
FROM customer c
JOIN invoice i ON c.customerid =i.customerid
JOIN invoiceline il ON il.invoiceid = i.invoiceid
GROUP BY c.customerid
ORDER BY 2 DESC

--Return the email, first name, last name, and Genre of all Rock Music listeners --------------------------------------

SELECT c.email,
       c.firstname,
       c.lastname,
       g.name
FROM genre g
JOIN track t ON t.genreid = g.genreid
JOIN invoiceline il ON il.trackid = t.trackid
JOIN invoice i ON i.invoiceid = il.invoiceid
JOIN customer c ON i.customerid = c.customerid
WHERE g.name = 'Rock'
GROUP BY c.email,
         c.firstname,
         c.lastname,
         g.name
ORDER BY c.email

-- Who is writing the rock music?----------------------------------------------------------------------------------------

SELECT ar.artistid,
       ar.name,
       count(*) songs
FROM genre g
JOIN track t ON t.genreid = g.genreid
JOIN album al ON al.albumid = t.albumid
JOIN artist ar ON ar.artistid = al.artistid
WHERE g.name = 'Rock'
GROUP BY ar.artistid,
         ar.name
ORDER BY songs DESC
LIMIT 10

--Find which artist has earned the most according to the InvoiceLines-----------------------------------------------------

SELECT ar.name,
       sum(il.quantity*t.unitprice) amountspent
FROM artist ar
JOIN album al ON ar.artistid = al.artistid
JOIN track t ON t.albumid = al.albumid
JOIN invoiceline il ON il.trackid = t.trackid
GROUP BY 1
ORDER BY 2 DESC

--Find which customer spent the most depending upon the artist who earned the most------------------------------------------

SELECT ar.name,
       sum(il.quantity*t.unitprice) amountspent,
       c.customerid,
       c.firstname,
       c.lastname
FROM artist ar
JOIN album al ON ar.artistid = al.artistid
JOIN track t ON t.albumid = al.albumid
JOIN invoiceline il ON il.trackid = t.trackid
JOIN invoice i ON i.invoiceid = il.invoiceid
JOIN customer c ON i.customerid = c.customerid
WHERE ar.name = 'Iron Maiden'
GROUP BY ar.name,
         c.customerid,
         c.firstname,
         c.lastname
ORDER BY 2 DESC,
         4


-- Return all the track names that have a song length longer than the average song length------------------------------------

SELECT Name,
       Milliseconds
FROM Track
WHERE Milliseconds >
    (SELECT AVG(Milliseconds)
     FROM Track)
ORDER BY Milliseconds DESC;

--Which artists have 10 or more number of albums? -----------------------------------------------------------------------------

SELECT ar.artistid,
       ar.name,
       count(al.artistid) numberofalbums
FROM album al
JOIN artist ar ON ar.artistid = al.artistid
GROUP BY ar.artistid,
         ar.name
HAVING numberofalbums >= 10
ORDER BY 3 DESC

--Who are the top 3 customers based on amount they spent and which country do they belong to? ----------------------------------

SELECT c.customerid,
       c.firstname,
       c.lastname,
       sum(il.quantity*il.unitprice) amountspent,
       c.country
FROM customer c
JOIN invoice i ON c.customerid =i.customerid
JOIN invoiceline il ON il.invoiceid = i.invoiceid
GROUP BY c.customerid
ORDER BY 4 DESC
LIMIT 3

--What genres are most popular? -------------------------------------------------------------------------------------------------

SELECT g.Name GenreName,
       count(t.genreid) NumberofSongs
FROM genre g
JOIN track t ON g.genreid = t.genreid
GROUP BY g.name
ORDER BY 2 DESC

-- How many number of tracks are there in each playlist? ----------------------------------------------------------------------

SELECT pt.playlistid,
       count(*) NumberofTracks
FROM PlaylistTrack PT
JOIN Track t ON PT.TrackId = t.TrackId
GROUP BY pt.playlistid
ORDER BY 2 DESC

/** find out the most popular music Genre for each country depending upon highest amount of purchases. 
Returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared, return all Genres.**/----------------------------------------

WITH CountryGenPopularityList AS
  (SELECT count(*) AS Popularity,
          g.Name AS GenreName,
          i.BillingCountry AS Country
   FROM InvoiceLine il
   JOIN Track t ON trk.TrackId=il.TrackId
   JOIN Genre g ON gen.GenreId=t.GenreId
   JOIN Invoice i ON il.InvoiceId=i.InvoiceId
   GROUP BY Country,
            g.GenreId)
SELECT cgpl.Country,
       cgpl.GenreName,
       cgpl.Popularity
FROM CountryGenPopularityList cgpl
WHERE cgpl.Popularity =
    (SELECT max(Popularity)
     FROM CountryGenPopularityList
     WHERE cgpl.Country=Country
     GROUP BY Country)
ORDER BY Country

-- Determine the customer that has spent the most on music for each country.----------------------------------------------
WITH TotalsPerCountry AS
  (SELECT i.BillingCountry,
          c.FirstName || ' ' || c.LastName AS CustomerName,
          sum(i.Total) AS TotalSpent
   FROM Invoice i
   JOIN Customer c ON c.CustomerId=i.CustomerId
   GROUP BY i.BillingCountry,
            cust.CustomerId
   ORDER BY i.BillingCountry)
SELECT a.BillingCountry,
       a.CustomerName,
       a.TotalSpent
FROM TotalsPerCountry a
WHERE a.TotalSpent =
    (SELECT max(TotalSpent)
     FROM TotalsPerCountry
     WHERE a.BillingCountry=BillingCountry
     GROUP BY BillingCountry)
