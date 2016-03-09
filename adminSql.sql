--USER
--@D:\app\Vlad-Gabriel\product\11.2.0\dbhome_1\RDBMS\ADMIN\catqueue.sql	
		
DROP USER evomer CASCADE;
CREATE USER evomer IDENTIFIED BY evomer;
GRANT CONNECT, RESOURCE TO evomer;

--ACCESS
CREATE OR REPLACE directory temp_dir AS 'D:\Oracle';
GRANT READ, WRITE ON directory temp_dir TO evomer;

--LOGIN TABLE
CREATE TABLE log_table (
						user_id VARCHAR2(30),
						logon_date DATE
						);
CREATE OR REPLACE TRIGGER logon_trigg
AFTER LOGON ON DATABASE
BEGIN
	INSERT INTO log_table (user_id, logon_date)
	VALUES (USER, SYSDATE);
END;