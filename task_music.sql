--Порівняти всіх музичних виконавчів за кількістю проданих музичних треків та загальною сумою продажу
SELECT 
	 a2.Name AS artist_name
	, a2.ArtistId 
	, COUNT(il.InvoiceLineId) AS TotalTrackSold
	, SUM(t.UnitPrice * il.Quantity) AS TotalSales --згодом я помітив, що у таблиці Invoice i уже є Total :)
FROM InvoiceLine il 
LEFT JOIN Track t ON il.TrackId = t.TrackId 
LEFT JOIN Album a ON t.AlbumId = a.AlbumId 
LEFT JOIN Artist a2 ON a.ArtistId = a2.ArtistId 
GROUP BY 1,2
ORDER BY TotalSales DESC;

/* Сформувати топ-3 співробітника за рівнем продажів для кожного року */
--1. Рахуємо кількість продажів кожного співробітника по рокам
--2. Ранжуємо співробітників за їх продажами в межах кожного року
--3. Вибрати трьох найкращих співробітників для кожного року
with SalesEmployee AS 
(
SELECT
	e.EmployeeId
	, e.FirstName 
	, e.LastName 
	, strftime('%Y', i.InvoiceDate) AS SaleYear
	, SUM(i.Total) AS TotalSales
FROM Employee e 
LEFT JOIN Customer c ON e.EmployeeId = c.SupportRepId 
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId 
GROUP BY 1,2,3,4
),
RankedSales AS
(
SELECT
	EmployeeId
	, FirstName 
	, LastName 
	, TotalSales
	, SaleYear
	, ROW_NUMBER()OVER(PARTITION BY SaleYear ORDER BY TotalSales DESC) AS SalesRank
FROM SalesEmployee
)
SELECT 
    SaleYear,
    EmployeeId,
    FirstName,
    LastName,
    TotalSales
FROM RankedSales
WHERE 
    SalesRank <= 3
ORDER BY 
    SaleYear, TotalSales DESC;
   
   
/* Надати інформацію про клієнтів, які придбали музичні треки в межах 4 різних жанрів*/
 SELECT 
   	c.CustomerId 
   	, c.FirstName 
   	, c.LastName 
   	, COUNT(DISTINCT g.GenreId) AS nmb
   FROM Customer c 
   LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId 
   LEFT JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId 
   LEFT JOIN Track t ON il.TrackId = t.TrackId 
   LEFT JOIN Genre g ON t.GenreId = g.GenreId 
   GROUP BY 1,2,3
   HAVING COUNT(DISTINCT g.GenreId) >=4
   ORDER BY nmb DESC, 1,2
   
   
/*Сформувати перелік клієнтів, які станом на останній місяць продажів не придбали нічого
 *  протягом 1 місяця, 2 місяців, 3 місяців */
--1. Визначаємо останній місяць купівлі
--2. Отримує інформацію про останню покупку кожного клієнта
--3. Згрупувати за умовою
   
--1. 
WITH last_invoice_month AS (
    SELECT DATE(MAX(InvoiceDate), 'start of month') AS last_month
    FROM Invoice
),
--2.
customer_last_purchase AS (
    SELECT 
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS customer_name,
        DATE(MAX(i.InvoiceDate), 'start of month') AS last_purchase_month
    FROM 
        Customer c
    LEFT JOIN 
        Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY 
        c.CustomerId
)
--3.
SELECT 
    clp.CustomerId,
    clp.customer_name,
    CASE 
        WHEN clp.last_purchase_month IS NULL THEN 'Ніколи не купував'
        WHEN clp.last_purchase_month < DATE((SELECT last_month FROM last_invoice_month), '-3 months') THEN 'Не купував більше 3 місяців'
        WHEN clp.last_purchase_month < DATE((SELECT last_month FROM last_invoice_month), '-2 months') THEN 'Не купував 2-3 місяці'
        WHEN clp.last_purchase_month < DATE((SELECT last_month FROM last_invoice_month), '-1 month') THEN 'Не купував 1-2 місяці'
        ELSE 'Купував протягом останнього місяця'
    END AS purchase_status
