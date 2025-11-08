       ACCOUNT-SECTION SECTION.
       *> START ACCOUNT CREATION
       CREATE-ACCOUNT.
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY ">>> Account Creation <<<"
           PERFORM CALCULATE-NEXT-ACCOUNT-NUMBER

           DISPLAY "Enter customer ID: "
           ACCEPT WS-ACCOUNT-CLIENT-ENTRY
           MOVE FUNCTION TRIM(WS-ACCOUNT-CLIENT-ENTRY TRAILING)
               TO WS-ACCOUNT-CLIENT-ENTRY
           IF WS-ACCOUNT-CLIENT-ENTRY = SPACES
               DISPLAY "Customer ID is required."
               EXIT PARAGRAPH
           END-IF
           COMPUTE WS-ACCOUNT-CLIENT-IN =
               FUNCTION NUMVAL (WS-ACCOUNT-CLIENT-ENTRY)
               ON SIZE ERROR
                   DISPLAY "Customer ID is invalid."
                   EXIT PARAGRAPH
           END-COMPUTE

           IF WS-ACCOUNT-CLIENT-IN <= 0
               DISPLAY "Customer ID must be positive."
               EXIT PARAGRAPH
           END-IF

           PERFORM VERIFY-CUSTOMER-EXISTS
           IF WS-OPERATION-FOUND NOT = "Y"
               DISPLAY "Customer not found. Register the customer first."
               PERFORM LOG-CLEAR
               MOVE "ACCOUNT" TO WS-LOG-TYPE
               MOVE "ERROR" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               STRING "missing customer id="
                      FUNCTION TRIM(WS-ACCOUNT-CLIENT-ENTRY TRAILING)
                      DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-NEXT-ACCOUNT-NUMBER TO ACCOUNT-NUMBER
           MOVE WS-ACCOUNT-CLIENT-IN TO ACCOUNT-CLIENT-ID
           MOVE ZERO TO ACCOUNT-BALANCE

           OPEN EXTEND ACCOUNT-FILE
           WRITE ACCOUNT-RECORD
           IF WS-ACCOUNT-STATUS NOT = "00"
               DISPLAY "Error creating account. STATUS: " WS-ACCOUNT-STATUS
               PERFORM LOG-CLEAR
               MOVE "ACCOUNT" TO WS-LOG-TYPE
               MOVE "ERROR" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               STRING "creation failure STATUS="
                      WS-ACCOUNT-STATUS DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           ELSE
               DISPLAY "Account created successfully! Number: "
                   WS-NEXT-ACCOUNT-NUMBER
               PERFORM INDEX-REGISTER-ACCOUNT
               PERFORM LOG-CLEAR
               MOVE "ACCOUNT" TO WS-LOG-TYPE
               MOVE "SUCCESS" TO WS-LOG-STATUS-TEXT
               MOVE WS-NEXT-ACCOUNT-NUMBER TO WS-NUMERIC-DISPLAY
               MOVE 1 TO WS-LOG-POINTER
               STRING "account=" DELIMITED BY SIZE
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      " customer=" DELIMITED BY SIZE
                      FUNCTION TRIM(WS-ACCOUNT-CLIENT-ENTRY TRAILING)
                      DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           END-IF
           CLOSE ACCOUNT-FILE
           MOVE "00" TO WS-ACCOUNT-STATUS.
       *> END ACCOUNT CREATION

       CALCULATE-NEXT-ACCOUNT-NUMBER.
           MOVE ZERO TO WS-NEXT-ACCOUNT-NUMBER
           MOVE "00" TO WS-ACCOUNT-STATUS
           OPEN INPUT ACCOUNT-FILE
           IF WS-ACCOUNT-STATUS = "00"
               PERFORM UNTIL WS-ACCOUNT-STATUS NOT = "00"
                   READ ACCOUNT-FILE
                       AT END
                           MOVE "99" TO WS-ACCOUNT-STATUS
                       NOT AT END
                           IF ACCOUNT-NUMBER > WS-NEXT-ACCOUNT-NUMBER
                               MOVE ACCOUNT-NUMBER TO WS-NEXT-ACCOUNT-NUMBER
                           END-IF
                   END-READ
               END-PERFORM
           END-IF
           CLOSE ACCOUNT-FILE
           MOVE "00" TO WS-ACCOUNT-STATUS
           ADD 1 TO WS-NEXT-ACCOUNT-NUMBER.

       *> START DEPOSIT
       DEPOSIT-INTO-ACCOUNT.
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY ">>> Account Deposit <<<"
           PERFORM READ-ACCOUNT-INPUT
           IF WS-VALID-OK NOT = "Y"
               EXIT PARAGRAPH
           END-IF
           PERFORM READ-AMOUNT-INPUT
           IF WS-VALID-OK NOT = "Y"
               EXIT PARAGRAPH
           END-IF

           PERFORM UPDATE-BALANCE
           IF WS-OPERATION-FOUND = "Y"
               MOVE "3" TO WS-OPTION
               PERFORM RECORD-TRANSACTION
               DISPLAY "Deposit completed successfully."
               PERFORM LOG-CLEAR
               MOVE "DEPOSIT" TO WS-LOG-TYPE
               MOVE "SUCCESS" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
               STRING "account=" DELIMITED BY SIZE
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      " amount=" DELIMITED BY SIZE
                      WS-AMOUNT-ENTRY DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           ELSE
               DISPLAY "Account not found."
               PERFORM LOG-CLEAR
               MOVE "DEPOSIT" TO WS-LOG-TYPE
               MOVE "ERROR" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
               STRING "missing account="
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           END-IF.
       *> END DEPOSIT

       *> START WITHDRAWAL
       WITHDRAW-FROM-ACCOUNT.
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY ">>> Account Withdrawal <<<"
           PERFORM READ-ACCOUNT-INPUT
           IF WS-VALID-OK NOT = "Y"
               EXIT PARAGRAPH
           END-IF
           PERFORM READ-AMOUNT-INPUT
           IF WS-VALID-OK NOT = "Y"
               EXIT PARAGRAPH
           END-IF

           MOVE "N" TO WS-OPERATION-FOUND
           MOVE ZERO TO WS-INDEX-RESULT-POS
           IF WS-INDEX-ENABLED = "Y"
               PERFORM INDEX-FIND-ACCOUNT-BY-NUMBER
               IF WS-INDEX-RESULT-POS = ZERO
                   DISPLAY "Account not found."
                   PERFORM LOG-CLEAR
                   MOVE "WITHDRAWAL" TO WS-LOG-TYPE
                   MOVE "ERROR" TO WS-LOG-STATUS-TEXT
                   MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
                   MOVE 1 TO WS-LOG-POINTER
                   STRING "missing account="
                          FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                          DELIMITED BY SIZE
                          INTO WS-LOG-MESSAGE
                          WITH POINTER WS-LOG-POINTER
                   END-STRING
                   PERFORM LOG-WRITE
                   EXIT PARAGRAPH
               END-IF
           END-IF
           MOVE "00" TO WS-ACCOUNT-STATUS
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCOUNT-STATUS NOT = "00"
               DISPLAY "Error opening account file. STATUS: "
                   WS-ACCOUNT-STATUS
               PERFORM LOG-CLEAR
               MOVE "WITHDRAWAL" TO WS-LOG-TYPE
               MOVE "FILE" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               STRING "open failure STATUS=" WS-ACCOUNT-STATUS
                      DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               CLOSE ACCOUNT-FILE
               MOVE "00" TO WS-ACCOUNT-STATUS
               EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL WS-ACCOUNT-STATUS NOT = "00"
                   OR WS-OPERATION-FOUND = "Y"
               READ ACCOUNT-FILE NEXT RECORD
                   AT END
                       MOVE "99" TO WS-ACCOUNT-STATUS
                   NOT AT END
                       IF ACCOUNT-NUMBER = WS-INPUT-ACCOUNT
                           IF ACCOUNT-BALANCE >= WS-INPUT-AMOUNT
                               SUBTRACT WS-INPUT-AMOUNT FROM ACCOUNT-BALANCE
                               REWRITE ACCOUNT-RECORD
                               IF WS-ACCOUNT-STATUS = "00"
                                   MOVE "Y" TO WS-OPERATION-FOUND
                                   PERFORM INDEX-SET-ACCOUNT-BALANCE
                               ELSE
                                   DISPLAY "Failed to update account. STATUS: "
                                       WS-ACCOUNT-STATUS
                               END-IF
                           ELSE
                               DISPLAY "Insufficient funds."
                               MOVE "99" TO WS-ACCOUNT-STATUS
                               PERFORM LOG-CLEAR
                               MOVE "WITHDRAWAL" TO WS-LOG-TYPE
                               MOVE "BALANCE" TO WS-LOG-STATUS-TEXT
                               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
                               MOVE 1 TO WS-LOG-POINTER
                               STRING "account=" DELIMITED BY SIZE
                                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                                      DELIMITED BY SIZE
                                      " amount=" DELIMITED BY SIZE
                                      WS-AMOUNT-ENTRY DELIMITED BY SIZE
                                      INTO WS-LOG-MESSAGE
                                      WITH POINTER WS-LOG-POINTER
                               END-STRING
                               PERFORM LOG-WRITE
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE ACCOUNT-FILE
           MOVE "00" TO WS-ACCOUNT-STATUS

           IF WS-OPERATION-FOUND = "Y"
               MOVE "4" TO WS-OPTION
               PERFORM RECORD-TRANSACTION
               DISPLAY "Withdrawal completed successfully."
               PERFORM LOG-CLEAR
               MOVE "WITHDRAWAL" TO WS-LOG-TYPE
               MOVE "SUCCESS" TO WS-LOG-STATUS-TEXT
               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
               MOVE 1 TO WS-LOG-POINTER
               STRING "account=" DELIMITED BY SIZE
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      " amount=" DELIMITED BY SIZE
                      WS-AMOUNT-ENTRY DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           ELSE
               DISPLAY "Account not found or operation error."
               PERFORM LOG-CLEAR
               MOVE "WITHDRAWAL" TO WS-LOG-TYPE
               MOVE "ERROR" TO WS-LOG-STATUS-TEXT
               MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
               MOVE 1 TO WS-LOG-POINTER
               STRING "account=" DELIMITED BY SIZE
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      " not found" DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           END-IF.
       *> END WITHDRAWAL

    *> START BALANCE INQUIRY
    CHECK-BALANCE.
        DISPLAY WS-LINE-SEPARATOR
        DISPLAY ">>> Balance Inquiry <<<"
        PERFORM READ-ACCOUNT-INPUT
        IF WS-VALID-OK NOT = "Y"
            EXIT PARAGRAPH
        END-IF

        MOVE "N" TO WS-OPERATION-FOUND
        MOVE ZERO TO WS-INDEX-RESULT-POS
        IF WS-INDEX-ENABLED = "Y"
            PERFORM INDEX-GET-ACCOUNT-BALANCE
            IF WS-OPERATION-FOUND = "Y"
                DISPLAY "Current balance: " WS-AMOUNT-FORMAT
                PERFORM LOG-CLEAR
                MOVE "BALANCE" TO WS-LOG-TYPE
                MOVE "SUCCESS" TO WS-LOG-STATUS-TEXT
                MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
                MOVE 1 TO WS-LOG-POINTER
                STRING "account=" DELIMITED BY SIZE
                       FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                       DELIMITED BY SIZE
                       " balance=" DELIMITED BY SIZE
                       WS-AMOUNT-FORMAT DELIMITED BY SIZE
                       INTO WS-LOG-MESSAGE
                       WITH POINTER WS-LOG-POINTER
                END-STRING
                PERFORM LOG-WRITE
                EXIT PARAGRAPH
            END-IF
        END-IF
        MOVE "00" TO WS-ACCOUNT-STATUS
        OPEN INPUT ACCOUNT-FILE
        IF WS-ACCOUNT-STATUS NOT = "00"
            DISPLAY "Error opening account file. STATUS: "
                WS-ACCOUNT-STATUS
            CLOSE ACCOUNT-FILE
            MOVE "00" TO WS-ACCOUNT-STATUS
            EXIT PARAGRAPH
        END-IF

        PERFORM UNTIL WS-ACCOUNT-STATUS NOT = "00"
                OR WS-OPERATION-FOUND = "Y"
            READ ACCOUNT-FILE
                AT END
                    MOVE "99" TO WS-ACCOUNT-STATUS
                NOT AT END
                    IF ACCOUNT-NUMBER = WS-INPUT-ACCOUNT
                        MOVE ACCOUNT-BALANCE TO WS-AMOUNT-FORMAT
                        DISPLAY "Current balance: " WS-AMOUNT-FORMAT
                        MOVE "Y" TO WS-OPERATION-FOUND
                        PERFORM LOG-CLEAR
                        MOVE "BALANCE" TO WS-LOG-TYPE
                        MOVE "SUCCESS" TO WS-LOG-STATUS-TEXT
                        MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
                        MOVE 1 TO WS-LOG-POINTER
                        STRING "account=" DELIMITED BY SIZE
                               FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                               DELIMITED BY SIZE
                               " balance=" DELIMITED BY SIZE
                               WS-AMOUNT-FORMAT DELIMITED BY SIZE
                               INTO WS-LOG-MESSAGE
                               WITH POINTER WS-LOG-POINTER
                        END-STRING
                        PERFORM LOG-WRITE
                    END-IF
            END-READ
        END-PERFORM
        CLOSE ACCOUNT-FILE
        MOVE "00" TO WS-ACCOUNT-STATUS

        IF WS-OPERATION-FOUND NOT = "Y"
            DISPLAY "Account not found."
            PERFORM LOG-CLEAR
            MOVE "BALANCE" TO WS-LOG-TYPE
            MOVE "ERROR" TO WS-LOG-STATUS-TEXT
            MOVE WS-INPUT-ACCOUNT TO WS-NUMERIC-DISPLAY
            MOVE 1 TO WS-LOG-POINTER
            STRING "account=" DELIMITED BY SIZE
                   FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                   DELIMITED BY SIZE
                   " not found" DELIMITED BY SIZE
                   INTO WS-LOG-MESSAGE
                   WITH POINTER WS-LOG-POINTER
            END-STRING
            PERFORM LOG-WRITE
        END-IF.
    *> END BALANCE INQUIRY

    READ-ACCOUNT-INPUT.
        MOVE "N" TO WS-VALID-OK
        DISPLAY "Account number: "
        ACCEPT WS-ACCOUNT-ENTRY
        MOVE FUNCTION TRIM(WS-ACCOUNT-ENTRY TRAILING)
            TO WS-ACCOUNT-ENTRY
        IF WS-ACCOUNT-ENTRY = SPACES
            DISPLAY "Account number is required."
            EXIT PARAGRAPH
        END-IF
        COMPUTE WS-INPUT-ACCOUNT = FUNCTION NUMVAL (WS-ACCOUNT-ENTRY)
            ON SIZE ERROR
                DISPLAY "Account number is invalid."
                EXIT PARAGRAPH
        END-COMPUTE
        IF WS-INPUT-ACCOUNT <= 0
            DISPLAY "Account number must be positive."
            EXIT PARAGRAPH
        END-IF
        MOVE "Y" TO WS-VALID-OK.

    READ-AMOUNT-INPUT.
        MOVE "N" TO WS-VALID-OK
        DISPLAY "Amount (e.g. 100.50): "
        ACCEPT WS-AMOUNT-ENTRY
        MOVE FUNCTION TRIM(WS-AMOUNT-ENTRY TRAILING)
            TO WS-AMOUNT-ENTRY
        IF WS-AMOUNT-ENTRY = SPACES
            DISPLAY "Amount cannot be empty."
            EXIT PARAGRAPH
        END-IF
        INSPECT WS-AMOUNT-ENTRY CONVERTING "," TO "."
        COMPUTE WS-INPUT-AMOUNT =
            FUNCTION NUMVAL (WS-AMOUNT-ENTRY)
            ON SIZE ERROR
                DISPLAY "Amount provided is invalid."
                EXIT PARAGRAPH
        END-COMPUTE
        IF WS-INPUT-AMOUNT <= ZERO
            DISPLAY "Amount must be greater than zero."
            EXIT PARAGRAPH
        END-IF
        MOVE "Y" TO WS-VALID-OK.

    UPDATE-BALANCE.
        MOVE "N" TO WS-OPERATION-FOUND
        MOVE ZERO TO WS-INDEX-RESULT-POS
        IF WS-INDEX-ENABLED = "Y"
            PERFORM INDEX-FIND-ACCOUNT-BY-NUMBER
            IF WS-INDEX-RESULT-POS = ZERO
                EXIT PARAGRAPH
            END-IF
        END-IF
        MOVE "00" TO WS-ACCOUNT-STATUS
        OPEN I-O ACCOUNT-FILE
        IF WS-ACCOUNT-STATUS NOT = "00"
            DISPLAY "Error opening account file. STATUS: "
                WS-ACCOUNT-STATUS
            CLOSE ACCOUNT-FILE
            MOVE "00" TO WS-ACCOUNT-STATUS
            EXIT PARAGRAPH
        END-IF

        PERFORM UNTIL WS-ACCOUNT-STATUS NOT = "00"
                OR WS-OPERATION-FOUND = "Y"
            READ ACCOUNT-FILE NEXT RECORD
                AT END
                    MOVE "99" TO WS-ACCOUNT-STATUS
                NOT AT END
                    IF ACCOUNT-NUMBER = WS-INPUT-ACCOUNT
                        ADD WS-INPUT-AMOUNT TO ACCOUNT-BALANCE
                        REWRITE ACCOUNT-RECORD
                        IF WS-ACCOUNT-STATUS = "00"
                            MOVE "Y" TO WS-OPERATION-FOUND
                            PERFORM INDEX-SET-ACCOUNT-BALANCE
                        ELSE
                            DISPLAY "Failed to update account. STATUS: "
                                WS-ACCOUNT-STATUS
                        END-IF
                    END-IF
            END-READ
        END-PERFORM
        CLOSE ACCOUNT-FILE
        MOVE "00" TO WS-ACCOUNT-STATUS.

