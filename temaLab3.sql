-- 1.
BEGIN 
	DBMS_OUTPUT.PUT_LINE('EMPNO' || '  '|| 'ENAME' || '          '|| 'JOB'
										|| '       '|| 'MGR' || '    '|| 'HIREDATE' || '      '|| 'SAL'
										|| '  '|| 'COMM' || '  '|| 'DEPTNO');
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
	manage_emp_pkg.display_emp('CONSOLE');
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
	manage_emp_pkg.add_emp('GABRIEL', 800, 'CLERK', 7902);
	DBMS_OUTPUT.PUT_LINE('EMPNO' || '  '|| 'ENAME' || '          '|| 'JOB'
										|| '       '|| 'MGR' || '    '|| 'HIREDATE' || '      '|| 'SAL'
										|| '  '|| 'COMM' || '  '|| 'DEPTNO');
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
	manage_emp_pkg.display_emp('CONSOLE');
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
	manage_emp_pkg.delete_emp('GABRIEL');
	manage_emp_pkg.display_emp('FILE');
END;

--USER
--CREATE USER evomer IDENTIFIED BY evomer;
--GRANT CONNECT, RESOURCE TO evomer;
--ACCESS
--CREATE OR REPLACE directory temp_dir AS 'D:\Oracle';
--GRANT READ, WRITE ON directory temp_dir TO evomer;