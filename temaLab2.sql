-- 1.
CREATE OR REPLACE PROCEDURE ang_gab IS

v_sal emp.sal%TYPE;
v_min_sal_clerk emp.sal%TYPE;
v_mgr emp.mgr%TYPE;
v_deptno emp.deptno%TYPE;

CURSOR dept_clerk IS
	SELECT deptno, mgr
	FROM emp
	WHERE job = 'CLERK';

BEGIN

	SELECT sal INTO v_sal
	FROM emp
	WHERE ename = 'GABRIEL';
	
	DBMS_OUTPUT.PUT_LINE('Salariul lui Gabriel este ' || v_sal 
							|| '. Acesta urmeaza sa fie concediat!');
	DELETE FROM emp
		WHERE ename = 'GABRIEL' 
		AND sal = v_sal;
	
	EXCEPTION 
		WHEN DATA_NOT_FOUND
			THEN
				SELECT MIN(sal) INTO v_min_sal_clerk
				FROM emp
				WHERE job = 'CLERK';
				
				OPEN dept_clerk;
				
					FETCH dept_clerk						
					INTO v_deptno, v_mgr;
				
				CLOSE dept_clerk;
				
				--FOR c_clerk IN dept_clerk LOOP
					--v_deptno := c_clerk.deptno;
					--v_mgr := c_clerk.mgr;
				--END LOOP;
			
				INSERT INTO emp VALUES
				(7321, 'GABRIEL', 'CLERK', v_mgr, TO_DATE(SYSDATE, 'dd/mm/yyyy'), v_min_sal_clerk, NULL, v_deptno);
			
END ang_gab;

----------------------------------------------------------------------------------

-- 2.
CREATE OR REPLACE PROCEDURE add_ang 
	(
		add_empno IN emp.empno%TYPE,
		add_ename IN emp.ename%TYPE,
		add_job IN emp.job%TYPE,
		add_mgr IN emp.mgr%TYPE,
		add_sal IN emp.sal%TYPE,
		add_deptno IN emp.deptno%TYPE
	) IS

CURSOR c_empno IS
	SELECT empno
	FROM emp;

BEGIN
	
	FOR in_emp IN c_empno LOOP
		IF in_emp.empno = add_empno THEN
			RAISE_APPLICATION_ERROR(-20999, 'INSERT FAILED');
		END IF;
	END LOOP;

	INSERT INTO emp VALUES
		(add_empno, add_ename, add_job, add_mgr, TO_DATE(SYSDATE, 'dd/mm/yyyy'), add_sal, NULL, add_deptno);
			
END add_ang;
	
--BEGIN add_ang(7321, 'GABRIEL', 'CLERK', 123, 1000, 10); END;

----------------------------------------------------------------------------------

-- 3.
DECLARE 

e_insert_excep EXCEPTION;
PRAGMA EXCEPTION_INIT(e_insert_excep, -20999);

v_empno emp.empno%TYPE := 7321;

BEGIN

	add_ang(v_empno, 'GABRIEL', 'CLERK', 123, 1000, 10);
	
	EXCEPTION 
		WHEN e_insert_excep
			THEN 
				DELETE FROM emp
					WHERE empno = v_empno;
END;