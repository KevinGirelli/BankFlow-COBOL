       >>SOURCE FORMAT FREE

       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKFLOW-COBOL.
       AUTHOR. KEVIN GIRELLI.
       INSTALLATION. BANKFLOW SYSTEMS.
       DATE-WRITTEN. 2025-11-08.
       DATE-COMPILED. 2025-11-08.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z-SERIES.
       OBJECT-COMPUTER. IBM-Z-SERIES.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY "../copybooks/file-control.cpy".

       DATA DIVISION.
       FILE SECTION.
           COPY "../copybooks/file-section.cpy".

       WORKING-STORAGE SECTION.
           COPY "../copybooks/working-storage.cpy".

       PROCEDURE DIVISION.
           COPY "../sections/main-section.cpy".
