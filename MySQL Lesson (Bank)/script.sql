# +Вибрати усіх клієнтів, чиє ім'я має менше ніж 6 символів.

SELECT * FROM client
WHERE CHAR_LENGTH(FirstName) < 6;

# Вибрати львівські відділення банку.

SELECT * FROM department
WHERE DepartmentCity = 'LVIV';

# Вибрати клієнтів з вищою освітою та посортувати по прізвищу.

SELECT * FROM client
WHERE Education = 'HIGH'
ORDER BY Education;

# Виконати сортування у зворотньому порядку над таблицею Заявка і вивести 5 останніх елементів.

SELECT * FROM application
ORDER BY idApplication DESC
LIMIT 5;

# Вивести усіх клієнтів, чиє прізвище закінчується на OV чи OVA.

SELECT * FROM client
WHERE LastName LIKE '%OV' OR LastName LIKE '%OVA';

# Вивести клієнтів банку, які обслуговуються київськими відділеннями.

SELECT * FROM client
WHERE Department_idDepartment IN (SELECT idDepartment FROM department WHERE DepartmentCity LIKE 'KYIV');

# Другий спосіб з Join

SELECT *
FROM client C
JOIN department D ON C.Department_idDepartment=D.idDepartment
WHERE DepartmentCity LIKE 'KYIV';

# Вивести імена клієнтів та їхні номера телефону, погрупувавши їх за іменами.

SELECT FirstName, Passport FROM client
ORDER BY FirstName;

# Вивести дані про клієнтів, які мають кредит більше ніж на 5000 тисяч гривень.

SELECT * FROM client C
JOIN application A ON C.idClient = A.Client_idClient
WHERE Sum > 5000 and CreditState like 'n%';

# Порахувати кількість клієнтів усіх відділень та лише львівських відділень.

SELECT COUNT(idClient)
FROM client;

SELECT COUNT(idClient)
FROM client C
JOIN department D ON C.Department_idDepartment = D.idDepartment
WHERE DepartmentCity LIKE 'lVIV';

# Знайти кредити, які мають найбільшу суму для кожного клієнта окремо.

SELECT MAX(SUM), C.FirstName, C.LastName FROM application A
JOIN client C ON A.Client_idClient = C.idClient
GROUP BY Client_idClient;

# Визначити кількість заявок на крдеит для кожного клієнта.

SELECT COUNT(SUM), C.FirstName, C.LastName FROM application A
JOIN client C ON A.Client_idClient = C.idClient
GROUP BY Client_idClient;

# Визначити найбільший та найменший кредити.

SELECT MAX(SUM), MIN(SUM) FROM application;

# Порахувати кількість кредитів для клієнтів,які мають вищу освіту.

SELECT COUNT(SUM) FROM application A
JOIN client C ON A.Client_idClient = C.idClient
WHERE C.Education = 'HIGH';

# Вивести дані про клієнта, в якого середня сума кредитів найвища.

SELECT AVG(A.SUM) AS  MAX_SUM, C.FirstName, C.LastName, C.idClient FROM application A
JOIN client C ON C.idClient = A.Client_idClient
GROUP BY FirstName
ORDER BY MAX_SUM DESC
LIMIT 1;

# Вивести відділення, яке видало в кредити найбільше грошей


SELECT max(sumMax), idDepartment, DepartmentCity, CountOfWorkers
    FROM(
        SELECT sum(a.Sum) AS sumMax , d.idDepartment, d.DepartmentCity, d.CountOfWorkers
        FROM client c
            JOIN application a ON a.Client_idClient= c.idClient
            JOIN department d ON  d.idDepartment= c.Department_idDepartment
        group by c.Department_idDepartment) AS SUM;

# Вивести відділення, яке видало найбільший кредит.

SELECT max(sumMax), idDepartment, DepartmentCity, CountOfWorkers
    FROM(
        SELECT MAX(a.Sum) AS sumMax , d.idDepartment, d.DepartmentCity, d.CountOfWorkers
        FROM client c
            JOIN application a ON a.Client_idClient= c.idClient
            JOIN department d ON  d.idDepartment= c.Department_idDepartment
        group by c.Department_idDepartment) AS SUM;

# Усім клієнтам, які мають вищу освіту, встановити усі їхні кредити у розмірі 6000 грн.

UPDATE application
SET Sum = 6000
WHERE Client_idClient IN (
    SELECT A.Client_idClient FROM (SELECT * FROM application) AS A
    JOIN client C ON A.Client_idClient = C.idClient
    WHERE C.Education = 'HIGH'
    );

# Усіх клієнтів київських відділень пересилити до Києва.

UPDATE client
SET City = 'KYIV'
WHERE Department_idDepartment IN (
    SELECT D.idDepartment FROM (SELECT * FROM department DEPT
    JOIN client C ON DEPT.idDepartment = C.Department_idDepartment
    WHERE DEPT.DepartmentCity = 'KYIV') AS D
    );

# Видалити усі кредити, які є повернені.

DELETE FROM application
WHERE CreditState = 'RETURNED';

# Видалити кредити клієнтів, в яких друга літера прізвища є голосною.

DELETE FROM application
WHERE Client_idClient IN (
    SELECT idClient FROM client
        WHERE LastName REGEXP('^.[aeiouy].*$')
        );

-- Знайти львівські відділення, які видали кредитів на загальну суму більше ніж 5000

SELECT sum(SUM), idDepartment, DepartmentCity FROM bank.department
JOIN client ON department.idDepartment = client.Department_idDepartment
JOIN application ON client.idClient = application.Client_idClient
WHERE SUM > 5000  and department.DepartmentCity = 'LVIV';

 -- Знайти клієнтів, які повністю погасили кредити на суму більше ніж 5000

SELECT * FROM CLIENT C
JOIN application A ON C.idClient = a.Client_idClient
where sum >= 5000 and CreditState = 'Returned';

--  Знайти максимальний неповернений кредит.--

select max(sum), idApplication, Client_idClient from application
where CreditState like 'Not returned';

-- Знайти клієнта, сума кредиту якого найменша

select * from client c
join application a on c.idClient = a.Client_idClient
where sum in (
select min(sum) from application
);

-- Знайти кредити, сума яких більша за середнє значення усіх кредитів

select * from application
where Sum > (
 select avg(sum) from application
);

-- Знайти клієнтів, які є з того самого міста, що і клієнт, який взяв найбільшу кількість кредитів

select * from client
where City = (
    SELECT City from(
        select *,count(Client_idClient) as num,Client_idClient as id from application
        right join client c on application.Client_idClient = c.idClient
        group by Client_idClient
        order by num desc
        limit 1) as t
    where id=idClient);

# місто чувака який набрав найбільше кредитів

select City from client
where idClient = (
    select count(idClient) as num from client
    join application a on client.idClient = a.Client_idClient
    group by FirstName
    order by num desc
    limit 1
    );