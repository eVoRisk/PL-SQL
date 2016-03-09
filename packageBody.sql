CREATE OR REPLACE PACKAGE BODY manage_emp_pkg 
IS
	FUNCTION random_empno (
							min_empno IN emp.empno%TYPE,
							max_empno IN emp.empno%TYPE
						) RETURN NUMBER IS
	BEGIN
		RETURN TRUNC((max_empno - min_empno + 1) * ABS(DBMS_RANDOM.VALUE) + min_empno);
	END random_empno;
	
----------------------------------------------------------------------------------	

	FUNCTION exists_empno (
							v_empno IN emp.empno%TYPE
						) RETURN BOOLEAN IS

	CURSOR empno_cursor IS
		SELECT empno
		FROM emp;
		
	BEGIN
	
		FOR emp_c IN empno_cursor LOOP
			IF v_empno = emp_c.empno THEN
				RETURN TRUE;
			END IF;
		END LOOP;
		
		RETURN FALSE;
	END exists_empno;
	
----------------------------------------------------------------------------------	
	
	FUNCTION unique_empno RETURN NUMBER IS
	
	CURSOR empno_cursor IS
		SELECT empno
		FROM emp;
	
	v_min_empno emp.empno%TYPE;
	v_max_empno emp.empno%TYPE;
	v_empno emp.empno%TYPE;
	
	BEGIN 
		
		SELECT MIN(empno), MAX(empno) INTO v_min_empno, v_max_empno
		FROM emp;
		
		LOOP
			v_empno := random_empno(v_min_empno, v_max_empno);
			IF exists_empno(v_empno) = FALSE THEN
				RETURN v_empno;
			END IF;
		END LOOP;
		
	END unique_empno;
	
----------------------------------------------------------------------------------	
	
	PROCEDURE add_emp (
						emp_name IN emp.ename%TYPE,
						emp_salary IN emp.sal%TYPE,
						emp_job IN emp.job%TYPE,
						emp_mgr IN emp.mgr%TYPE
						) IS
		
	CURSOR deptno_cursor IS
		SELECT UNIQUE deptno
		FROM emp;
		
	v_min_job_dept NUMBER(2);
	v_min_job NUMBER(2) := 99;
	emp_empno emp.empno%TYPE;
	emp_deptno emp.empno%TYPE;
		
	BEGIN
		emp_empno := unique_empno();
			
		FOR dept_no IN deptno_cursor LOOP
			SELECT COUNT(job) INTO v_min_job_dept
			FROM emp
			WHERE 
				job = emp_job 
			AND
				deptno = dept_no.deptno;
						
			IF v_min_job_dept < v_min_job THEN
				v_min_job := v_min_job_dept;
				emp_deptno := dept_no.deptno;
			END IF;
		END LOOP;
			
		IF v_min_job = 99 THEN
			OPEN deptno_cursor;
				
				FETCH deptno_cursor
				INTO emp_deptno;
					
			INSERT INTO emp VALUES
				(emp_empno, emp_name, emp_job, emp_mgr, TO_DATE(SYSDATE, 'dd/mm/yyyy'), emp_salary, NULL, emp_deptno);
				
			CLOSE deptno_cursor;
			
		ELSE
			INSERT INTO emp VALUES
				(emp_empno, emp_name, emp_job, emp_mgr, TO_DATE(SYSDATE, 'dd/mm/yyyy'), emp_salary, NULL, emp_deptno);	
		END IF;
		
	END add_emp;
	
----------------------------------------------------------------------------------
	FUNCTION exists_ename (
							emp_ename IN emp.ename%TYPE
						) RETURN BOOLEAN IS
	
	CURSOR ename_cursor IS
		SELECT ename
		FROM emp;
		
	BEGIN
		FOR name_curs IN ename_cursor LOOP
			IF emp_ename = name_curs.ename THEN
				RETURN TRUE;
			END IF;
		END LOOP;
		
		RETURN FALSE;
	END exists_ename;
	
