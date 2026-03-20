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

COMPUTE student_id = $CASENUM.
EXECUTE.


DATASET ACTIVATE DataSet1.
COMPUTE finalGrade=((G1+G2+G3)/60)*100.
EXECUTE.

RECODE finalGrade (40 thru 100=1) (ELSE=0) INTO Result.
VARIABLE LABELS  Result '1:Passed;0:Failed' .
EXECUTE.

COMPUTE district=RND(RV.UNIFORM(1,8)).
EXECUTE.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=district COUNT()[name="COUNT"] MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: district=col(source(s), name("district"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  GUIDE: axis(dim(1), label("district"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: text.title(label("Simple Bar Count of district"))
  SCALE: cat(dim(1), include("1.00", "2.00", "3.00", "4.00", "5.00", "6.00", "7.00", "8.00"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(district*COUNT), shape.interior(shape.square))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=studytime finalGrade MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: studytime=col(source(s), name("studytime"))
  DATA: finalGrade=col(source(s), name("finalGrade"))
  GUIDE: axis(dim(1), label("SMEAN(studytime)"))
  GUIDE: axis(dim(2), label("finalGrade"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of finalGrade by SMEAN(studytime)"))
  ELEMENT: point(position(studytime*finalGrade))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=district finalGrade MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: district=col(source(s), name("district"), unit.category())
  DATA: finalGrade=col(source(s), name("finalGrade"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("district"))
  GUIDE: axis(dim(2), label("finalGrade"))
  GUIDE: text.title(label("Simple Boxplot of finalGrade by district"))
  SCALE: cat(dim(1), include("1.00", "2.00", "3.00", "4.00", "5.00", "6.00", "7.00", "8.00"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(district*finalGrade)), label(id))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=studytime finalGrade MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: studytime=col(source(s), name("studytime"))
  DATA: finalGrade=col(source(s), name("finalGrade"))
  GUIDE: axis(dim(1), label("SMEAN(studytime)"))
  GUIDE: axis(dim(2), label("finalGrade"))
  GUIDE: text.title(label("Simple Scatter of finalGrade by SMEAN(studytime)"))
  ELEMENT: point(position(studytime*finalGrade))
END GPL.


*randomizing study time according to description.
DO IF (studytime <= 1).
  COMPUTE studytime_hours = RV.UNIFORM(0,2).
ELSE IF (studytime <= 2).
  COMPUTE studytime_hours = RV.UNIFORM(2,5).
ELSE IF (studytime <= 3).
  COMPUTE studytime_hours = RV.UNIFORM(5,10).
ELSE IF (studytime <= 4).
  COMPUTE studytime_hours = RV.UNIFORM(10,15).
END IF.

EXECUTE.

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=finalGrade
  /STATISTICS=MEAN STDDEV MIN MAX.

* Custom Tables. 1.
CTABLES
  /VLABELS VARIABLES=district sex DISPLAY=LABEL
  /TABLE district [C][COUNT F40.0, ROWPCT.COUNT PCT40.1] BY sex [C]
  /CATEGORIES VARIABLES=district ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CATEGORIES VARIABLES=sex ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CRITERIA CILEVEL=95.

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=paid schoolsup finalGrade DISPLAY=LABEL
  /TABLE paid + schoolsup BY finalGrade [MEAN, MAXIMUM, MINIMUM, STDDEV]
  /CATEGORIES VARIABLES=paid schoolsup ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CRITERIA CILEVEL=95.

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=scholarship_status internet studytime_hours finalGrade DISPLAY=LABEL
  /TABLE scholarship_status > internet BY studytime_hours [MEAN] + finalGrade [MEAN]
  /CATEGORIES VARIABLES=scholarship_status ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CATEGORIES VARIABLES=internet ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CRITERIA CILEVEL=95.



CORRELATIONS
  /VARIABLES=studytime_hours finalGrade
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=studytime_hours finalGrade MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: studytime_hours=col(source(s), name("studytime_hours"))
  DATA: finalGrade=col(source(s), name("finalGrade"))
  GUIDE: axis(dim(1), label("studytime_hours"))
  GUIDE: axis(dim(2), label("finalGrade"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of finalGrade by studytime_hours"))
  ELEMENT: point(position(studytime_hours*finalGrade))
END GPL.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT finalGrade
  /METHOD=ENTER studytime_hours.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT finalGrade
  /METHOD=ENTER studytime_hours scholarship_status Dalc.
