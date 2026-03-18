* Encoding: UTF-8.
*import data from existing files.

*input type csv if the data file is a csv file. 
*input the worksheet name of your excel file where the data is saved in /SHEETS .

GET DATA
/TYPE = XLSX 
/FILE = 'G:\Projects\SPSS\data\raw\data-raw.xlsx'
/SHEET = name 'data-raw'
/READNAMES = ON.

RECODE sex ('f'='F') ('female'='F') ('male'='M') ('m'='M') ('Male'='M').
EXECUTE.

RECODE sex ('F'=1) ('M'=0) INTO sex_numeric.
EXECUTE.

DELETE VARIABLES famrel.
RMV /studytime=SMEAN(studytime).

SELECT IF (PrimaryLast = 1).
EXECUTE.

