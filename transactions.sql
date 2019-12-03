CREATE DATABASE transactions;
USE transactions;

CREATE TABLE accounts ( 
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(50)NOT NULL,
    account_no INT NOT NULL, 
    balance DECIMAL NOT NULL DEFAULT 0,
    CONSTRAINT  uk_account_no UNIQUE (account_no),
    CONSTRAINT uk_email UNIQUE  (email),
    CONSTRAINT ck_balance  CHECK(balance >= 0)
);

INSERT INTO accounts (email,account_no,balance)
VALUES ('keyne.loui@gmail.com',100,10000),('sheyne@gmail.com',200,10000);
 
SELECT * FROM  accounts;
INSERT INTO account_transactions(account_no,transaction_type,amount,transaction_date) 
VALUES(100,'credit',1000,now());

CREATE TABLE account_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account_no INT NOT NULL, 
    to_account_no INT NOT NULL,
    transaction_type VARCHAR(10) NOT NULL, 
    amount DECIMAL(10,2) NOT NULL, 
    transaction_date DATE NOT NULL 
);

create table log(
     id int auto_increment primary key,
     account_no int not null,
     amount decimal(10,4)not null,
     date timestamp not null,
     status varchar(40) not null default 'failed'
     );
         
drop procedure fund_transfer;
DELIMITER $$
SET autocommit=0$$
CREATE PROCEDURE fund_transfer(
IN amount_transferred int,
IN from_account_no int,
IN to_account_no int,
IN actions VARCHAR(10),
OUT message VARCHAR(50))
BEGIN
 DECLARE `_rollback` BOOL DEFAULT 0;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
    select from_account_no,amount_transferred;
     
    
     ROLLBACK TO account_transactions ;
     insert into log(account_no,amount,date)values(from_account_no,amount_transferred,current_timestamp());
    
    SET message="Transaction failed";
  
    END;
START TRANSACTION;
 
        savepoint account_transactions;

      INSERT INTO account_transactions(
      from_account_no,to_account_no,transaction_type,amount,transaction_date) 
         VALUES(
         from_account_no,to_account_no,actions,amount_transferred,now());
 
 insert into log 
 (account_no,amount,date,status)
 values
 (from_account_no,amount_transferred,current_timestamp(),'success');
 
 UPDATE accounts
   SET balance = balance - amount_transferred
 WHERE account_no = from_account_no;
 
 
 COMMIT;
          SET message="Transaction Success";
          savepoint end;
END$$
CALL fund_transfer(100088,200,100,'debit',@message)$$
SELECT @message$$
select * from accounts$$
select * from account_transactions$$
select * from log;
