-- 1.
DECLARE

	v_CursorID NUMBER;
	v_CursorInsert NUMBER;
	v_CreateTableString VARCHAR2(500);
	v_InsertRecords VARCHAR2(500);
	v_MatchRecord VARCHAR2(500);
	v_SelectRecords VARCHAR2(500);
	
	v_NUMRows INTEGER;
	v_boss VARCHAR2(20);
	v_empno NUMBER(4);
	v_TOTRow INTEGER;
	v_telefon VARCHAR2(10);
	
BEGIN
	v_CursorID := DBMS_SQL.OPEN_CURSOR;
	
	v_MatchRecord := '
					DECLARE v_max_comm emp.comm%TYPE;
					BEGIN
						SELECT MAX(comm) INTO v_max_comm
						FROM emp;
						
						SELECT ename INTO :boss
						FROM emp
						WHERE comm = v_max_comm;
					END;
					';
	DBMS_SQL.PARSE(v_CursorID, v_MatchRecord, DBMS_SQL.NATIVE);
	DBMS_SQL.BIND_VARIABLE(v_CursorID, ':boss', v_boss, 20);
    v_NUMRows := DBMS_SQL.EXECUTE(v_CursorID);
	DBMS_SQL.VARIABLE_VALUE(v_CursorID,':boss',v_boss);
	
	DBMS_OUTPUT.PUT_LINE('CONTRACT_ORANGE_' || TRIM(v_boss));
	
	v_CreateTableString := '
							CREATE 
							TABLE CONTRACT_ORANGE_' || TRIM(v_boss) || '(
														empno_val NUMBER(4) NULL,
														telefon VARCHAR2(10) NULL
														)							
							';
	DBMS_SQL.PARSE(v_CursorID, v_CreateTableString, DBMS_SQL.NATIVE);
	v_NUMRows := DBMS_SQL.EXECUTE(v_CursorID);
	
	
	v_SelectRecords := '
						SELECT empno
						FROM emp
						ORDER BY sal DESC
						';
	DBMS_SQL.PARSE(v_CursorID, v_SelectRecords, DBMS_SQL.NATIVE);
	DBMS_SQL.DEFINE_COLUMN(v_CursorID, 1, v_empno);
	v_NUMRows := DBMS_SQL.EXECUTE(v_CursorID);
	
	v_CursorInsert := DBMS_SQL.OPEN_CURSOR;
	
	v_InsertRecords := '
							INSERT INTO CONTRACT_ORANGE_' || TRIM(v_boss) 
							|| ' VALUES(:v_empno_val, :v_telefon_val)';
	DBMS_SQL.PARSE(v_CursorInsert, v_InsertRecords, DBMS_SQL.NATIVE);
	
	LOOP
		IF DBMS_SQL.FETCH_ROWS(v_CursorID) = 0 THEN
			EXIT;
		END IF;
		
		v_TOTRow := DBMS_SQL.LAST_ROW_COUNT;
		
		IF v_TOTRow < 10 THEN
			v_telefon := '07410000' || '0' || TO_CHAR(v_TOTRow);
		ELSE
			v_telefon := '07410000' || TO_CHAR(v_TOTRow);
		END IF;
		
		DBMS_SQL.COLUMN_VALUE(v_CursorID, 1, v_empno);
		
		DBMS_SQL.BIND_VARIABLE(v_CursorInsert, ':v_empno_val', v_empno);
		DBMS_SQL.BIND_VARIABLE(v_CursorInsert, ':v_telefon_val', v_telefon, 10);
		
		v_NUMRows := DBMS_SQL.EXECUTE(v_CursorInsert);
	
	END LOOP;
	
	DBMS_SQL.CLOSE_CURSOR(v_CursorInsert);
	
	EXCEPTION
		WHEN OTHERS THEN
			IF SQLCODE = -955 THEN
				DBMS_OUTPUT.PUT_LINE('TABLE ALREADY EXISTS!');
			END IF;
	DBMS_SQL.CLOSE_CURSOR(v_CursorID);
				
END;

-- SELECT FROM NEW TABLE
DECLARE

    v_CursorID  NUMBER;
    v_SelectRecords  VARCHAR2(500); 
    v_NUMRows  INTEGER; 
    v_empno NUMBER(4);
    v_tel VARCHAR2(10);

BEGIN

    v_CursorID := DBMS_SQL.OPEN_CURSOR; 
    v_SelectRecords := 'SELECT * FROM CONTRACT_ORANGE_MARTIN';
    DBMS_SQL.PARSE(v_CursorID,v_SelectRecords,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_CursorID,1,v_empno);
    DBMS_SQL.DEFINE_COLUMN(v_CursorID,2,v_tel,10);
    v_NumRows := DBMS_SQL.EXECUTE(v_CursorID);

LOOP
    IF DBMS_SQL.FETCH_ROWS(v_CursorID) = 0 THEN
        EXIT;
	END IF;
    DBMS_SQL.COLUMN_VALUE(v_CursorId,1,v_empno);
    DBMS_SQL.COLUMN_VALUE(v_CursorId,2,v_tel);
    DBMS_OUTPUT.PUT_LINE(v_empno || ' ' || v_tel);
 
 END LOOP;
 
	DBMS_SQL.CLOSE_CURSOR(v_CursorID);

 END; 

