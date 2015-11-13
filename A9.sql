-- SPENCER KERBER
-- CIS31018
-- A9

-- PART 1

SELECT CUST_CODE, CUST_BALANCE
FROM LGCUSTOMER
ORDER BY CUST_CODE

SELECT CUST_CODE, SUM(INV_TOTAL) AS TOTAL
FROM LGINVOICE
GROUP BY CUST_CODE
ORDER BY CUST_CODE

DECLARE @CUST_CODE INT
DECLARE @CUST_BALANCE DECIMAL(8,2)

DECLARE BALANCE_CURSOR CURSOR FOR
SELECT 	CUST_CODE, SUM( INV_TOTAL) AS TOTAL
FROM	LGINVOICE
GROUP BY	CUST_CODE

-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- PART 2

CREATE TRIGGER A9_LINE
   ON  LGLINE
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	
	DECLARE @INV_NUM INT
	DECLARE @TOTAL INT

	--INSERT 
	IF	(EXISTS (SELECT * FROM INSERTED) AND
	EXISTS (SELECT * FROM DELETED)
	BEGIN
		DECLARE INSERT_CURSOR CURSOR FOR 
		SELECT INV_NUM, SUM(LINE_PRICE) AS TOTAL
		FROM INSERTED
		GROUP BY INV_NUM
	
		OPEN INSERT_CURSOR
		FETCH NEXT FROM INSERT_CURSOR INTO @INV_NUM, @TOTAL
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			UPDATE LGINVOICE
			SET INV_TOTAL=INV_TOTAL+@TOTAL
			WHERE INV_NUM=@INV_NUM
			FETCH NEXT FROM INSERT_CURSOR INTO @INV_NUM, @TOTAL
		END
	CLOSE INSERT_CURSOR
	DEALLOCATE INSERT_CURSOR
	END

	--DELETE
	  IF(EXISTS (SELECT * FROM DELETED) AND
       NOT EXISTS (SELECT * FROM INSERTED))
    BEGIN
        DECLARE    DELETE_CURSOR CURSOR FOR
        SELECT    INV_NUM, SUM(LINE_PRICE) AS TOTAL
		FROM DELETED
		GROUP BY INV_NUM

		OPEN DELETE_CURSOR
		FETCH NEXT FROM DELETE_CURSOR INTO @INV_NUM, @TOTAL
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			UPDATE LGINVOICE
			SET INV_TOTAL=INV_TOTAL-@TOTAL
			WHERE INV_NUM=@INV_NUM
			FETCH NEXT FROM DELETE_CURSOR INTO @INV_NUM, @TOTAL
		END
	CLOSE DELETE_CURSOR
	DEALLOCATE DELETE_CURSOR
	END

	--UPDATE
	 IF(EXISTS (SELECT * FROM DELETED) AND
       NOT EXISTS (SELECT * FROM INSERTED))
    BEGIN
		DECLARE UPDATE_CURSOR CURSOR FOR 
		SELECT I.INV_NUM, SUM(I.LINE_PRICE-D.LINE_PRICE) AS TOTAL
		FROM DELETED D INNER JOIN INSERTED I
		ON D.INV_NUM = I.INV_NUM AND D.LINE_PRICE = I.LINE_PRICE
		GROUP BY I.INV_NUM

		OPEN UPDATE_CURSOR
		FETCH NEXT FROM UPDATE_CURSOR INTO @INV_NUM, @TOTAL
		WHILE (@@FETCH_STATUS=0)
		BEGIN
			UPDATE LGINVOICE
			SET INV_TOTAL = INV_TOTAL+@TOTAL
			WHERE INV_NUM=@INV_NUM
			FETCH NEXT FROM UPDATE_CURSOR INTO @INV_NUM, @TOTAL
		END
	CLOSE UPDATE_CURSOR
	DEALLOCATE UPDATE_CURSOR
	END


END
GO

CREATE TRIGGER A9_INVOICE 
   ON  LGINVOICE 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	
	DECLARE @CUST_CODE INT
	DECLARE @INV_TOTAL INT

	--INSERT
	IF	(EXISTS (SELECT * FROM INSERTED) AND
	EXISTS (SELECT * FROM DELETED)
	BEGIN
		DECLARE INSERT_CURSOR CURSOR FOR 
		SELECT CUST_CODE, INV_TOTAL
		FROM INSERTED
		GROUP BY CUST_CODE

		OPEN INSERT_CURSOR
		FETCH NEXT FROM INSERT_CURSOR INTO @CUST_CODE, @INV_TOTAL
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			UPDATE LGCUSTOMER
			SET CUST_BALANCE = @INV_TOTAL
			WHERE CUST_CODE=@CUST_CODE
			FETCH NEXT FROM INSERT_CURSOR INTO @CUST_CODE, @INV_TOTAL
		END
	CLOSE INSERT_CURSOR
	DEALLOCATE INSERT_CURSOR
	END

	--DELETE
	  IF(EXISTS (SELECT * FROM DELETED) AND
       NOT EXISTS (SELECT * FROM INSERTED))
    BEGIN
        DECLARE    DELETE_CURSOR CURSOR FOR
        SELECT    CUST_CODE, INV_TOTAL
		FROM DELETED
		GROUP BY CUST_CODE

		OPEN DELETE_CURSOR
		FETCH NEXT FROM DELETE_CURSOR INTO @CUST_CODE, @INV_TOTAL
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			UPDATE LGCUSTOMER
			SET CUST_BALANCE=@INV_TOTAL
			WHERE CUST_CODE=@CUST_CODE
			FETCH NEXT FROM DELETE_CURSOR INTO @CUST_CODE, @INV_TOTAL
		END
	CLOSE DELETE_CURSOR
	DEALLOCATE DELETE_CURSOR
	END

	--UPDATE
	 IF(EXISTS (SELECT * FROM DELETED) AND
       NOT EXISTS (SELECT * FROM INSERTED))
    BEGIN
		DECLARE UPDATE_CURSOR CURSOR FOR 
		SELECT I.CUST_CODE, I.INV_TOTAL
		FROM DELETED D INNER JOIN INSERTED I
		ON D.CUST_CODE = I.CUST_CODE AND D.INV_TOTAL = I.INV_TOTAL
		GROUP BY I.CUST_CODE

		OPEN UPDATE_CURSOR
		FETCH NEXT FROM UPDATE_CURSOR INTO @CUST_CODE, @INV_TOTAL
		WHILE (@@FETCH_STATUS=0)
		BEGIN
			UPDATE LGCUSTOMER
			SET CUST_BALANCE=@INV_TOTAL
			WHERE CUST_CODE=@CUST_CODE
			FETCH NEXT FROM UPDATE_CURSOR INTO @CUST_CODE, @INV_TOTAL
		END
	CLOSE UPDATE_CURSOR
	DEALLOCATE UPDATE_CURSOR
	END

END
GO

-- ===========================================================================

-- PART 3

SELECT *
FROM LGLINE
WHERE INV_NUM IN (334, 335, 336)

SELECT * INTO TEMP
FROM LGLINE
WHERE INV_NUM IN (334, 335, 336)

SELECT *
FROM TEMP

-- DELETE
DELETE 
FROM LGLINE
WHERE INV_NUM IN (334, 335, 336)

-- INSERT 
INSERT INTO LGLINE
SELECT *
FROM TEMP

-- UPDATE 
UPDATE LGLINE
SET LINE_QTY=LINE_QTY + 10
WHERE INV_NUM IN (334, 335, 336)


