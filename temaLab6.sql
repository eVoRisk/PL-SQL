-- 1.
CREATE OR REPLACE VIEW emp_sal AS
	SELECT ename
	FROM emp
	WHERE sal > 1500
	ORDER BY ename;
	
-- 2.
CREATE OR REPLACE VIEW all_owner AS
	SELECT OBJECT_NAME, OBJECT_TYPE 
	FROM SYS.ALL_OBJECTS
	WHERE OBBJECT_TYPE IN ( 'VIEW', 'TABLE', 'TRIGGER', 'PROCEDURE', 'PACKAGE', 'FUNCTION' )
		AND OWNER = 'evomer';
		
-- 3.
CREATE OR REPLACE PROCEDURE make_view (
										view_name_val IN VARCHAR2
										) AUTHID CURRENT_USER IS										
	exists_view EXCEPTION;
	v_count_trigger INTEGER;
	
BEGIN
			
	SELECT COUNT(VIEW_NAME) INTO v_count_trigger
	FROM USER_VIEWS
	WHERE VIEW_NAME = view_name_val;
	
	IF v_count_trigger = 0 THEN
		EXECUTE IMMEDIATE
			'CREATE OR REPLACE VIEW val_view_name AS
				SELECT ename
				FROM emp';	

		EXECUTE IMMEDIATE
		'RENAME val_view_name TO ' || view_name_val;
	ELSE
		RAISE exists_view;
	END IF;
	
	EXCEPTION 
		WHEN exists_view THEN
			DBMS_OUTPUT.PUT_LINE('Exista deja un view cu acest nume!!!');
END;

-- 4.
-- Definesc o constrangere pe tabela EMP pentru a asigura empno unice
ALTER TABLE emp
ADD CONSTRAINT UNQ_KEY UNIQUE (empno);

ALTER TABLE emp
DROP CONSTRAINT UNQ_KEY;

-- Posesorii si numele tabelelor la care avem acces
SELECT OWNER, TABLE_NAME
FROM ALL_TABLES
WHERE TABLE_NAME LIKE '%EMP%';

-- Constrangeri pe tabele
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE, TABLE_NAME
FROM USER_CONSTRAINTS;

--drepturile transmise prin intermediul rolurilor nu se pot specifica pentru sistem