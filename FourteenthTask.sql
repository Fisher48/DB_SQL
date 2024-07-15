Рефлексия на предыдущее задание:

Задание 13.3.1 Выполнено с недочетом, нужно было также учесть что в условии говорилось
не просто кол-во в заказе, а кол-во на складе и обновить запись через кол-во единиц
на складе UnitsInStock по таблице Products.
UPDATE [Order Details]
SET Discount = 0.20
WHERE ProductID IN
  (SELECT ProductID IN Products
   WHERE UnitsInStock > 50)

Задание 13.3.3 Выполнено верно, я согласен с тем что удалять записи следует ориентируясь на ID (уникальный идентификатор),
т.к действительно могут возникать записи имеющие одинаковые названия или информацию.

Решение задания 14:

14.1. Представление "Invoices" отличается от таблицы Orders тем, что в представлении Invoices
находится сразу вся информация из трех основных таблиц Поставщики, Клиенты, Сотрудники
и Информация о товаре из таблицы Товары связанных с Заказами.
Этот запрос как-бы расширяет информацию о заказе и выводит построчно полную информацию о каждом заказе,
включая информацию из 3 связанных таблиц (Customers,Shippers,Employees и Product через Order Details)
с таблицей Orders — это так называемая счет-фактура по каждому заказу
(Кто клиент, поставщик, какой сотрудник обрабатывает заказ, какой товар и т. д.)

14.2. Представление "CategorySales for 1997" выводит сумму по каждой категории товара
в алфавитном порядке, проданной за 1997 год, которую он берет из другого представления
"Product Sales for 1997", в котором уже расписан каждый продукт и их общая продажа по каждому товару включая
категорию и сам продукт, а вот в "CategorySales for 1997" уже суммируются товары по категориям и выдается общая сумма по категориям.

14.3. Представление "Sales Total by Amount"  выводит общий объем продаж
по каждому заказу по промежуточному итогу, который в свою очередь берется из представления "Order Subtotals"
и фильтруется по 1997 году и также где сумма продаж по каждому заказу больше 2500.

14.4. Представление "Products Above Average Price" выводит все товары,
у которых цена выше средней цены по всем товарам из таблицы Products.

14.5. Представление "Summary of Sales by Quarter" выводит сводку продаж по кварталам,
сумма продаж по заказам берется из представления "Order Subtotals", а дата доставки и ID заказа, берется из таблицы Orders,
где дата поставки не NULL, т. е. была осуществлена поставка товара.
Данное представление объединяет часть информации из таблицы Orders и представления "Order Subtotals".