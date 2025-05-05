--Câu 1: 
---A. Bạn hãy xây dựng đoạn truy vấn đếm tổng số đơn hàng được order (0.25đ)
SELECT COUNT(Invoice_ID) AS total_orders
FROM supermarket_sales;
---B. Bạn hãy xây dựng đoạn truy vấn tính tổng doanh số theo từng Branch. Kết quả làm tròn đến 2 chữ số thập phân (0.25đ)
SELECT Branch, ROUND(SUM(cogs), 2) AS sum_sales
FROM [dbo].[supermarket_sales]
GROUP BY Branch;

--Câu 2: 
---A. Bạn hãy xây dựng đoạn truy vấn tính tổng doanh số và số lượng đơn hàng của từng ProductLine (0.25đ)
SELECT  Product_line, 
        ROUND(SUM(cogs), 2) AS sum_sales, 
        COUNT(Invoice_ID) AS total_orders
FROM supermarket_sales
GROUP BY Product_line;
---B. Bạn hãy xây dựng đoạn truy vấn tính tổng doanh số, tổng số đơn hàng của từng loại khách hàng theo từng Productline. (tổng doanh số làm tròn đến 2 chữ số thập phân) (0.5đ)
SELECT  Product_line, Customer_type, 
        ROUND(SUM(cogs), 2) AS sum_sales, 
        COUNT(Invoice_ID) AS total_orders
FROM supermarket_sales
GROUP BY Product_line, Customer_type;

--Câu 3: 
---A. Với tháng có doanh số cao nhất, bạn hãy tìm ra các khung giờ có tổng số đơn hàng cao hơn số lượng đơn hàng trung bình theo giờ của tháng đó. (0.75đ)
WITH SalesByMonth AS (
    SELECT DATEPART(YEAR, Date) * 100 + DATEPART(MONTH, Date) AS month, 
           ROUND(SUM(Unit_price * Quantity), 2) AS total_sales
    FROM supermarket_sales
    GROUP BY DATEPART(YEAR, Date) * 100 + DATEPART(MONTH, Date)
),
MaxSalesMonth AS (
    SELECT TOP 1 month
    FROM SalesByMonth
    ORDER BY total_sales DESC
),
HourlySales AS (
    SELECT DATEPART(HOUR, Time) AS hour, 
           COUNT(Invoice_ID) AS total_order
    FROM supermarket_sales
    WHERE DATEPART(YEAR, Date) * 100 + DATEPART(MONTH, Date) = (SELECT month FROM MaxSalesMonth)
    GROUP BY DATEPART(HOUR, Time)
),
AverageOrders AS (
    SELECT AVG(total_order) AS avg_orders
    FROM HourlySales
)
SELECT hour, total_order
FROM HourlySales
WHERE total_order > (SELECT avg_orders FROM AverageOrders);
---B. Với mỗi Product line, đều có 2 loại khách hàng (Customer Type) mua hàng là Normal, Member. Bạn hãy tìm các Product line có loại khách hàng mua ít đơn hàng nhưng lại có doanh số cao hơn loại khách hàng còn lại.(1đ)
WITH CustomerSales AS (
    SELECT  Product_line, 
            Customer_type, 
            ROUND(SUM(cogs), 2) AS sum_sales, 
            COUNT(Invoice_ID) AS total_orders
    FROM supermarket_sales
    GROUP BY Product_line, Customer_type
),
MaxSales AS (
    SELECT Product_line, MAX(sum_sales) AS max_sales
    FROM CustomerSales
    GROUP BY Product_line
),
MaxOrders AS (
    SELECT Product_line, MIN(total_orders) AS min_orders
    FROM CustomerSales
    GROUP BY Product_line
)
SELECT cs.Product_line, cs.Customer_type, cs.sum_sales, cs.total_orders
FROM CustomerSales cs
JOIN MaxSales ms ON cs.Product_line = ms.Product_line
JOIN MaxOrders mo ON cs.Product_line = mo.Product_line
WHERE cs.sum_sales = ms.max_sales AND cs.total_orders = mo.min_orders;

--Câu 4: Bạn hãy xây dựng đoạn truy vấn tìm ra tổng doanh số, tổng số đơn hàng theo tháng, tổng doanh số và tổng số đơn hàng của các tháng về trước (1đ)
WITH MonthlySales AS (
    SELECT DATEPART(YEAR, Date) * 100 + DATEPART(MONTH, Date) AS month_code,
           DATEPART(YEAR, Date) AS year,
           DATEPART(MONTH, Date) AS month,
           ROUND(SUM(cogs), 2) AS sum_sales,
           COUNT(*) AS total_orders
    FROM supermarket_sales
    GROUP BY DATEPART(YEAR, Date) * 100 + DATEPART(MONTH, Date), DATEPART(YEAR, Date), DATEPART(MONTH, Date)
)
SELECT ms1.year,
       ms1.month,
       ms1.sum_sales,
       ms1.total_orders,
       (SELECT SUM(sum_sales)
        FROM MonthlySales ms2
        WHERE ms2.month_code < ms1.month_code) AS TotalSalesBefore,
       (SELECT SUM(total_orders)
        FROM MonthlySales ms2
        WHERE ms2.month_code < ms1.month_code) AS TotalOrdersBefore
FROM MonthlySales ms1
ORDER BY ms1.year, ms1.month;