----------------------------------------------------------------------------------	
	
	PROCEDURE delete_emp (
							emp_empno IN NUMBER
						) IS
	
	v_emp_number NUMBER(2);
	v_emp_deptno emp.deptno%TYPE;
	empno_not_found EXCEPTION;
						
	BEGIN
	
		IF exists_empno(emp_empno) = FALSE THEN 
			RAISE empno_not_found;
		ELSE
			SELECT deptno INTO v_emp_deptno
			FROM emp
			WHERE empno = emp_empno;
			
			SELECT COUNT(empno) INTO v_emp_number
			FROM emp
			WHERE deptno = v_emp_deptno;
			
			IF v_emp_number = 1 THEN
				DELETE FROM emp
					WHERE empno = emp_empno;
				DELETE FROM dept
					WHERE deptno = v_emp_deptno;
			ELSE
				DELETE FROM emp
					WHERE empno = emp_empno;
			END IF;
		END IF;
		
		EXCEPTION 
			WHEN empno_not_found THEN
				DBMS_OUTPUT.PUT_LINE('ANGAJATUL NU EXISTA IN BAZA DE DATE');
	END delete_emp;

----------------------------------------------------------------------------------	
	
	PROCEDURE delete_emp (
							emp_ename IN CHAR
						) IS
	
	v_emp_number NUMBER(2);
	v_emp_deptno emp.deptno%TYPE;
	ename_not_found EXCEPTION;
						
	BEGIN
	
		IF exists_ename(emp_ename) = FALSE THEN 
			RAISE ename_not_found;
		ELSE
			SELECT deptno INTO v_emp_deptno
			FROM emp
			WHERE ename = emp_ename;
			
			SELECT COUNT(empno) INTO v_emp_number
			FROM emp
			WHERE deptno = v_emp_deptno;
			
			IF v_emp_number = 1 THEN
				DELETE FROM emp
					WHERE ename = emp_ename;
				DELETE FROM dept
					WHERE deptno = v_emp_deptno;
			ELSE
				DELETE FROM emp
					WHERE ename = emp_ename;
			END IF;
		END IF;
		
		EXCEPTION 
			WHEN ename_not_found THEN
				DBMS_OUTPUT.PUT_LINE('ANGAJATUL NU EXISTA IN BAZA DE DATE');
	END delete_emp;

----------------------------------------------------------------------------------	
	
	PROCEDURE add_dept (
						dept_dname dept.dname%TYPE,
						dept_loc dept.loc%TYPE
						) IS
	
	v_max_dept dept.deptno%TYPE;
	
	BEGIN
		SELECT MAX(deptno) INTO v_max_dept
		FROM dept;
		v_max_dept := v_max_dept + 10;
		INSERT INTO dept
			VALUES(v_max_dept, dept_dname, dept_loc);
	END add_dept;

----------------------------------------------------------------------------------	
	
	PROCEDURE display_emp (
							v_view CHAR
						) IS
	CURSOR display_cursor IS
		SELECT *
		FROM emp;
	
	not_con_file EXCEPTION;
	file UTL_FILE.FILE_TYPE;
	
	BEGIN
		IF v_view = 'CONSOLE' THEN
			FOR display IN display_cursor LOOP
					DBMS_OUTPUT.PUT_LINE(display.empno || '   '|| display.ename || '   '|| display.job
										|| '   '|| display.mgr || '   '|| display.hiredate || '   '|| display.sal
										|| '   '|| display.comm || '   '|| display.deptno);
			END LOOP;
		ELSE
			IF v_view = 'FILE' AND NOT UTL_FILE.IS_OPEN(file) THEN
				file := UTL_FILE.FOPEN ('TEMP_DIR', 'empTable.txt', 'w');
				
				UTL_FILE.PUT_LINE(file, 'EMPNO' || '  '|| 'ENAME' || '          '|| 'JOB'
										|| '       '|| 'MGR' || '    '|| 'HIREDATE' || '      '|| 'SAL'
										|| '  '|| 'COMM' || '  '|| 'DEPTNO');
				UTL_FILE.PUT_LINE(file, '--------------------------------------------------------------------------------');
				
				FOR display IN display_cursor LOOP
					UTL_FILE.PUT_LINE(file, display.empno || '   '|| display.ename || '   '|| display.job
										|| '   '|| display.mgr || '   '|| display.hiredate || '   '|| display.sal
										|| '   '|| display.comm || '   '|| display.deptno);
				END LOOP;
				
				UTL_FILE.FCLOSE(file);
			ELSE
				RAISE not_con_file;
			END IF;
		END IF;	
		
		EXCEPTION 
			WHEN UTL_FILE.INVALID_FILEHANDLE THEN
				RAISE_APPLICATION_ERROR(-20001, 'Invalid File.');
				
			WHEN UTL_FILE.WRITE_ERROR THEN
				RAISE_APPLICATION_ERROR (-20002, 'Unable towrite to file');
				
			WHEN not_con_file THEN
				DBMS_OUTPUT.PUT_LINE('ARGUMENT INVALID!');
	END display_emp;
	
END manage_emp_pkg;	