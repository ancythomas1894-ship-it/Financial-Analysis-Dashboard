CREATE DATABASE ecomm;
USE ecomm;
SHOW TABLES;
SELECT * FROM customer_churn;
SET SQL_SAFE_UPDATES= 0;
UPDATE customer_churn
SET WarehouseToHome = (
    SELECT ROUND(AVG(WarehouseToHome))
    FROM (
        SELECT WarehouseToHome
        FROM customer_churn
        WHERE WarehouseToHome IS NOT NULL
    ) AS temp
)
WHERE WarehouseToHome IS NULL;

SET SQL_SAFE_UPDATES = 1;
SELECT COUNT(*)
FROM customer_churn
WHERE WarehouseToHome IS NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE customer_churn
SET OrderAmountHikeFromlastYear = (
    SELECT ROUND(AVG(OrderAmountHikeFromlastYear))
    FROM (
        SELECT OrderAmountHikeFromlastYear
        FROM customer_churn
        WHERE OrderAmountHikeFromlastYear IS NOT NULL
    ) AS temp
)
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn
SET DaySinceLastOrder = (
    SELECT ROUND(AVG(DaySinceLastOrder))
    FROM (
        SELECT DaySinceLastOrder
        FROM customer_churn
        WHERE DaySinceLastOrder IS NOT NULL
    ) AS temp
)
WHERE DaySinceLastOrder IS NULL;

UPDATE customer_churn c
JOIN (
    SELECT Tenure
    FROM customer_churn
    WHERE Tenure IS NOT NULL
    GROUP BY Tenure
    ORDER BY COUNT(*) DESC, Tenure
    LIMIT 1
) m
ON c.Tenure IS NULL
SET c.Tenure = m.Tenure;

UPDATE customer_churn c
JOIN (
    SELECT CouponUsed
    FROM customer_churn
    WHERE CouponUsed IS NOT NULL
    GROUP BY CouponUsed
    ORDER BY COUNT(*) DESC, CouponUsed
    LIMIT 1
) m
ON c.CouponUsed IS NULL
SET c.CouponUsed = m.CouponUsed;

UPDATE customer_churn c
JOIN (
    SELECT OrderCount
    FROM customer_churn
    WHERE OrderCount IS NOT NULL
    GROUP BY OrderCount
    ORDER BY COUNT(*) DESC, OrderCount
    LIMIT 1
) m
ON c.OrderCount IS NULL
SET c.OrderCount = m.OrderCount;

DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;

ALTER TABLE customer_churn
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

ALTER TABLE customer_churn
ADD ComplaintReceived VARCHAR(3);

ALTER TABLE customer_churn
ADD ChurnStatus VARCHAR(10);

UPDATE customer_churn
SET ComplaintReceived =
CASE
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END;

UPDATE customer_churn
SET ChurnStatus =
CASE
    WHEN Churn = 1 THEN 'Churned'
    ELSE 'Active'
END;

SELECT ChurnStatus, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;

SELECT
    AVG(Tenure) AS AverageTenure,
    SUM(CashbackAmount) AS TotalCashback
FROM customer_churn
WHERE Churn = 1;

SELECT
    SUM(CASE WHEN Complain = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
    AS ComplaintPercentage
FROM customer_churn
WHERE Churn = 1;

SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE Churn = 1
AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;

SELECT PreferredPaymentMode, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE Churn = 0
GROUP BY PreferredPaymentMode
ORDER BY CustomerCount DESC
LIMIT 1;

SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike
FROM customer_churn
WHERE MaritalStatus = 'Single'
AND PreferredOrderCat = 'Mobile Phone';

SELECT AVG(NumberOfDeviceRegistered) AS AverageDevices
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;

SELECT Gender, SUM(CouponUsed) AS TotalCoupons
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCoupons DESC
LIMIT 1;

SELECT
    PreferredOrderCat,
    COUNT(*) AS CustomerCount,
    MAX(HoursSpentOnApp) AS MaximumHours
FROM customer_churn
GROUP BY PreferredOrderCat;

SELECT SUM(OrderCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
AND SatisfactionScore = (
    SELECT MAX(SatisfactionScore)
    FROM customer_churn
);

SELECT AVG(SatisfactionScore) AS AverageSatisfactionScore
FROM customer_churn
WHERE Complain = 1;

SELECT PreferredOrderCat, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY CustomerCount DESC
LIMIT 1;

SELECT
    PreferredOrderCat,
    AVG(CashbackAmount) AS AverageCashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AverageCashback DESC
LIMIT 3;

SELECT PreferredPaymentMode
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING ROUND( AVG(Tenure),0) = 10
AND SUM(OrderCount)>500;

SELECT
    CASE
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus;

SELECT *
FROM customer_churn
WHERE MaritalStatus = 'Married'
AND CityTier = 1
AND OrderCount > (
    SELECT AVG(OrderCount)
    FROM customer_churn
);

CREATE TABLE customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount INT
);

INSERT INTO customer_returns
(ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

SELECT
    r.*,
    c.*
FROM customer_returns r
JOIN customer_churn c
ON r.CustomerID = c.CustomerID
WHERE c.Churn = 1
AND c.Complain = 1;

ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

SET SQL_SAFE_UPDATES = 1;


 
