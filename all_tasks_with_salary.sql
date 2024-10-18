-- ЗАДАЧІ
-- Вивести з/п спеціалістів ML Engineer в 2023 році
SELECT
	salary_in_usd
	, job_title
FROM salaries
WHERE job_title = 'ML Engineer'

/*Назвати країну (comp_location), в якій зафіксована найменша з/п 
спеціаліста в сфері Data Scientist в 2023 році */

SELECT job_title
	, year
	, comp_location
	, salary_in_usd
FROM salaries
WHERE 
	job_title = 'Data Scientist'
	AND year = 2023
ORDER BY salary_in_usd ASC

-- Вивести з/п українців (код країни UA), додати сортування за зростанням з/п

SELECT 
	comp_location
	, job_title
	, salary_in_usd
FROM salaries
WHERE comp_location = 'UA'
ORDER BY salary_in_usd ASC

/* Вивести топ 5 з/п серед усіх спеціалістів, які працюють повністю 
віддалено (remote_ratio = 100) */

SELECT 
	salary_in_usd
	, remote_ratio
FROM salaries
WHERE remote_ratio = 100
ORDER BY remote_ratio DESC
LIMIT 5;

/* Згенерувати .csv файл з таблицею даних всіх спеціалістів, які в 2023
році мали з/п більшу за $100,000 і працювали в компаніях середнього 
розміру (comp_size = 'M') */
SELECT
	year
	, salary_in_usd
	, comp_size
FROM salaries
WHERE year = 2023
	AND comp_size = 'M'
	AND salary_in_usd >= 100000
ORDER BY salary_in_usd ASC


/* Вивести кількість унікальних значень для кожної колонки, що містить 
текстові значення.
*/
SELECT
	COUNT(DISTINCT year) AS count_year
	, COUNT(DISTINCT emp_type) AS count_emp
	, COUNT(DISTINCT job_title)
	, COUNT(DISTINCT salary_curr)
	, COUNT(DISTINCT emp_location)
	, COUNT(DISTINCT comp_location)
	, COUNT(DISTINCT comp_size)
FROM salaries


/* Вивести унікальні значення для кожної колонки, що містить текстові 
значення. (SELECT DISTINCT column_name FROM salaries)*/
SELECT 
	DISTINCT job_title
FROM salaries

/*Вивести середню, мінімальну та максимальну з/п (salary_in_usd) для 
кожного року (окремими запитами, в кожному з яких впроваджено фільтр 
відповідного року) */
SELECT
	MAX (salary_in_usd)
	, MIN (salary_in_usd)
	, AVG (salary_in_usd)
FROM salaries
WHERE year = 2020

SELECT
	MAX (salary_in_usd)
	, MIN (salary_in_usd)
	, AVG (salary_in_usd)
FROM salaries
WHERE year = 2021

SELECT
	MAX (salary_in_usd)
	, MIN (salary_in_usd)
	, AVG (salary_in_usd)
FROM salaries
WHERE year = 2022

/*Вивести середню з/п (salary_in_usd) для 2023 року по кожному рівню 
досвіду працівників (окремими запитами, в кожному з яких впроваджено 
фільтр року та досвіду). */

SELECT
	salary_in_usd
	, emp_type
	, exp_level
FROM salaries
WHERE year = 2023
	AND exp_level = 'MI'


/* Вивести 5 найвищих заробітних плат в 2023 році для представників 
спеціальності ML Engineer. Заробітні плати перевести в гривні*/
SELECT
	job_title
	, salary_in_usd
	, year
FROM salaries
WHERE year = 2023
	AND job_title = 'ML Engineer'
ORDER BY salary_in_usd DESC
LIMIT 5;


/*Вивести Унікальні значення колонки remote_ratio, формат даних має 
бути дробовим з двома знаками після коми, приклад: значення 50 має 
відображатись в форматі 0.50 */
SELECT
	DISTINCT ROUND (remote_ratio/100.0,2)
FROM salaries


