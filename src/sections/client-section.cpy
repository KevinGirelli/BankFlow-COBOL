       CLIENT-SECTION SECTION.
       *> START CUSTOMER REGISTRATION
       REGISTER-CUSTOMER.
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY ">>> Customer Registration <<<"
           PERFORM CALCULATE-NEXT-CUSTOMER-ID

           DISPLAY "Customer name: "
           ACCEPT WS-CLIENT-NAME-IN
           DISPLAY "CPF (numbers only): "
           ACCEPT WS-CLIENT-CPF-IN
           DISPLAY "Address: "
           ACCEPT WS-CLIENT-ADDRESS-IN

           PERFORM VALIDATE-CUSTOMER-DATA
           IF WS-VALID-OK NOT = "Y"
               EXIT PARAGRAPH
           END-IF

           MOVE WS-NEXT-CLIENT-ID TO CLIENT-ID
           MOVE WS-CLIENT-NAME-TRIM (1:40) TO CLIENT-NAME
           MOVE WS-CLIENT-CPF-DIGITS TO CLIENT-CPF
           MOVE WS-CLIENT-ADDRESS-TRIM (1:60) TO CLIENT-ADDRESS

           OPEN EXTEND CLIENT-FILE
           WRITE CLIENT-RECORD
           IF WS-CLIENT-STATUS NOT = "00"
               DISPLAY "Error writing customer. STATUS: " WS-CLIENT-STATUS
               PERFORM LOG-CLEAR
               MOVE "CUSTOMER" TO WS-LOG-TYPE
               MOVE "ERROR" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               STRING "registration failure STATUS="
                      WS-CLIENT-STATUS DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
           ELSE
               DISPLAY "Customer registered successfully! ID: " WS-NEXT-CLIENT-ID
               PERFORM INDEX-REGISTER-CLIENT
               PERFORM LOG-CLEAR
               MOVE "CUSTOMER" TO WS-LOG-TYPE
               MOVE "SUCCESS" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               MOVE WS-NEXT-CLIENT-ID TO WS-NUMERIC-DISPLAY
               STRING "cpf=" DELIMITED BY SIZE
                      WS-CLIENT-CPF-DIGITS DELIMITED BY SIZE
                      " id=" DELIMITED BY SIZE
                      FUNCTION TRIM(WS-NUMERIC-DISPLAY TRAILING)
                      DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               PERFORM METRICS-RECORD-SUCCESS
           END-IF
           CLOSE CLIENT-FILE
           MOVE "00" TO WS-CLIENT-STATUS.
       *> END CUSTOMER REGISTRATION

       VALIDATE-CUSTOMER-DATA.
           MOVE "N" TO WS-VALID-OK
           MOVE FUNCTION TRIM(WS-CLIENT-NAME-IN TRAILING)
               TO WS-CLIENT-NAME-TRIM
           IF WS-CLIENT-NAME-TRIM = SPACES
               DISPLAY "Customer name cannot be empty."
               EXIT PARAGRAPH
           END-IF

           MOVE FUNCTION TRIM(WS-CLIENT-CPF-IN TRAILING)
               TO WS-CLIENT-CPF-TRIM
           IF WS-CLIENT-CPF-TRIM = SPACES
               DISPLAY "CPF cannot be empty."
               EXIT PARAGRAPH
           END-IF

           MOVE SPACES TO WS-CLIENT-CPF-DIGITS
           MOVE ZERO TO WS-DIGIT-COUNT
           PERFORM VARYING WS-ENTRY-LENGTH FROM 1 BY 1
                   UNTIL WS-ENTRY-LENGTH > FUNCTION LENGTH(WS-CLIENT-CPF-TRIM)
               EVALUATE TRUE
                   WHEN WS-CLIENT-CPF-TRIM(WS-ENTRY-LENGTH:1) >= "0"
                        AND WS-CLIENT-CPF-TRIM(WS-ENTRY-LENGTH:1) <= "9"
                       ADD 1 TO WS-DIGIT-COUNT
                       IF WS-DIGIT-COUNT <= 11
                           MOVE WS-CLIENT-CPF-TRIM(WS-ENTRY-LENGTH:1)
                               TO WS-CLIENT-CPF-DIGITS(WS-DIGIT-COUNT:1)
                       END-IF
                   WHEN OTHER
                       CONTINUE
               END-EVALUATE
           END-PERFORM

           IF WS-DIGIT-COUNT NOT = 11
               DISPLAY "CPF must contain 11 numeric digits."
               EXIT PARAGRAPH
           END-IF

           MOVE FUNCTION TRIM(WS-CLIENT-ADDRESS-IN TRAILING)
               TO WS-CLIENT-ADDRESS-TRIM
           IF WS-CLIENT-ADDRESS-TRIM = SPACES
               DISPLAY "Address cannot be empty."
               EXIT PARAGRAPH
           END-IF

           PERFORM FIND-CUSTOMER-BY-CPF
           IF WS-DUPLICATE-FOUND = "Y"
               DISPLAY "The provided CPF is already registered."
               PERFORM LOG-CLEAR
               MOVE "CUSTOMER" TO WS-LOG-TYPE
               MOVE "DUPLICATE" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               STRING "cpf=" DELIMITED BY SIZE
                      WS-CLIENT-CPF-DIGITS DELIMITED BY SIZE
                      " duplicate" DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               EXIT PARAGRAPH
           END-IF

           MOVE "Y" TO WS-VALID-OK.

       CALCULATE-NEXT-CUSTOMER-ID.
           MOVE ZERO TO WS-NEXT-CLIENT-ID
           MOVE "00" TO WS-CLIENT-STATUS
           OPEN INPUT CLIENT-FILE
           IF WS-CLIENT-STATUS = "00"
               PERFORM UNTIL WS-CLIENT-STATUS NOT = "00"
                   READ CLIENT-FILE
                       AT END
                           MOVE "99" TO WS-CLIENT-STATUS
                       NOT AT END
                           IF CLIENT-ID > WS-NEXT-CLIENT-ID
                               MOVE CLIENT-ID TO WS-NEXT-CLIENT-ID
                           END-IF
                   END-READ
               END-PERFORM
           END-IF
           CLOSE CLIENT-FILE
           MOVE "00" TO WS-CLIENT-STATUS
           ADD 1 TO WS-NEXT-CLIENT-ID.

       FIND-CUSTOMER-BY-CPF.
           MOVE "N" TO WS-DUPLICATE-FOUND
           MOVE ZERO TO WS-INDEX-RESULT-POS
           IF WS-INDEX-ENABLED = "Y"
               PERFORM INDEX-FIND-CLIENT-BY-CPF
               IF WS-INDEX-RESULT-POS > ZERO
                   MOVE "Y" TO WS-DUPLICATE-FOUND
                   EXIT PARAGRAPH
               END-IF
           END-IF
           MOVE "00" TO WS-CLIENT-STATUS
           OPEN INPUT CLIENT-FILE
           IF WS-CLIENT-STATUS = "00"
               PERFORM UNTIL WS-CLIENT-STATUS NOT = "00"
                   READ CLIENT-FILE
                       AT END
                           MOVE "99" TO WS-CLIENT-STATUS
                       NOT AT END
                           IF CLIENT-CPF = WS-CLIENT-CPF-DIGITS
                               MOVE "Y" TO WS-DUPLICATE-FOUND
                               MOVE "99" TO WS-CLIENT-STATUS
                           END-IF
                   END-READ
               END-PERFORM
           END-IF
           CLOSE CLIENT-FILE
           MOVE "00" TO WS-CLIENT-STATUS.

       VERIFY-CUSTOMER-EXISTS.
           MOVE "N" TO WS-OPERATION-FOUND
           MOVE "00" TO WS-CLIENT-STATUS
           OPEN INPUT CLIENT-FILE
           IF WS-CLIENT-STATUS = "00"
               PERFORM WITH TEST AFTER UNTIL WS-CLIENT-STATUS NOT = "00"
                   READ CLIENT-FILE
                       AT END
                           MOVE "99" TO WS-CLIENT-STATUS
                       NOT AT END
                           IF CLIENT-ID = WS-ACCOUNT-CLIENT-IN
                               MOVE "Y" TO WS-OPERATION-FOUND
                               MOVE "99" TO WS-CLIENT-STATUS
                           END-IF
                   END-READ
               END-PERFORM
           END-IF
           CLOSE CLIENT-FILE
           MOVE "00" TO WS-CLIENT-STATUS.

