       IDENTIFICATION DIVISION.

       PROGRAM-ID. TSQL049A.

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

      *    COMP-5 holds the machine's own byte order, COMP is big-endian:
      *    the same number must reach the database from either, and come
      *    back into either.

           01  H-S5    PIC S9(4) COMP-5.
           01  H-I5    PIC S9(9) COMP-5.
           01  H-B5    PIC S9(18) COMP-5.
           01  H-SC    PIC S9(4) COMP.
           01  H-IC    PIC S9(9) COMP.
           01  H-ID    PIC 9(4).
           01  H-D4    PIC 9(4).
           01  H-D9    PIC 9(9).
           01  H-D18   PIC 9(18).

       EXEC SQL
            INCLUDE SQLCA
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

           MOVE 1 TO H-S5.
           MOVE 300 TO H-I5.
           MOVE 5000000000 TO H-B5.
           MOVE 1 TO H-ID.

           EXEC SQL
                INSERT INTO TAB1 (FLD1, FLD2, FLD3, FLD4)
                    VALUES (:H-ID, :H-S5, :H-I5, :H-B5)
           END-EXEC.

           DISPLAY 'INSERT SQLCODE: ' SQLCODE.

           MOVE 0 TO H-S5.
           MOVE 0 TO H-I5.
           MOVE 0 TO H-B5.

           EXEC SQL
                SELECT FLD2, FLD3, FLD4 INTO :H-S5, :H-I5, :H-B5
                    FROM TAB1 WHERE FLD1 = 1
           END-EXEC.

           DISPLAY 'SELECT SQLCODE: ' SQLCODE.
           MOVE H-S5 TO H-D4.
           MOVE H-I5 TO H-D9.
           MOVE H-B5 TO H-D18.
           DISPLAY 'COMP-5: ' H-D4 ' ' H-D9 ' ' H-D18.

      *    The COMP-5 value used as a plain number

           ADD 1 TO H-S5.
           ADD 1 TO H-I5.
           MOVE H-S5 TO H-D4.
           MOVE H-I5 TO H-D9.
           DISPLAY 'COMP-5 + 1: ' H-D4 ' ' H-D9.

           EXEC SQL
                SELECT FLD2, FLD3 INTO :H-SC, :H-IC
                    FROM TAB1 WHERE FLD1 = 1
           END-EXEC.

           MOVE H-SC TO H-D4.
           MOVE H-IC TO H-D9.
           DISPLAY 'COMP: ' H-D4 ' ' H-D9.

           MOVE 7 TO H-SC.
           MOVE 700 TO H-IC.
           MOVE 2 TO H-ID.

           EXEC SQL
                INSERT INTO TAB1 (FLD1, FLD2, FLD3, FLD4)
                    VALUES (:H-ID, :H-SC, :H-IC, 0)
           END-EXEC.

           EXEC SQL
                SELECT FLD2, FLD3 INTO :H-S5, :H-I5
                    FROM TAB1 WHERE FLD1 = 2
           END-EXEC.

           MOVE H-S5 TO H-D4.
           MOVE H-I5 TO H-D9.
           DISPLAY 'COMP in, COMP-5 out: ' H-D4 ' ' H-D9.

           EXEC SQL
                SELECT FLD1 INTO :H-ID FROM TAB1
                    WHERE FLD2 = :H-S5 AND FLD3 = :H-I5
           END-EXEC.

           DISPLAY 'SELECT BY COMP-5 SQLCODE: ' SQLCODE.
           DISPLAY 'SELECT BY COMP-5: ' H-ID.

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
