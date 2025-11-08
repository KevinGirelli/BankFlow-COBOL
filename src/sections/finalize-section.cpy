       FINALIZE-SECTION SECTION.
       FINALIZE-ENTRY.
           IF WS-LOG-OPEN-FLAG = "Y"
               PERFORM LOG-CLEAR
               MOVE "SYSTEM" TO WS-LOG-TYPE
               MOVE "END" TO WS-LOG-STATUS-TEXT
               MOVE 1 TO WS-LOG-POINTER
               STRING "session finished" DELIMITED BY SIZE
                      INTO WS-LOG-MESSAGE
                      WITH POINTER WS-LOG-POINTER
               END-STRING
               PERFORM LOG-WRITE
               CLOSE LOG-FILE
               MOVE "N" TO WS-LOG-OPEN-FLAG
               MOVE "00" TO WS-LOG-STATUS
           END-IF.