/* Вивести дані таблиці, додавши колонку 'exp_level_full' з повною 
назвою рівнів досвіду працівників відповідно до колонки exp_level. 
Визначення: Entry-level (EN), Mid-level (MI), Senior-level (SE), 
Executive-level (EX) */
SELECT *
	, CASE 
	WHEN exp_level = 'EN' THEN 'Entry-level'
	WHEN exp_level = 'MI' THEN 'Mid-level'
	WHEN exp_level = 'SE' THEN 'Senior_level'
	ELSE 'Executive_else'
	END AS exp_level_full
FROM salaries


/* Додатки колонку "salary_category', яка буде відображати різні 
категорії заробітних плат відповідно до їх значення в колонці 
'salary_in_usd'. Визначення: з/п менша за 20 000 - Категорія 1, з/п 
менша за 50 000 - Категорія 2, з/п менша за 100 000 - Категорія 3, з/п 
більша за 100 000 - Категорія 4*/

SELECT *
	, CASE
	WHEN salary_in_usd < 20000 THEN 'category_1'
	WHEN salary_in_usd < 50000 THEN 'category_2'
	WHEN salary_in_usd <= 100000 THEN 'category_3'
	WHEN salary_in_usd > 100000 THEN 'category_4'
	END AS salary_category
FROM salaries




/* Дослідити всі колонки на наявність відсутніх значень, порівнявши 
кількість рядків таблиці з кількістю значень відповідної колонки*/
SELECT
	COUNT(*)- COUNT(salary_in_usd)
FROM salaries

SELECT
	COUNT(*)- COUNT(job_title)
FROM salaries



/* Порахувати кількість працівників в таблиці, які в 2023 році працюють
на компанії розміру "М" і отримують з/п вищу за $100 000*/
SELECT
	COUNT(salary_in_usd)
FROM salaries
WHERE year = 2023
	AND comp_size = 'M'
	AND salary_in_usd >= 100000



/* Вивести всіх співробітників, які в 2023 отримували з/п більшу за 
$300тис */
SELECT *
FROM salaries
WHERE year = 2023
	AND salary_in_usd >=300000

/* Вивести всіх співробітників, які в 2023 отримували з/п більшу за 
$300тис. та не працювали в великих компаніях*/
SELECT *
FROM salaries
WHERE year = 2023
	AND salary_in_usd >=300000
	AND comp_size != 'L'


/* Чи є співробітники, які працювали на Українську компанію повністю 
віддалено?*/
SELECT *
FROM salaries
WHERE comp_location = 'UA'
	AND remote_ratio = 100

/* Вивести всіх співробітників, які в 2023 році працюючи в Німеччині 
(comp_location = 'DE') отримували з/п більшу за $100тис*/
SELECT *
FROM salaries
WHERE comp_location = 'DE'
	AND year = 2023
	AND salary_in_usd >= 100000

/* оопрацювати попередній запит: Вивести з результатів тільки ТОП 5 
співробітників за рівнем з/п*/
SELECT *
FROM salaries
WHERE comp_location = 'DE'
	AND year = 2023
	AND salary_in_usd >= 100000
ORDER BY salary_in_usd DESC
LIMIT 5;

/* Додати в попередню таблицю окрім спеціалістів з Німеччини 
спеціалістів з Канади (CA)*/
SELECT *
FROM salaries
WHERE comp_location = 'DE'
	AND year = 2023
	AND salary_in_usd >= 100000

UNION

SELECT *
FROM salaries
WHERE comp_location = 'CA'
	AND year = 2023
	AND salary_in_usd >= 100000
ORDER BY salary_in_usd DESC
LIMIT 10;

/* Надати перелік країн, в яких в 2021 році спеціалісти "ML Engineer" 
та "Data Scientist" отримувати з/п в діапазоні між $50тис і $100тис*/
SELECT *
FROM salaries
WHERE year = 2021
	AND job_title = 'ML Engineer'
	AND salary_in_usd >= 50000
	AND salary_in_usd <= 100000
	
