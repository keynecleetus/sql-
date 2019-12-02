CREATE DATABASE transactions;
USE transactions;

CREATE TABLE accounts ( 
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(50)NOT NULL,
    account_no INT NOT NULL, 
    balance DECIMAL NOT NULL DEFAULT 0,
    UNIQUE (account_no),
    UNIQUE(email),
        CHECK(balance >= 0)
);
INSERT INTO accounts (email,account_no,balance)
VALUES ('keyne.loui@gmail.com',100,10000),('sheyne@gmail.com',200,10000);
 
SELECT * FROM  accounts;
INSERT INTO account_transactions(account_no,flag,amount,transaction_date) 
VALUES(100,'-',1000,now());

CREATE TABLE account_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_no INT NOT NULL, 
    flag VARCHAR(10) NOT NULL, 
    amount DECIMAL NOT NULL, 
    transaction_date DATE NOT NULL 
);

DELIMITER $$
SET autocommit=0$$
CREATE PROCEDURE fund_transfer1(
IN amount_transferred int,
IN account_info int,
IN actions VARCHAR(10),
OUT message VARCHAR(50))
BEGIN
 DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
START TRANSACTION;
 

INSERT INTO account_transactions(account_no,flag,amount,transaction_date) 
VALUES(account_info,actions,amount_transferred,now());

 UPDATE accounts
   SET balance = balance - amount_transferred
 WHERE account_no = account_info;
 
 
IF `_rollback` THEN
        ROLLBACK;
        SET message="Transaction failed";
    ELSE
        COMMIT;
          SET message="Transaction Success";
    END IF; 
END$$
CALL fund_transfer1(100,200,'+',@message)$$
select @message$$
SELECT * FROM accounts$$
SELECT * FROM account_transactions$$
