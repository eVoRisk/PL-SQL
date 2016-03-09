-- 1.
CREATE TYPE increase AS OBJECT (
								empno NUMBER(4),
								percent NUMBER(2)							
								);
								
CREATE TYPE nestedID AS TABLE OF increase;

CREATE TABLE cresteriSalariale(
								newSal NUMBER(7,2) NULL
								) /

CREATE OR REPLACE PROCEDURE modificaSalar(
						empID nestedID
						) IS

CURSOR empINFO IS
	SELECT empno, sal
	FROM emp;

BEGIN
	FOR i IN empID.FIRST..empID.LAST
	LOOP
		FOR j IN empINFO LOOP
			IF empID(i).empno = j.empno THEN
				j.sal := j.sal + j.sal * (empID(i).percent / 100);
				
				UPDATE emp
					SET sal = j.sal
					WHERE empno = j.empno;
					
				INSERT INTO cresteriSalariale 
					VALUES (j.sal);
					
			END IF;
		END LOOP;
	END LOOP;
		
END modificaSalar;	

DECLARE 
	emp increase := increase(7369, 2);
	empID nestedID := nestedID(emp);					
BEGIN
	modificaSalar(empID);
END;

-- 2.
DECLARE
	TYPE firstCol IS VARRAY(3) OF INTEGER;
	TYPE secondCol IS VARRAY(3) OF firstCol;
	TYPE courseCol IS TABLE OF VARCHAR2(1);
	
	firstRow firstCol := firstCol(1, 2, 3);
	lastRow firstCol := firstCol(7, 8, 9);
	matrix secondCol := secondCol(firstRow, firstCol(4, 5, 6), lastRow);
	courseList courseCol := courseCol('S', 'G', 'X');
	
	val INTEGER;
	
BEGIN 
	courseList.DELETE(3);
	courseList.EXTEND;
	courseList(4) := 'D';
	courseList(3) := 'B';
	DBMS_OUTPUT.PUT_LINE(courseList(1) || ' ' || courseList(2) || ' '|| courseList(3) || ' ' || courseList(4));
	
	DBMS_OUTPUT.PUT_LINE('Last row elements');
	val := lastRow.FIRST;
	
	WHILE val IS NOT NULL 
	LOOP
		DBMS_OUTPUT.PUT(val || ' ');
		val := lastRow.NEXT(val);
	END LOOP;
	
	DBMS_OUTPUT.PUT_LINE(' ');
	DBMS_OUTPUT.PUT_LINE('Add matrix');
	FOR i IN 1..firstRow.COUNT 
	LOOP
		FOR j IN firstRow.FIRST..firstRow.LAST
		LOOP
			val := matrix(i)(j) + matrix((firstRow.COUNT + 1) - i)((firstRow.COUNT + 1) - j);
			DBMS_OUTPUT.PUT(val || ' ');
		END LOOP;
		DBMS_OUTPUT.PUT_LINE(' ');
	END LOOP;
END;