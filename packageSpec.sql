CREATE OR REPLACE PACKAGE manage_emp_pkg 
IS
	PROCEDURE add_emp (
						emp_name IN emp.ename%TYPE,
						emp_salary IN emp.sal%TYPE,
						emp_job IN emp.job%TYPE,
						emp_mgr IN emp.mgr%TYPE
					);
	PROCEDURE delete_emp (
							emp_empno IN NUMBER
						);
	PROCEDURE delete_emp (
							emp_ename IN CHAR
						);		
	PROCEDURE add_dept (
						dept_dname dept.dname%TYPE,
						dept_loc dept.loc%TYPE
						);
	PROCEDURE display_emp (
							v_view CHAR
						);
END manage_emp_pkg;
	