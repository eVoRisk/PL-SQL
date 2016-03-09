-- 1.
CREATE OR REPLACE TYPE Depart AS OBJECT (
									deptno NUMBER(2),
									dname CHAR(14)
									);
									
-- 2.
CREATE OR REPLACE TYPE Employee AS OBJECT (
									empno NUMBER(4),
									ename CHAR(10),
									dept REF Depart,
									sal NUMBER(7, 2),
									ORDER MEMBER FUNCTION sort (employee Employee) RETURN INTEGER									
									) NOT FINAL;

-- 3.
CREATE OR REPLACE TYPE Manager UNDER Employee (
										nrEmp INTEGER,	
										OVERRIDING MEMBER FUNCTION sort (TREAT( VALUE(employee) AS Manager)) RETURN INTEGER
										);

-- 4.
CREATE TYPE BODY Manager AS
	OVERRRIDING MEMBER FUNTION sort (manager Manager) RETURN INTEGER IS
	BEGIN
		IF nrEmp < manager.nrEmp THEN
			RETURN -1;
		ELSIF nrEmp > manager.nrEmp THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	END;
END;

CREATE TYPE nestedManager AS TABLE OF Manager;

CREATE OR REPLACE PROCEDURE ManagerList IS 
	CURSOR ManagerINFO IS
		SELECT DISTINCT(e.empno), e.ename, d.deptno, d.dname, e.sal
		FROM emp e, emp m, dept d
		WHERE e.deptno = d.deptno
			AND e.empno = m.mgr;
			
	listOfManager nestedManager;
	manager Manager;
	nrEmpMan INTEGER;
	sortRez INTEGER;
	dept Depart;
	
BEGIN
	FOR infoMan IN ManagerINFO LOOP
		
		SELECT COUNT(empno) INTO nrEmpMan
		FROM emp
		WHERE mgr = infoMan.empno;
		
		dept.deptno := infoMan.deptno;
		dept.dname := infoMan.dname;
		manager := Manager(infoMan.empno, infoMan.ename, infoMan.deptno, infoMan.dname, infoMan.sal, nrEmpMan);
		listOfManager := nestedManager(manager);
	END LOOP;
	
	FOR i IN 1..(listOfManager.COUNT - 1) 
	LOOP
		FOR j IN i..listOfManager.COUNT 
		LOOP
			sortRez := listOfManager(i).sort(listOfManager(j));
			IF sortRez = -1 THEN
				manager := listOfManager(i);
				listOfManager(i) := listOfManager(j);
				listOfManager(j) := manager;
			END IF;
		END LOOP;
	END LOOP;
	
	DBMS_OUTPUT.PUT_LINE("EMPNO" || "ENAME" || "DEPTNO" || "DNAME" || "SAL");
	FOR i IN listOfManager.FIRST..listOfManager.LAST
	LOOP
		DBMS_OUTPUT.PUT_LINE(listOfManager(i).empno || listOfManager(i).ename
		|| listOfManager(i).deptno || listOfManager(i).dname || listOfManager(i).sal);
	END LOOP;
	
END ManagerList;
