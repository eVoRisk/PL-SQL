-- 1.
CREATE OR REPLACE PROCEDURE mareste_salar 
	(
		mgr_id IN emp.mgr%TYPE
	) IS
	
v_mgr_sal emp.sal%TYPE;

BEGIN
	SELECT sal INTO v_mgr_sal
	FROM EMP
	WHERE mgr = mgr_id;
	
	UPDATE emp
	SET sal = sal + v_mgr_sal * 0.01
	WHERE mgr = mgr_id;
END mareste_salar;
	
----------------------------------------------------------------------------------
	
CREATE OR REPLACE PROCEDURE data_ang
	(
		hire_day IN NUMBER
	) IS
	
CURSOR ang_name IS
	SELECT ename, sal
	FROM emp
	WHERE TO_NUMBER (EXTRACT (DAY FROM hiredate)) > hire_day;
	
v_mgr_id emp.mgr%TYPE;
v_min_sal emp.sal%type := 99999;
is_manager EXCEPTION;

BEGIN
	FOR a_name_min IN ang_name LOOP
		DBMS_OUTPUT.PUT_LINE(a_name_min.ename);
		IF a_name_min.sal < v_min_sal THEN
			v_min_sal := a_name_min.sal;
		END IF;
	END LOOP;
	
	SELECT mgr INTO v_mgr_id
	FROM EMP
	WHERE sal = v_min_sal;
	
	IF v_mgr_id IS NULL THEN
		RAISE is_manager;
	END IF;
	
	mareste_salar(v_mgr_id);
	
	EXCEPTION
		WHEN is_manager THEN
			DBMS_OUTPUT.PUT_LINE(SQLERRM);
END data_ang;

----------------------------------------------------------------------------------

-- 2.
CREATE OR REPLACE FUNCTION salariu_net 
	(
		emp_no emp.empno%TYPE
	) RETURN NUMBER IS 

v_ang_sal emp.sal%TYPE;
v_tax salgrade.tax%TYPE;
	
BEGIN
	SELECT sal INTO v_ang_sal
	FROM emp
	WHERE empno = emp_no;

	SELECT tax INTO v_tax
	FROM salgrade
	WHERE losal < v_ang_sal 
		AND
			hisal > v_ang_sal;
			
	RETURN TO_NUMBER(v_ang_sal + v_ang_sal * v_tax);
	
	EXCEPTION
		WHEN NO_DATA_FOUND THEN RETURN NULL;
END salariu_net;

----------------------------------------------------------------------------------

-- 3.
DROP TABLE salarnet
CREATE TABLE salarnet
	(
		empno NUMBER(4) NOT NULL,
		sal NUMBER(7,2) NULL
	);

DECLARE
	CURSOR emp_no IS
		SELECT empno
		FROM emp;

v_sal_net emp.sal%TYPE;

BEGIN
	FOR e_no IN emp_no LOOP
		v_sal_net := salariu_net(e_no.empno);
		INSERT INTO salarnet(empno, sal)
		VALUES (e_no.empno, v_sal_net);
	END LOOP;
END;
