       INDEX-SECTION SECTION.
       INDEX-INITIALIZE.
           MOVE "N" TO WS-INDEX-ENABLED
           MOVE "N" TO WS-INDEX-LOAD-FAIL
           MOVE ZERO TO WS-CLIENT-INDEX-COUNT
           MOVE ZERO TO WS-ACCOUNT-INDEX-COUNT
           MOVE ZERO TO WS-INDEX-RESULT-POS
           PERFORM LOAD-CLIENT-INDEX
           PERFORM LOAD-ACCOUNT-INDEX
           IF WS-INDEX-LOAD-FAIL = "N"
               MOVE "Y" TO WS-INDEX-ENABLED
           END-IF.

       LOAD-CLIENT-INDEX.
           MOVE ZERO TO WS-CLIENT-INDEX-COUNT
           MOVE ZERO TO WS-INDEX-RESULT-POS
           MOVE "00" TO WS-CLIENT-STATUS
           OPEN INPUT CLIENT-FILE
           IF WS-CLIENT-STATUS = "00"
               PERFORM UNTIL WS-CLIENT-STATUS NOT = "00"
                   READ CLIENT-FILE
                       AT END
                           MOVE "99" TO WS-CLIENT-STATUS
                       NOT AT END
                           IF WS-CLIENT-INDEX-COUNT < MAX-CLIENT-INDEX
                               ADD 1 TO WS-CLIENT-INDEX-COUNT
                               MOVE CLIENT-CPF TO
                                   WS-CLIENT-INDEX-CPF(WS-CLIENT-INDEX-COUNT)
                               MOVE CLIENT-ID TO
                                   WS-CLIENT-INDEX-ID(WS-CLIENT-INDEX-COUNT)
                           END-IF
                   END-READ
               END-PERFORM
           ELSE
               MOVE "Y" TO WS-INDEX-LOAD-FAIL
           END-IF
           CLOSE CLIENT-FILE
           MOVE "00" TO WS-CLIENT-STATUS.

       LOAD-ACCOUNT-INDEX.
           MOVE ZERO TO WS-ACCOUNT-INDEX-COUNT
           MOVE ZERO TO WS-INDEX-RESULT-POS
           MOVE "00" TO WS-ACCOUNT-STATUS
           OPEN INPUT ACCOUNT-FILE
           IF WS-ACCOUNT-STATUS = "00"
               PERFORM UNTIL WS-ACCOUNT-STATUS NOT = "00"
                   READ ACCOUNT-FILE
                       AT END
                           MOVE "99" TO WS-ACCOUNT-STATUS
                       NOT AT END
                           IF WS-ACCOUNT-INDEX-COUNT < MAX-ACCOUNT-INDEX
                               ADD 1 TO WS-ACCOUNT-INDEX-COUNT
                               MOVE ACCOUNT-NUMBER TO
                                   WS-ACCOUNT-INDEX-NUMBER(WS-ACCOUNT-INDEX-COUNT)
                               MOVE ACCOUNT-CLIENT-ID TO
                                   WS-ACCOUNT-INDEX-CLIENT-ID(WS-ACCOUNT-INDEX-COUNT)
                               MOVE ACCOUNT-BALANCE TO
                                   WS-ACCOUNT-INDEX-BALANCE(WS-ACCOUNT-INDEX-COUNT)
                           END-IF
                   END-READ
               END-PERFORM
           ELSE
               MOVE "Y" TO WS-INDEX-LOAD-FAIL
           END-IF
           CLOSE ACCOUNT-FILE
           MOVE "00" TO WS-ACCOUNT-STATUS.

       INDEX-REGISTER-CLIENT.
           IF WS-INDEX-ENABLED = "Y"
               AND WS-CLIENT-INDEX-COUNT < MAX-CLIENT-INDEX
               ADD 1 TO WS-CLIENT-INDEX-COUNT
               MOVE WS-CLIENT-CPF-DIGITS TO
                   WS-CLIENT-INDEX-CPF(WS-CLIENT-INDEX-COUNT)
               MOVE WS-NEXT-CLIENT-ID TO
                   WS-CLIENT-INDEX-ID(WS-CLIENT-INDEX-COUNT)
           END-IF.

       INDEX-REGISTER-ACCOUNT.
           IF WS-INDEX-ENABLED = "Y"
               AND WS-ACCOUNT-INDEX-COUNT < MAX-ACCOUNT-INDEX
               ADD 1 TO WS-ACCOUNT-INDEX-COUNT
               MOVE WS-NEXT-ACCOUNT-NUMBER TO
                   WS-ACCOUNT-INDEX-NUMBER(WS-ACCOUNT-INDEX-COUNT)
               MOVE WS-ACCOUNT-CLIENT-IN TO
                   WS-ACCOUNT-INDEX-CLIENT-ID(WS-ACCOUNT-INDEX-COUNT)
               MOVE ZERO TO
                   WS-ACCOUNT-INDEX-BALANCE(WS-ACCOUNT-INDEX-COUNT)
           END-IF.

       INDEX-FIND-CLIENT-BY-CPF.
           MOVE ZERO TO WS-INDEX-RESULT-POS
           IF WS-INDEX-ENABLED = "Y"
               PERFORM VARYING WS-INDEX-ITER FROM 1 BY 1
                       UNTIL WS-INDEX-ITER > WS-CLIENT-INDEX-COUNT
                   IF WS-CLIENT-INDEX-CPF(WS-INDEX-ITER)
                        = WS-CLIENT-CPF-DIGITS
                       MOVE WS-INDEX-ITER TO WS-INDEX-RESULT-POS
                       EXIT PERFORM
                   END-IF
               END-PERFORM
           END-IF.

       INDEX-FIND-ACCOUNT-BY-NUMBER.
           MOVE ZERO TO WS-INDEX-RESULT-POS
           IF WS-INDEX-ENABLED = "Y"
               PERFORM VARYING WS-INDEX-ITER FROM 1 BY 1
                       UNTIL WS-INDEX-ITER > WS-ACCOUNT-INDEX-COUNT
                   IF WS-ACCOUNT-INDEX-NUMBER(WS-INDEX-ITER)
                        = WS-INPUT-ACCOUNT
                       MOVE WS-INDEX-ITER TO WS-INDEX-RESULT-POS
                       EXIT PERFORM
                   END-IF
               END-PERFORM
           END-IF.

       INDEX-SET-ACCOUNT-BALANCE.
           IF WS-INDEX-ENABLED = "Y"
               IF WS-INDEX-RESULT-POS = ZERO
                   PERFORM INDEX-FIND-ACCOUNT-BY-NUMBER
               END-IF
               IF WS-INDEX-RESULT-POS > ZERO
                   MOVE ACCOUNT-BALANCE TO
                       WS-ACCOUNT-INDEX-BALANCE(WS-INDEX-RESULT-POS)
               END-IF
           END-IF.

       INDEX-GET-ACCOUNT-BALANCE.
           MOVE ZERO TO WS-INDEX-RESULT-POS
           IF WS-INDEX-ENABLED = "Y"
               PERFORM INDEX-FIND-ACCOUNT-BY-NUMBER
               IF WS-INDEX-RESULT-POS > ZERO
                   MOVE WS-ACCOUNT-INDEX-BALANCE(WS-INDEX-RESULT-POS)
                       TO WS-AMOUNT-FORMAT
                   MOVE "Y" TO WS-OPERATION-FOUND
               END-IF
           END-IF.

