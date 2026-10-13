       IDENTIFICATION DIVISION.

       PROGRAM-ID. TSQL047A.

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AT.
       OBJECT-COMPUTER. IBM-AT.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.

       FILE SECTION.

       WORKING-STORAGE SECTION.

           01 DATASRC PIC X(64).
           01 DBUSR  PIC X(64).

           01  H-F1    PIC 9(4).
           01  H-F2    PIC X(8).

       EXEC SQL
            INCLUDE SQLCA
       END-EXEC.

       EXEC SQL
            DECLARE CRSR01 CURSOR FOR
               SELECT FLD1, FLD2, FLD3 FROM TAB1 ORDER BY FLD1
       END-EXEC.

       PROCEDURE DIVISION.

       000-CONNECT.

           DISPLAY "DATASRC" UPON ENVIRONMENT-NAME.
           ACCEPT DATASRC FROM ENVIRONMENT-VALUE.
           DISPLAY "DATASRC_USR" UPON ENVIRONMENT-NAME.
           ACCEPT DBUSR FROM ENVIRONMENT-VALUE.

           EXEC SQL
              CONNECT TO :DATASRC USER :DBUSR
           END-EXEC.

           IF SQLCODE <> 0 THEN
              DISPLAY 'CONNECT SQLCODE. ' SQLCODE
              DISPLAY 'CONNECT SQLERRM. ' SQLERRM
              GO TO 100-EXIT
           END-IF.

       100-MAIN.

      *    The result row has more columns than the INTO list: the given
      *    host variables are assigned, SQLCODE is 0 and SQLWARN3 is set.

           EXEC SQL
                SELECT FLD1, FLD2, FLD3 INTO :H-F1, :H-F2
                    FROM TAB1 WHERE FLD1 = 1
           END-EXEC.

           DISPLAY 'SELECT SQLCODE: ' SQLCODE.
           DISPLAY 'SELECT SQLWARN0: [' SQLWARN0 ']'.
           DISPLAY 'SELECT SQLWARN3: [' SQLWARN3 ']'.
           DISPLAY 'SELECT: ' H-F1 ' ' H-F2.

           EXEC SQL
                SELECT FLD1, FLD2 INTO :H-F1, :H-F2
                    FROM TAB1 WHERE FLD1 = 2
           END-EXEC.

           DISPLAY 'SELECT SQLCODE: ' SQLCODE.
           DISPLAY 'SELECT SQLWARN3: [' SQLWARN3 ']'.

           EXEC SQL
                OPEN CRSR01
           END-EXEC.

           EXEC SQL
                FETCH CRSR01 INTO :H-F1, :H-F2
           END-EXEC.

           DISPLAY 'FETCH SQLCODE: ' SQLCODE.
           DISPLAY 'FETCH SQLWARN3: [' SQLWARN3 ']'.
           DISPLAY 'FETCH: ' H-F1 ' ' H-F2.

           EXEC SQL
                FETCH CRSR01 INTO :H-F1, :H-F2
           END-EXEC.

           DISPLAY 'FETCH SQLCODE: ' SQLCODE.
           DISPLAY 'FETCH: ' H-F1 ' ' H-F2.

           EXEC SQL
                FETCH CRSR01 INTO :H-F1, :H-F2
           END-EXEC.

           DISPLAY 'FETCH SQLCODE: ' SQLCODE.

           EXEC SQL
                CLOSE CRSR01
           END-EXEC.

           EXEC SQL
              CONNECT RESET
           END-EXEC.

           IF SQLCODE <> 0 THEN
              DISPLAY 'DISCONNECT SQLCODE. ' SQLCODE
              DISPLAY 'DISCONNECT SQLERRM. ' SQLERRM
              GO TO 100-EXIT
           END-IF.

       100-EXIT.
             STOP RUN.
