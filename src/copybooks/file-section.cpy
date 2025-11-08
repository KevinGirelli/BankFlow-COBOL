       FD  CLIENT-FILE.
       01  CLIENT-RECORD.
           05 CLIENT-ID            PIC 9(6).
           05 CLIENT-NAME          PIC X(40).
           05 CLIENT-CPF           PIC X(11).
           05 CLIENT-ADDRESS       PIC X(60).

       FD  ACCOUNT-FILE.
       01  ACCOUNT-RECORD.
           05 ACCOUNT-NUMBER       PIC 9(8).
           05 ACCOUNT-CLIENT-ID    PIC 9(6).
           05 ACCOUNT-BALANCE      PIC S9(9)V99.

       FD  TRANSACTION-FILE.
       01  TRANSACTION-RECORD.
           05 TRANS-ACCOUNT-NUMBER PIC 9(8).
           05 TRANS-TYPE           PIC X(6).
           05 TRANS-AMOUNT         PIC S9(9)V99.
           05 TRANS-DATETIME       PIC X(19).

       FD  REPORT-FILE.
       01  REPORT-RECORD           PIC X(160).

       FD  LOG-FILE.
       01  LOG-RECORD              PIC X(220).

