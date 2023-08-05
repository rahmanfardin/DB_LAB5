--1 non sub
SELECT
    CUSTOMER_NAME,
    CUSTOMER_CITY,
    CUSTOMER_STREET
FROM
    CUSTOMER
    NATURAL JOIN DEPOSITOR
    NATURAL JOIN ACCOUNT
    NATURAL JOIN BRANCH INTERSECT
    SELECT
        CUSTOMER_NAME,
        BRANCH_CITY,
        CUSTOMER_STREET
    FROM
        CUSTOMER
        NATURAL JOIN DEPOSITOR
        NATURAL JOIN ACCOUNT
        NATURAL JOIN BRANCH;

--1 sub
SELECT
    CUSTOMER_NAME,
    CUSTOMER_STREET,
    CUSTOMER_CITY
FROM
    CUSTOMER  CUS
WHERE
    CUSTOMER_CITY = SOME (
        SELECT
            BRANCH_CITY
        FROM
            BRANCH
            NATURAL JOIN ACCOUNT
            NATURAL JOIN DEPOSITOR
        WHERE
            CUS.CUSTOMER_NAME = DEPOSITOR.CUSTOMER_NAME
    );

--2 non sub
SELECT
    CUSTOMER_NAME,
    CUSTOMER_CITY,
    CUSTOMER_STREET
FROM
    CUSTOMER
    NATURAL JOIN BORROWER
    NATURAL JOIN LOAN
    NATURAL JOIN BRANCH INTERSECT
    SELECT
        CUSTOMER_NAME,
        BRANCH_CITY,
        CUSTOMER_STREET
    FROM
        CUSTOMER
        NATURAL JOIN BORROWER
        NATURAL JOIN LOAN
        NATURAL JOIN BRANCH;

--2 SUB
SELECT
    CUSTOMER_NAME,
    CUSTOMER_STREET,
    CUSTOMER_CITY
FROM
    CUSTOMER CUS
WHERE
    CUS.CUSTOMER_CITY = SOME(
        SELECT
            BRANCH_CITY
        FROM
            BRANCH
            NATURAL JOIN BORROWER
            NATURAL JOIN LOAN
        WHERE
            CUS.CUSTOMER_NAME = BORROWER.CUSTOMER_NAME
    );

--3 without having
WITH BALANCE_FROM_1001 AS(
    SELECT
        BRANCH_NAME,
        BRANCH_CITY,
        SUM(BALANCE) AS SUM_BALANCE,
        AVG(BALANCE) AS AVG_BALANCE
    FROM
        BRANCH
        NATURAL JOIN ACCOUNT
    GROUP BY
        BRANCH_NAME,
        BRANCH_CITY
)
SELECT
    BRANCH_CITY,
    AVG_BALANCE
FROM
    BALANCE_FROM_1001 BF
WHERE
    BF.SUM_BALANCE >= 1000;

--3 with having
SELECT
    BRANCH_CITY,
    AVG(TEMP.AVG_B)
FROM
    (
        SELECT
            BRANCH_NAME,
            AVG(BALANCE) AS AVG_B,
            SUM(BALANCE) AS SUM_B
        FROM
            BRANCH
            NATURAL JOIN ACCOUNT
        GROUP BY
            BRANCH_NAME
        HAVING
            SUM(BALANCE) >=1000
    )      TEMP,
    BRANCH B
WHERE
    B.BRANCH_NAME = TEMP.BRANCH_NAME
GROUP BY
    BRANCH_CITY;

--4 without having
WITH TEMP AS(
    SELECT
        BRANCH_CITY,
        BRANCH_NAME,
        AVG(AMOUNT) AS AVG_AM
    FROM
        LOAN
        NATURAL JOIN BRANCH
    GROUP BY
        BRANCH_CITY,
        BRANCH_NAME
)
SELECT
    TEMP2.BRANCH_CITY,
    AVG(AVG_AM)
FROM
    (
        SELECT
            BRANCH_CITY,
            BRANCH_NAME,
            AVG_AM
        FROM
            TEMP
        WHERE
            1500 < AVG_AM
    )TEMP2,      BRANCH B
WHERE
    B.BRANCH_NAME = TEMP2.BRANCH_NAME
GROUP BY
    TEMP2.BRANCH_CITY;

--4 WITH HAVING
SELECT
    BRANCH_CITY,
    AVG(AVG_L)
FROM
    (
        SELECT
            BRANCH_NAME,
            AVG(AMOUNT) AS AVG_L
        FROM
            LOAN
        WHERE
            BRANCH_NAME = LOAN.BRANCH_NAME
        GROUP BY
            BRANCH_NAME
        HAVING
            AVG(AMOUNT) >= 1500
    )      
    NATURAL JOIN BRANCH
GROUP BY
    BRANCH.BRANCH_CITY;

--5 WITH all
SELECT
    CUSTOMER_NAME, CUSTOMER.CUSTOMER_STREET, CUSTOMER.CUSTOMER_CITY, BALANCE
FROM
    ACCOUNT NATURAL JOIN CUSTOMER NATURAL JOIN DEPOSITOR
WHERE
    BALANCE >= ALL(
        SELECT
            BALANCE
        FROM
            ACCOUNT
    );

--5 WITHOUT ALL
SELECT
    CUSTOMER_NAME, CUSTOMER.CUSTOMER_STREET, CUSTOMER.CUSTOMER_CITY, BALANCE
FROM
    ACCOUNT NATURAL JOIN CUSTOMER NATURAL JOIN DEPOSITOR
WHERE
    BALANCE = (
        SELECT
            MAX(BALANCE)
        FROM
            ACCOUNT
    );