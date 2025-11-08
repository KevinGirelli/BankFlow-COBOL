       REPORT-SECTION SECTION.
       *> START MOVEMENT REPORT
       GENERATE-REPORT.
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY ">>> Account Activity Report <<<"
           PERFORM READ-ACCOUNT-INPUT
           IF WS-VALID-OK NOT = "Y"
               EXIT PARAGRAPH
           END-IF

           PERFORM RESET-REPORT-TEXT
           PERFORM GET-ACCOUNT-CUSTOMER
           IF WS-REPORT-CUSTOMER-ID = ZERO
               DISPLAY "Account not found."
               PERFORM LOG-CLEAR
               MOVE "REPORT" TO WS-LOG-TYPE
               MOVE "ERROR" TO WS-LOG-STATUS-TEXT
               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
               MOVE 1 TO WS-LOG-POINTER
               STRING "account="
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      " not found" DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               EXIT PARAGRAPH
           END-IF

           MOVE ZERO TO WS-TOTAL-BY-CUSTOMER
           MOVE "00" TO WS-TRANSACTION-STATUS
           OPEN INPUT TRANSACTION-FILE
           IF WS-TRANSACTION-STATUS NOT = "00"
               DISPLAY "Error opening transaction file. STATUS: "
                   WS-TRANSACTION-STATUS
               CLOSE TRANSACTION-FILE
               MOVE "00" TO WS-TRANSACTION-STATUS
               PERFORM LOG-CLEAR
               MOVE "REPORT" TO WS-LOG-TYPE
               MOVE "FILE" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               STRING "open failure STATUS="
                      WS-TRANSACTION-STATUS DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               EXIT PARAGRAPH
           END-IF

           OPEN EXTEND REPORT-FILE
           MOVE SPACES TO WS-TEMP-REPORT-LINE
           STRING
               "ACCOUNT ACTIVITY REPORT" DELIMITED BY SIZE
               INTO WS-TEMP-REPORT-LINE
           END-STRING
           WRITE REPORT-RECORD FROM WS-TEMP-REPORT-LINE

           MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
           MOVE SPACES TO WS-TEMP-REPORT-LINE
           STRING
               "Account: " DELIMITED BY SIZE
               FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING) DELIMITED BY SIZE
               INTO WS-TEMP-REPORT-LINE
           END-STRING
           WRITE REPORT-RECORD FROM WS-TEMP-REPORT-LINE

           MOVE WS-REPORT-CUSTOMER-ID TO WS-NUMERIC-DISPLAY
           MOVE SPACES TO WS-TEMP-REPORT-LINE
           STRING
               "Customer ID: " DELIMITED BY SIZE
               FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING) DELIMITED BY SIZE
               INTO WS-TEMP-REPORT-LINE
           END-STRING
           WRITE REPORT-RECORD FROM WS-TEMP-REPORT-LINE

           MOVE WS-LINE-SEPARATOR TO WS-TEMP-REPORT-LINE
           WRITE REPORT-RECORD FROM WS-TEMP-REPORT-LINE

           MOVE "N" TO WS-OPERATION-FOUND

           PERFORM UNTIL WS-TRANSACTION-STATUS NOT = "00"
               READ TRANSACTION-FILE
                   AT END
                       MOVE "99" TO WS-TRANSACTION-STATUS
                   NOT AT END
                       IF TRANS-ACCOUNT-NUMBER = WS-INPUT-ACCOUNT
                           MOVE TRANS-AMOUNT TO WS-AMOUNT-FORMAT
                           MOVE "Y" TO WS-OPERATION-FOUND
                           PERFORM DISPLAY-TRANSACTION
                           PERFORM WRITE-TRANSACTION-REPORT
                       END-IF
               END-READ
           END-PERFORM

           CLOSE TRANSACTION-FILE
           MOVE "00" TO WS-TRANSACTION-STATUS
           CLOSE REPORT-FILE
           MOVE "00" TO WS-REPORT-STATUS

           PERFORM CALCULATE-CUSTOMER-TOTAL-BALANCE

           IF WS-OPERATION-FOUND NOT = "Y"
               DISPLAY "No transactions found for the provided account."
               PERFORM LOG-CLEAR
               MOVE "REPORT" TO WS-LOG-TYPE
               MOVE "EMPTY" TO WS-LOG-STATUS-TEXT
               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
               MOVE 1 TO WS-LOG-POINTER
               STRING "account="
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      " no activity" DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           ELSE
               DISPLAY "Report generated successfully at: "
                   FUNCTION TRIM(WS-REPORT-PATH TRAILING)
               PERFORM LOG-CLEAR
               MOVE "REPORT" TO WS-LOG-TYPE
               MOVE "SUCCESS" TO WS-LOG-STATUS-TEXT
               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
               MOVE 1 TO WS-LOG-POINTER
               STRING "account="
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      " file="
                      FUNCTION TRIM(WS-REPORT-PATH TRAILING) DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               PERFORM METRICS-RECORD-SUCCESS
           END-IF.
       *> END MOVEMENT REPORT

       RESET-REPORT-TEXT.
           OPEN OUTPUT REPORT-FILE
           MOVE WS-LINE-SEPARATOR TO REPORT-RECORD
           WRITE REPORT-RECORD
           CLOSE REPORT-FILE
           MOVE "00" TO WS-REPORT-STATUS.

       DISPLAY-TRANSACTION.
           DISPLAY "Date/Time: " TRANS-DATETIME
           DISPLAY "Type.....: " FUNCTION TRIM(TRANS-TYPE TRAILING)
           DISPLAY "Amount...: " WS-AMOUNT-FORMAT
           DISPLAY WS-LINE-SEPARATOR.

       WRITE-TRANSACTION-REPORT.
           STRING
               "Date/Time: " DELIMITED BY SIZE
               TRANS-DATETIME DELIMITED BY SIZE
               " | Type: " DELIMITED BY SIZE
               FUNCTION TRIM(TRANS-TYPE TRAILING) DELIMITED BY SIZE
               " | Amount: " DELIMITED BY SIZE
               WS-AMOUNT-FORMAT DELIMITED BY SIZE
               INTO WS-TEMP-REPORT-LINE
           END-STRING
           WRITE REPORT-RECORD FROM WS-TEMP-REPORT-LINE
           IF WS-REPORT-STATUS NOT = "00"
               DISPLAY "Failed to write report. STATUS: "
                   WS-REPORT-STATUS
           END-IF.

       GET-ACCOUNT-CUSTOMER.
           MOVE ZERO TO WS-REPORT-CUSTOMER-ID
           MOVE ZERO TO WS-INDEX-RESULT-POS
           IF WS-INDEX-ENABLED = "Y"
               PERFORM INDEX-FIND-ACCOUNT-BY-NUMBER
               IF WS-INDEX-RESULT-POS > ZERO
                   MOVE WS-ACCOUNT-INDEX-CLIENT-ID(WS-INDEX-RESULT-POS)
                       TO WS-REPORT-CUSTOMER-ID
                   MOVE WS-ACCOUNT-INDEX-BALANCE(WS-INDEX-RESULT-POS)
                       TO WS-AMOUNT-FORMAT
                   EXIT PARAGRAPH
               END-IF
           END-IF
           OPEN INPUT ACCOUNT-FILE
           IF WS-ACCOUNT-STATUS = "00"
               PERFORM UNTIL WS-ACCOUNT-STATUS NOT = "00"
                   READ ACCOUNT-FILE
                       AT END
                           MOVE "99" TO WS-ACCOUNT-STATUS
                       NOT AT END
                           IF ACCOUNT-NUMBER = WS-INPUT-ACCOUNT
                               MOVE ACCOUNT-CLIENT-ID TO WS-REPORT-CUSTOMER-ID
                               MOVE ACCOUNT-BALANCE TO WS-AMOUNT-FORMAT
                               MOVE "99" TO WS-ACCOUNT-STATUS
                           END-IF
                   END-READ
               END-PERFORM
           END-IF
           CLOSE ACCOUNT-FILE
           MOVE "00" TO WS-ACCOUNT-STATUS.

       CALCULATE-CUSTOMER-TOTAL-BALANCE.
           IF WS-REPORT-CUSTOMER-ID = ZERO
               EXIT PARAGRAPH
           END-IF

           IF WS-INDEX-ENABLED = "Y"
               MOVE ZERO TO WS-TOTAL-BY-CUSTOMER
               PERFORM VARYING WS-INDEX-ITER FROM 1 BY 1
                       UNTIL WS-INDEX-ITER > WS-ACCOUNT-INDEX-COUNT
                   IF WS-ACCOUNT-INDEX-CLIENT-ID(WS-INDEX-ITER)
                        = WS-REPORT-CUSTOMER-ID
                       ADD WS-ACCOUNT-INDEX-BALANCE(WS-INDEX-ITER)
                           TO WS-TOTAL-BY-CUSTOMER
                   END-IF
               END-PERFORM
               MOVE WS-TOTAL-BY-CUSTOMER TO WS-AMOUNT-FORMAT
               DISPLAY "Total balance for customer (all accounts): "
                   WS-AMOUNT-FORMAT
               OPEN EXTEND REPORT-FILE
               MOVE SPACES TO WS-TEMP-REPORT-LINE
               STRING
                   "Total customer balance: " DELIMITED BY SIZE
                   WS-AMOUNT-FORMAT DELIMITED BY SIZE
                   INTO WS-TEMP-REPORT-LINE
               END-STRING
               WRITE REPORT-RECORD FROM WS-TEMP-REPORT-LINE
               CLOSE REPORT-FILE
               MOVE "00" TO WS-REPORT-STATUS
               EXIT PARAGRAPH
           END-IF

           MOVE ZERO TO WS-TOTAL-BY-CUSTOMER
           OPEN INPUT ACCOUNT-FILE
           IF WS-ACCOUNT-STATUS = "00"
               PERFORM UNTIL WS-ACCOUNT-STATUS NOT = "00"
                   READ ACCOUNT-FILE
                       AT END
                           MOVE "99" TO WS-ACCOUNT-STATUS
                       NOT AT END
                           IF ACCOUNT-CLIENT-ID = WS-REPORT-CUSTOMER-ID
                               ADD ACCOUNT-BALANCE TO WS-TOTAL-BY-CUSTOMER
                           END-IF
                   END-READ
               END-PERFORM
           END-IF
           CLOSE ACCOUNT-FILE
           MOVE "00" TO WS-ACCOUNT-STATUS
           MOVE WS-TOTAL-BY-CUSTOMER TO WS-AMOUNT-FORMAT
           DISPLAY "Total balance for customer (all accounts): "
               WS-AMOUNT-FORMAT
           OPEN EXTEND REPORT-FILE
           MOVE SPACES TO WS-TEMP-REPORT-LINE
           STRING
               "Total customer balance: " DELIMITED BY SIZE
               WS-AMOUNT-FORMAT DELIMITED BY SIZE
               INTO WS-TEMP-REPORT-LINE
           END-STRING
           WRITE REPORT-RECORD FROM WS-TEMP-REPORT-LINE
           CLOSE REPORT-FILE
           MOVE "00" TO WS-REPORT-STATUS.