FROM 
    customer_last_purchase clp
    
-- WHERE Потрібен, щоб виключити усіх клієнтів, які купували у останній місяць та тих, хто не купував нічого.
WHERE 
    clp.last_purchase_month < DATE((SELECT last_month FROM last_invoice_month), '-1 month')
    OR clp.last_purchase_month IS NULL
ORDER BY 
    clp.customer_name;  


   
   /* Сформувати найбільш популярний жанр з числа перших покупок клієнтів*/
--1. Визначити першу покупку клієнтів
--2. Визначити жанр треку при першій покупці
--3. Порахувати кожен жанр і визначити найпопулярніший

--1
WITH firstPurchase AS 
(
SELECT
	c.CustomerId 
	, MIN(i.InvoiceDate) AS 'min_date'
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId 
GROUP BY 1
),
--2
firstGenre AS
(
SELECT
	fp.CustomerId
	, g.GenreId
	, g.Name AS GenreName
FROM firstPurchase fp
LEFT JOIN Invoice i ON fp.CustomerId = i.CustomerId AND fp.min_date = i.InvoiceDate /*додаємо умову про першу покупку*/
LEFT JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId 
LEFT JOIN Track t ON il.TrackId = t.TrackId 
LEFT JOIN Genre g ON t.GenreId = g.GenreId
)
--3
SELECT
	GenreName
	, Count(*)
FROM firstGenre
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


/* Вивести динаміку продажів музичних треків за останні 3 роки */
WITH MaxDate AS
(
SELECT 
	MAX(i.InvoiceDate) AS max_date
FROM Invoice i 
)
SELECT
	i.InvoiceId 
	, i.InvoiceDate
	, SUM(il.Quantity * il.UnitPrice) AS total_profit
FROM Invoice i 
LEFT JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN  MaxDate md ON i.InvoiceDate > DATE(md.max_date, '-3 years')
GROUP BY 1,2
ORDER BY 2 ASC



/* Дослідити кумулятивну суму продажів для кожного замовника*/

SELECT
	i.InvoiceId 
	, i.CustomerId 
	, i.InvoiceDate 
	, i.Total
    , SUM(i.Total) OVER (PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS CumulativeSum
FROM Invoice i
ORDER BY 1,2

/* Розрахувати середній чек */
SELECT 
	AVG(i.Total)
FROM Invoice i


/* Розрахувати середню загальну суму продажу в перерахунку на одного замовника */
--1. Рахуємо суму по кожному замовнику
--2. Беремо середнє значення із сум по замовниках

WITH customer_total AS 
(
SELECT
	CustomerId
	, SUM(Total) AS total_sales
FROM Invoice i 
GROUP BY 1
)
SELECT 
	AVG(total_sales) AS avg_customer
-- можна ще порахувати min,max за таким же принципом
	, MIN(total_sales) AS min_customer 
	, MAX(total_sales) AS max_customer
	, COUNT(*) AS total_customer
FROM customer_total


/* Розрахувати середню тривалість періоду між першою покупкою і другою */
--1. Нумеруємо кожну покупку за датою
--2. Порахуємо першу та другу покупку
--3. Відняти 2 від 1
WITH nmb_purchases AS (
    SELECT CustomerID
    , InvoiceDate
    , ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY InvoiceDate) AS pn
    FROM Invoice i 
),
fisrt_second AS 
(
SELECT
    CustomerID
    , MAX(CASE WHEN pn = 1 THEN InvoiceDate END) 'first_p'
    , MAX(CASE WHEN pn = 2 THEN InvoiceDate END) 'second_p'
FROM nmb_purchases
WHERE pn <= 2
GROUP BY
    CustomerID
)
SELECT 
	AVG(JULIANDAY(second_p)-JULIANDAY(first_p)) AS avg_btw_firts_second
FROM fisrt_second
WHERE second_p IS NOT NULL