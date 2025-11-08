       LOGGING-SECTION SECTION.
       LOG-CLEAR.
           MOVE SPACES TO WS-LOG-TYPE
           MOVE SPACES TO WS-LOG-STATUS-TEXT
           MOVE SPACES TO WS-LOG-MESSAGE
           MOVE SPACES TO WS-LOG-BUFFER.

       LOG-WRITE.
           IF WS-LOG-PATH = SPACES
               EXIT PARAGRAPH
           END-IF
           IF WS-LOG-OPEN-FLAG NOT = "Y"
               EXIT PARAGRAPH
           END-IF
           PERFORM BUILD-DATETIME
           MOVE SPACES TO WS-LOG-BUFFER
           MOVE 1 TO WS-LOG-POINTER
           STRING WS-DATETIME-FORMATTED DELIMITED BY SIZE
                  " | " DELIMITED BY SIZE
                  FUNCTION TRIM(WS-LOG-TYPE TRAILING) DELIMITED BY SIZE
                  " | " DELIMITED BY SIZE
                  FUNCTION TRIM(WS-LOG-STATUS-TEXT TRAILING) DELIMITED BY SIZE
                  " | " DELIMITED BY SIZE
                  FUNCTION TRIM(WS-LOG-MESSAGE TRAILING) DELIMITED BY SIZE
                  INTO WS-LOG-BUFFER
                  WITH POINTER WS-LOG-POINTER
           END-STRING
           MOVE WS-LOG-BUFFER TO LOG-RECORD
           WRITE LOG-RECORD
           IF WS-VERBOSE-FLAG = "Y"
               DISPLAY WS-LOG-BUFFER
           END-IF.

       OPEN-LOG-FILE.
           MOVE "00" TO WS-LOG-STATUS
           OPEN EXTEND LOG-FILE
           IF WS-LOG-STATUS = "00"
               MOVE "Y" TO WS-LOG-OPEN-FLAG
           ELSE
               MOVE "N" TO WS-LOG-OPEN-FLAG
               DISPLAY "Warning: logging disabled. STATUS: " WS-LOG-STATUS
               CLOSE LOG-FILE
           END-IF.

