create database transactions;
use transactions;

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
 
select * from  accounts;
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
set autocommit=0$$
CREATE PROCEDURE fund_transfer(
IN amount_transferred int,
IN account_info int,
IN actions VARCHAR(10))
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
    ELSE
        COMMIT;
    END IF; 
END$$
call fund_transfer(100,100,'+')$$
select * from accounts$$
select * from account_transactions$$
