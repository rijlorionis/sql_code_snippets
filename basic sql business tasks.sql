--Нужно вывести почтовый адрес всех поставщиков. Вначале покажите тех, у кого адрес отсутствует.

select ContactName, IFNULL(IFNULL(Country,' ') ||' '||IFNULL(Region, ' ')||', '||IFNULL(City, ' ') 
       ||', '||IFNULL(Address,' ')||', '||PostalCode, '!needs request') as MailAddress
from Customers
order by MailAddress

--Сгруппируйте заказы в 1996 и 1997 году по количеству в странах-получателях от большего к меньшему. Отобразите не менее 10 заказов.

select OrderDate, ShipCountry, count(*) as OrdCountryNum 
       ,strftime('%Y', OrderDate) as YYYY
from orders
where 
strftime('%Y', OrderDate) in ('1996', '1997')
group by ShipCountry, YYYY
having OrdCountryNum >= 10
order by OrdCountryNum desc

--Подсчитайте общее количество заказов по годам с 1996 года в случаях, когда заказов было больше 100.

SELECT strftime('%Y', OrderDate) as YYYY, count (*) as CountYYYYOrders
FROM orders
group by strftime('%Y', OrderDate)
having strftime('%Y', OrderDate)>'1996' and count (*)>100

--Добавьте категорию Snacks с описанием Chips and Other Junk в таблицу Categories


insert into Categories(CategoryName, Description)
values ('Snacks','Chips and Other Junk')


-- Измените описание категории Snacks на Chips and salty crackers

update Categories
set Description = 'Chips and salty crackers'
where CategoryID = 10


-- Вывести таблицу с именем, страной и городом всех клиентов и сотрудников

select ContactName, Country, City, 'Клиент' as person_type from Customers
union all
select FirstName ||' '|| LastName,  Country, City, 'Сотрудник' from Employees

--Найти дубли в телефонах клиентов

select Phone, count(Phone)
from Customers
group by Phone
having count(Phone)>1