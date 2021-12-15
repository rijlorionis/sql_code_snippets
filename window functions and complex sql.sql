--Кто из работников сопровождал заказы на самую крупную сумму с учетом скидки клиентам в категории "Напитки" в 1998? Покажите имя и сумму заказов.

select FirstName ||' '|| LastName as Employee_Name, 
	(
        select
              sum( (
                 select sum(UnitPrice*Quantity*(1-discount)) 
                 from Order_Details as od
                 where od.OrderID=o.OrderID
                 and od.ProductID in (
                   select p.ProductID
                   from products as p
                   where p.CategoryID in (
                   select c.categoryID
                   from Categories as c
                   where c.CategoryName='Beverages')
                   )
              )) 
            from orders as o
            where o.EmployeeID=e.EmployeeID
            and o.OrderDate >= date('1998-01-01')
      and o.OrderDate < date ('1999-01-01')) as sum_Beverages_98
from Employees as e
group by Employee_Name
order by sum_Beverages_98 DESC limit 1 


--CTE

with 
     cte as (
     select *
     from Order_Details 
     where ProductID='14'
     ),
     ctel as (
     select CompanyName, ContactName, ShipCountry, ShipCity, ShipAddress, sum(UnitPrice*Quantity*(1-discount)) as  cost
     from Orders o inner join Customers c on o.CustomerID=c.CustomerID
     inner join cte on cte.OrderID=o.OrderID
     group by CompanyName
     )
     select * from ctel

--Посчитать продажи каждого работника в 1997 году с итоговой суммой

select FirstName ||' '|| LastName as Employee_Name, round(sum(UnitPrice*Quantity*(1-discount)), 0) sales_97, e.City
from Employees as e 
left join Orders as o
     on e.EmployeeID=o.EmployeeID
left join Order_Details as od
     on o.OrderID=od.OrderID 
and o.OrderDate >= date('1997-01-01')
      and o.OrderDate < date ('1998-01-01')
group by Employee_Name

union all

select 'TOTAL SALES', round(sum(UnitPrice*Quantity*(1-discount)), 0), ' ' 
from Employees as e 
left join Orders as o
     on e.EmployeeID=o.EmployeeID
left join Order_Details as od
     on o.OrderID=od.OrderID 
and o.OrderDate >= date('1997-01-01')
      and o.OrderDate < date ('1998-01-01')
order by sales_97 

--CTE + partition: Нарастающим итогом подсчитать как увеличивалась стоимость проданных товаров с разбивкой на категории

with sales as
     (
     select  strftime('%Y', OrderDate) as Year,
             strftime('%m', OrderDate) as Month,
             c.CategoryName as Product_Category,
             round(sum(od.UnitPrice*od.Quantity*(1-od.Discount)), 0) as sum_sales
     from Orders o 
     left join Order_Details od
     on o.OrderID=od.OrderID
     left join Products p
     on od.ProductID=p.ProductID
     left join Categories c
     on p.CategoryID=c.CategoryID
     group by strftime('%Y', OrderDate),
           strftime('%m', OrderDate),
           c.CategoryName
           )
     select s.Year,
            s.Month,
            s.Product_Category,
            sum(s.sum_sales) over(partition by s.Product_Category order by s.Year, s.Month) as prod_sales_growth
            from sales s
            order by s.Product_Category, s.Year, s.Month
     

           