UNION

SELECT *
FROM salaries
WHERE year = 2021
	AND job_title = 'Data Scientist'
	AND salary_in_usd >= 50000
	AND salary_in_usd <= 100000

	
/* Порахувати кількість спеціалістів, які працюючи в середніх компаніях
(comp_size = M) та в великих компаніях (comp_size = L) працювали 
віддалено (remote_ratio=100 або remote_ratio=50)*/
SELECT
	comp_size
	, COUNT(*) AS specialist_count
FROM salaries
WHERE 
	comp_size IN ('M', 'L')
	AND remote_ratio IN (50, 100)
GROUP BY 1

/* Вивести кількість країн, які починаються на "С" */
SELECT COUNT (DISTINCT comp_location)
FROM salaries
WHERE comp_location LIKE 'C%'



/*Вивести професії, назва яких не складається з трьох слів */
SELECT *
FROM salaries
WHERE job_title NOT LIKE '% % %'


/*Для кожного року навести дані щодо середньої заробітної плати та 
кількості спеціалістів. Результат експортувати в .csv файл, імпортувати
файл в Power BI і побудувати доречну візуалізацію отриманих даних */
SELECT
	year
	, ROUND(AVG(salary_in_usd),2) AS avg_salary
	, COUNT(*) AS emp_nmb
FROM salaries
GROUP BY 1;


/* Вивести всіх спеціалістів, в яких з/п вище середньої в таблиці*/
SELECT *
FROM salaries
WHERE salary_in_usd > 
	(
	SELECT
	AVG(salary_in_usd)
	FROM salaries
	WHERE year = 2023
	)
	AND year = 2023

/* Вивести всіх спеціалістів, які живуть в країнах, де середня з/п вища 
за середню серед усіх країн. */
-- 1. Знайти середню всіх спеціалістів
-- 2. Знайти середню по країнах
-- 3. Порівняти 
-- 4.Спеціалісти що проживають у цих країнах


--1.
SELECT 
	AVG(salary_in_usd)
FROM salaries
--2,3
SELECT 
	comp_location
FROM salaries
WHERE year = 2023
GROUP BY 1
HAVING AVG(salary_in_usd) >
	(
	SELECT 
		AVG(salary_in_usd)
	FROM salaries
	WHERE year = 2023
	)
	
-- 4
SELECT *
FROM salaries
WHERE emp_location IN 
(
	SELECT 
		comp_location
	FROM salaries
	WHERE year = 2023
	GROUP BY 1
	HAVING AVG(salary_in_usd) >
(
		SELECT 
			AVG(salary_in_usd)
		FROM salaries
		WHERE year = 2023
)
)


/* Знайти мінімальну заробітну плату серед максимальних з/п по країнах*/
-- 1 знайти максимальну зп
-- 2 знайти найменшу

--1
SELECT
	MAX(salary_in_usd)
FROM salaries
WHERE year = 2023
GROUP BY comp_location

--2
SELECT 
	MIN(t.salary_in_usd)
FROM 
(
	SELECT
		MAX(salary_in_usd) AS salary_in_usd
	FROM salaries
	WHERE year = 2023
	GROUP BY comp_location
) AS t


/* По кожній професії вивести різницю між середньою з/п та максимальною
з/п усіх спеціалістів*/
SELECT
	AVG(salary_in_usd)
FROM salaries

SELECT 
	job_title
	, MAX(salary_in_usd) - 
	(
	SELECT AVG(salary_in_usd)
	FROM salaries
	) AS diff
FROM salaries
GROUP BY 1

/* Вивести дані по співробітнику, який отримує другу по розміру з/п в 
таблиці*/
SELECT *
FROM salaries
ORDER BY salary_in_usd DESC
LIMIT 2;

SELECT *
FROM (SELECT *
FROM salaries
ORDER BY salary_in_usd DESC
LIMIT 2) AS t
ORDER BY salary_in_usd ASC
LIMIT 1;






