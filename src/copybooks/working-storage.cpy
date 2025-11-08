       78  CLIENT-FILE-NAME        VALUE "clients.dat".
       78  ACCOUNT-FILE-NAME       VALUE "accounts.dat".
       78  TRANSACTION-FILE-NAME   VALUE "transactions.dat".
       78  REPORT-FILE-NAME        VALUE "report.txt".
       78  DEFAULT-DATA-DIR        VALUE "data".
       78  DEFAULT-REPORT-DIR      VALUE "reports".
       78  DEFAULT-LOG-FILE        VALUE "logs/events.log".
       78  MAX-CLIENT-INDEX        VALUE 500.
       78  MAX-ACCOUNT-INDEX       VALUE 500.

       01  WS-PATHS.
           05 WS-DATA-DIR            PIC X(256) VALUE DEFAULT-DATA-DIR.
           05 WS-REPORT-DIR          PIC X(256) VALUE DEFAULT-REPORT-DIR.
           05 WS-CLIENT-PATH         PIC X(256).
           05 WS-ACCOUNT-PATH        PIC X(256).
           05 WS-TRANSACTION-PATH    PIC X(256).
           05 WS-REPORT-PATH         PIC X(256).
           05 WS-LOG-PATH            PIC X(256) VALUE DEFAULT-LOG-FILE.

       01  WS-PATH-WORK.
           05 WS-DIR-WORK            PIC X(256).
           05 WS-FILENAME            PIC X(64).
           05 WS-PATH-BUILD          PIC X(256).

       77  WS-DIR-LENGTH             PIC 9(4) COMP.
       77  WS-LAST-CHAR              PIC X.

       01  WS-CONSTANTS.
           05 WS-LINE-SEPARATOR      PIC X(80) VALUE ALL "-".
           05 WS-NEW-LINE            PIC X VALUE SPACE.

       01  WS-FLAGS.
           05 WS-EXIT-FLAG           PIC X VALUE "N".
           05 WS-OPERATION-FOUND     PIC X VALUE "N".
           05 WS-VALID-OK            PIC X VALUE "N".
           05 WS-DUPLICATE-FOUND     PIC X VALUE "N".
           05 WS-MSG-NEEDS-PAUSE     PIC X VALUE "N".
           05 WS-INDEX-ENABLED       PIC X VALUE "N".
           05 WS-INDEX-LOAD-FAIL     PIC X VALUE "N".
           05 WS-VERBOSE-FLAG        PIC X VALUE "N".

       01  WS-OPTION                 PIC X VALUE SPACE.

       01  WS-FILE-STATUS.
           05 WS-CLIENT-STATUS       PIC XX VALUE "00".
           05 WS-ACCOUNT-STATUS      PIC XX VALUE "00".
           05 WS-TRANSACTION-STATUS  PIC XX VALUE "00".
           05 WS-REPORT-STATUS       PIC XX VALUE "00".
           05 WS-LOG-STATUS          PIC XX VALUE "00".

       01  WS-ID-CONTROL.
           05 WS-NEXT-CLIENT-ID      PIC 9(6) VALUE ZERO.
           05 WS-NEXT-ACCOUNT-NUMBER PIC 9(8) VALUE ZERO.

       01  WS-INDEX-CONTROL.
           05 WS-CLIENT-INDEX-COUNT  PIC 9(4) COMP VALUE ZERO.
           05 WS-ACCOUNT-INDEX-COUNT PIC 9(4) COMP VALUE ZERO.
           05 WS-INDEX-RESULT-POS    PIC 9(4) COMP VALUE ZERO.

       *> Input structures
       01  WS-CLIENT-DATA.
           05 WS-CLIENT-NAME-IN        PIC X(60).
           05 WS-CLIENT-CPF-IN         PIC X(20).
           05 WS-CLIENT-ADDRESS-IN     PIC X(80).

       01  WS-CLIENT-TRIM.
           05 WS-CLIENT-NAME-TRIM      PIC X(60).
           05 WS-CLIENT-CPF-TRIM       PIC X(20).
           05 WS-CLIENT-CPF-DIGITS     PIC X(11).
           05 WS-CLIENT-ADDRESS-TRIM   PIC X(80).

       01  WS-ACCOUNT-DATA.
           05 WS-ACCOUNT-ENTRY         PIC X(16).
           05 WS-ACCOUNT-CLIENT-ENTRY  PIC X(16).
           05 WS-ACCOUNT-CLIENT-IN     PIC 9(6).
           05 WS-INPUT-ACCOUNT         PIC 9(8).

       01  WS-AMOUNT-DATA.
           05 WS-AMOUNT-ENTRY          PIC X(20).
           05 WS-INPUT-AMOUNT          PIC S9(11)V99.
           05 WS-AMOUNT-FORMAT         PIC --,---,---,---.99.

       01  WS-DISPLAY-AUX.
           05 WS-NUMERIC-DISPLAY       PIC Z(10).

       01  WS-TRANSACTION-AUX.
           05 WS-TOTAL-BY-CUSTOMER    PIC S9(13)V99 VALUE ZERO.
           05 WS-REPORT-CUSTOMER-ID   PIC 9(6) VALUE ZERO.

       01  WS-CLIENT-INDEX-TABLE.
           05 WS-CLIENT-INDEX-ENTRY
                  OCCURS MAX-CLIENT-INDEX TIMES
                  INDEXED BY WS-CLIENT-INDEX-IDX.
               10 WS-CLIENT-INDEX-CPF     PIC X(11).
               10 WS-CLIENT-INDEX-ID      PIC 9(6).

       01  WS-ACCOUNT-INDEX-TABLE.
           05 WS-ACCOUNT-INDEX-ENTRY
                  OCCURS MAX-ACCOUNT-INDEX TIMES
                  INDEXED BY WS-ACCOUNT-INDEX-IDX.
               10 WS-ACCOUNT-INDEX-NUMBER     PIC 9(8).
               10 WS-ACCOUNT-INDEX-CLIENT-ID  PIC 9(6).
               10 WS-ACCOUNT-INDEX-BALANCE    PIC S9(9)V99.

       01  WS-LOGGING.
           05 WS-LOG-BUFFER           PIC X(220).
           05 WS-LOG-TYPE             PIC X(12).
           05 WS-LOG-STATUS-TEXT      PIC X(12).
           05 WS-LOG-MESSAGE          PIC X(160).
           05 WS-LOG-POINTER          PIC 9(4) COMP.
           05 WS-LOG-OPEN-FLAG        PIC X VALUE "N".

       01  WS-CURRENT-TIMESTAMP.
           05 WS-CURRENT-DATE-RAW     PIC 9(8).
           05 WS-CURRENT-TIME-RAW     PIC 9(6).
           05 WS-DATETIME-FORMATTED    PIC X(19).

       01  WS-REPORT-BUFFER.
           05 WS-TEMP-REPORT-LINE      PIC X(160).

       77  WS-PAUSE-INPUT             PIC X(5).
       77  WS-ENTRY-LENGTH            PIC 9(4) COMP.
       77  WS-DIGIT-COUNT             PIC 9(4) COMP.
       77  WS-STRING-POINTER          PIC 9(4) COMP.
       77  WS-INDEX-ITER              PIC 9(4) COMP.


