       IDENTIFICATION DIVISION.

       PROGRAM-ID. TSQL045A.

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AT.
       OBJECT-COMPUTER. IBM-AT.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.

       FILE SECTION.

       WORKING-STORAGE SECTION.

           01  H-TS     PIC X(26).
           01  H-SCHEMA PIC X(08).

       EXEC SQL
            INCLUDE SQLCA
       END-EXEC.

       PROCEDURE DIVISION.

       100-MAIN.

      *    DB2's assignment form of SET reads a special register into a
      *    host variable. The target is a result, so this has to become a
      *    one-row query with H-TS bound as an output. Bound as an input
      *    instead, H-TS is never written and SQLCODE is still 0.

           EXEC SQL
                SET :H-TS = CURRENT_TIMESTAMP
           END-EXEC.

      *    The other form of SET assigns to the register itself. The host
      *    variable is genuinely an input here, so this one stays a
      *    passthru.

           MOVE 'PUBLIC' TO H-SCHEMA.

           EXEC SQL
                SET CURRENT SCHEMA = :H-SCHEMA
           END-EXEC.

       100-EXIT.
             STOP RUN.
