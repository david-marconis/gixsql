       IDENTIFICATION DIVISION.

       PROGRAM-ID. TSQL048A.

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
           01  H-MIN   PIC 9(4) VALUE 0.

       EXEC SQL
            INCLUDE SQLCA
       END-EXEC.

      *    String literals in a cursor's query: dots and runs of blanks
      *    in them must reach the database unchanged.

       EXEC SQL
            DECLARE CRSR01 CURSOR FOR
               SELECT FLD1 FROM TAB1
                   WHERE FLD2 = '00.00.00' AND FLD1 > :H-MIN
                   ORDER BY FLD1
       END-EXEC.

       EXEC SQL
            DECLARE CRSR02 CURSOR FOR
               SELECT FLD1 FROM TAB1
                   WHERE FLD2 = 'a.b.c.d.e' OR FLD2 = 'x   y'
                   ORDER BY FLD1
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

           EXEC SQL
                OPEN CRSR01
           END-EXEC.

           EXEC SQL
                FETCH CRSR01 INTO :H-F1
           END-EXEC.

           DISPLAY 'CRSR01 SQLCODE: ' SQLCODE.
           DISPLAY 'CRSR01: ' H-F1.

           EXEC SQL
                FETCH CRSR01 INTO :H-F1
           END-EXEC.

           DISPLAY 'CRSR01 SQLCODE: ' SQLCODE.

           EXEC SQL
                CLOSE CRSR01
           END-EXEC.

           EXEC SQL
                OPEN CRSR02
           END-EXEC.

           EXEC SQL
                FETCH CRSR02 INTO :H-F1
           END-EXEC.

           DISPLAY 'CRSR02 SQLCODE: ' SQLCODE.
           DISPLAY 'CRSR02: ' H-F1.

           EXEC SQL
                FETCH CRSR02 INTO :H-F1
           END-EXEC.

           DISPLAY 'CRSR02 SQLCODE: ' SQLCODE.
           DISPLAY 'CRSR02: ' H-F1.

           EXEC SQL
                FETCH CRSR02 INTO :H-F1
           END-EXEC.

           DISPLAY 'CRSR02 SQLCODE: ' SQLCODE.

           EXEC SQL
                CLOSE CRSR02
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
