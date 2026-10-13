       IDENTIFICATION DIVISION.

       PROGRAM-ID. TSQL046A.

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

      *    Binary input host variables holding as many digits as their
      *    picture allows (and a sign): the text they are bound as must
      *    keep every digit.
           01  H-S4    PIC S9(4)  COMP.
           01  H-U4    PIC 9(4)   COMP.
           01  H-S9    PIC S9(9)  COMP.
           01  H-U9    PIC 9(9)   COMP.
           01  H-S18   PIC S9(18) COMP.
           01  H-CNT   PIC S9(9)  COMP.

           01  H-OUT   PIC S9(18) COMP.
           01  D-OUT   PIC -9(18).
           01  D-CNT   PIC 9(4).

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

           MOVE 1801 TO H-S4.
           MOVE 9999 TO H-U4.
           MOVE -999999999 TO H-S9.
           MOVE 999999999 TO H-U9.
           MOVE -999999999999999999 TO H-S18.

           EXEC SQL
                INSERT INTO TAB1(FLD1, FLD2, FLD3, FLD4, FLD5)
                    VALUES(:H-S4, :H-U4, :H-S9, :H-U9, :H-S18)
           END-EXEC.

           DISPLAY 'INSERT SQLCODE: ' SQLCODE.

           MOVE -9999 TO H-S4.

           EXEC SQL
                INSERT INTO TAB1(FLD1, FLD2, FLD3, FLD4, FLD5)
                    VALUES(:H-S4, :H-U4, :H-S9, :H-U9, :H-S18)
           END-EXEC.

           DISPLAY 'INSERT SQLCODE: ' SQLCODE.

           EXEC SQL
                SELECT FLD1 INTO :H-OUT FROM TAB1 WHERE FLD1 > 0
           END-EXEC.
           MOVE H-OUT TO D-OUT.
           DISPLAY 'FLD1: ' D-OUT.

           EXEC SQL
                SELECT FLD1 INTO :H-OUT FROM TAB1 WHERE FLD1 < 0
           END-EXEC.
           MOVE H-OUT TO D-OUT.
           DISPLAY 'FLD1: ' D-OUT.

           EXEC SQL
                SELECT FLD2 INTO :H-OUT FROM TAB1 WHERE FLD1 > 0
           END-EXEC.
           MOVE H-OUT TO D-OUT.
           DISPLAY 'FLD2: ' D-OUT.

           EXEC SQL
                SELECT FLD3 INTO :H-OUT FROM TAB1 WHERE FLD1 > 0
           END-EXEC.
           MOVE H-OUT TO D-OUT.
           DISPLAY 'FLD3: ' D-OUT.

           EXEC SQL
                SELECT FLD4 INTO :H-OUT FROM TAB1 WHERE FLD1 > 0
           END-EXEC.
           MOVE H-OUT TO D-OUT.
           DISPLAY 'FLD4: ' D-OUT.

           EXEC SQL
                SELECT FLD5 INTO :H-OUT FROM TAB1 WHERE FLD1 > 0
           END-EXEC.
           MOVE H-OUT TO D-OUT.
           DISPLAY 'FLD5: ' D-OUT.

      *    The same host variables as WHERE parameters.
           EXEC SQL
                SELECT COUNT(*) INTO :H-CNT FROM TAB1
                    WHERE FLD1 = :H-S4 AND FLD2 = :H-U4
                      AND FLD3 = :H-S9 AND FLD4 = :H-U9
                      AND FLD5 = :H-S18
           END-EXEC.
           MOVE H-CNT TO D-CNT.
           DISPLAY 'COUNT SQLCODE: ' SQLCODE.
           DISPLAY 'COUNT: ' D-CNT.

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
