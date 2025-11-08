       MENU-SECTION SECTION.
       MAIN-LOOP.
           MOVE "N" TO WS-EXIT-FLAG
           PERFORM UNTIL WS-EXIT-FLAG = "Y"
               PERFORM DISPLAY-MENU
               ACCEPT WS-OPTION
               PERFORM HANDLE-OPTION
               IF WS-EXIT-FLAG NOT = "Y"
                   PERFORM PROMPT-CONTINUE
               END-IF
           END-PERFORM
           DISPLAY "Shutting down BankFlow COBOL...".

       DISPLAY-MENU.
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY "          *** BANKFLOW COBOL ***"
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY "1 - Register Customer"
           DISPLAY "2 - Create Account"
           DISPLAY "3 - Deposit"
           DISPLAY "4 - Withdraw"
           DISPLAY "5 - Check Balance"
           DISPLAY "6 - Generate Report"
           DISPLAY "7 - Exit"
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY "Select an option: ".

       HANDLE-OPTION.
           EVALUATE WS-OPTION
               WHEN "1"
                   PERFORM REGISTER-CUSTOMER
               WHEN "2"
                   PERFORM CREATE-ACCOUNT
               WHEN "3"
                   PERFORM DEPOSIT-INTO-ACCOUNT
               WHEN "4"
                   PERFORM WITHDRAW-FROM-ACCOUNT
               WHEN "5"
                   PERFORM CHECK-BALANCE
               WHEN "6"
                   PERFORM GENERATE-REPORT
               WHEN "7"
                   MOVE "Y" TO WS-EXIT-FLAG
               WHEN OTHER
                   DISPLAY "Invalid option. Please try again."
           END-EVALUATE.

       PROMPT-CONTINUE.
           DISPLAY WS-LINE-SEPARATOR
           DISPLAY "Press ENTER to continue..."
           ACCEPT WS-PAUSE-INPUT.

