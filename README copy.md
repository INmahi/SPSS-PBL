# SPSS Student Performance Workflow

![SPSS](https://img.shields.io/badge/Tool-IBM%20SPSS-1261A0?style=for-the-badge)
![Data Cleaning](https://img.shields.io/badge/Stage-Data%20Cleaning-0B8457?style=for-the-badge)
![Feature Engineering](https://img.shields.io/badge/Stage-Feature%20Engineering-6A4C93?style=for-the-badge)

Documentation for importing, cleaning, transforming, and analyzing student performance data in SPSS.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Workspace Structure](#workspace-structure)
3. [Data Import](#data-import)
4. [Phase 1: Data Cleaning](#phase-1-data-cleaning)
5. [Phase 2: Feature Engineering](#phase-2-feature-engineering)
6. [Visualization](#visualization)
7. [SPSS Syntax Quick Reference](#spss-syntax-quick-reference)
8. [Export Cleaned Dataset](#export-cleaned-dataset)

---

## Project Overview

This project documents a complete SPSS workflow for:

- Importing raw student data
- Cleaning inconsistent and missing values
- Handling duplicates and outliers
- Creating engineered features
- Producing charts for analysis
- Exporting a final cleaned dataset

The workflow is designed for reproducibility using both SPSS GUI actions and SPSS syntax.

---

## Workspace Structure

Key folders in this workspace:

- `data/raw`: Raw source files (`.sav`, `.csv`, `.xlsx`)
- `data/Source`: Data dictionary/reference notes (`student.txt`)
- `data/cleaned`: Final cleaned outputs
- `spss/files`: Working SPSS files and process notes
- `spss/syntax`: SPSS syntax scripts
- `spss/output`: SPSS output viewer files (`.spv`)

---

## Data Import

### Import from CSV (GUI)

1. Open SPSS and select CSV import.
2. In the Text Import Wizard:
	 - Set decimal symbol correctly (comma if needed).
	 - Confirm variable names are in row 1.
	 - Verify delimiter and text qualifier by checking the raw CSV.
	 - Confirm preview before finishing.

### Import from Excel (Syntax)

```spss
GET DATA
	/TYPE = XLSX
	/FILE = 'G:\Projects\SPSS\data\raw\data-raw.xlsx'
	/SHEET = name 'data-raw'
	/READNAMES = ON.
```

After import, save the dataset as `.sav` for processing.

> Screenshot placeholder: Import wizard settings and data preview.

---

## Phase 1: Data Cleaning

### 1) Profile Variables with Frequencies

Use frequency tables to detect:

- Missing values by variable
- Inconsistent categorical coding (for example, `f`, `Female`, `M`, `male`)

Path: `Analyze > Descriptive Statistics > Frequencies`

> Screenshot placeholder: Frequencies dialog and output table.

### 2) Standardize the `sex` Variable

- Recode inconsistent text values into standard `M` and `F`.
- Use **Recode into Same Variables** for in-place cleanup.

Then define value labels in Variable View for readability.

> Screenshot placeholder: Recode setup and value labels.

### 3) Create Numeric Sex Variable

Create a new variable such as `sex_numeric`:

- `M -> 0`
- `F -> 1`

Use **Recode into Different Variables** because this is a new field.

> Screenshot placeholder: Different-variable recode mapping.

### 4) Handle Missing Values

From profiling:

- `famrel` has high missingness (about 44%): drop variable if low analytical value.
- `studytime` has moderate missingness (about 13%): impute with mean.

Example syntax to drop variable:

```spss
DELETE VARIABLES famrel.
```

> Screenshot placeholder: Missing-value summary and imputation setup.
### 5) Detect Outliers

Path: `Graphs > Legacy Dialogs > Boxplot`

- Use case numbers shown in the chart to inspect outlier records.
- In this project, outlier values were corrected by cross-checking with the source dataset.

> Screenshot placeholder: Boxplot with outlier case labels.

### 6) Detect and Remove Duplicate Cases

Path: `Data > Identify Duplicate Cases`

*it is important to remove duplicates before creating new features to avoid propagating errors.*

Define Matching Cases: Move the variable(s) that identify a duplicate (e.g., Student_ID) into the Define matching cases by box.
Tip: If you want to find cases that are identical across every variable, move all variables into this box. (in our case we don't have a unique ID, so we can use all variables to identify duplicates).
Sort within Groups: Use the Sort within groups by box to determine which record becomes the "primary" one.
For example, sort by Date (Descending) to keep the most recent entry as the primary case.
Indicators to Create:
PrimaryLast: By default, SPSS creates a new variable named PrimaryLast.
Value 1: Marks the primary case (the one you want to keep).
Value 0: Marks the duplicate cases.
Run: Click OK.

Keep only primary rows:

```spss
SELECT IF (PrimaryLast = 1).
EXECUTE.
```

> Screenshot placeholder: Duplicate-case settings and filtered result.


---

## Phase 2: Feature Engineering

### 1) Add Student ID

Assign case-based ID:

```spss
COMPUTE student_id = $CASENUM.
EXECUTE.
```

### 2) Create Final Grade

Combine three grade components into one percentage feature:

```spss
COMPUTE finalGrade = ((G1 + G2 + G3) / 60) * 100.
EXECUTE.
```

### 3) Create Pass/Fail Flag

Example logic:

- `finalGrade >= 40` -> Pass (`1`)
- Otherwise -> Fail (`0`)

Use **Recode into Different Variables** or `DO IF` syntax.

### 4) Generate Random District Variable

Generate a random district code from 1 to 8 and then apply value labels.

Example idea:

```spss
COMPUTE district = RND(RV.UNIFORM(1, 8)).
EXECUTE.
```

Then label values (for example: `1=Dhaka`, `2=Chattogram`, etc.).

> Screenshot placeholder: District generation and value label setup.

### 5) Convert Ordinal Study Time into Estimated Hours

Because `studytime` is ordinal (1 to 4), map each category to a realistic hour range:

```spss
DO IF (studytime <= 1).
	COMPUTE studytime_hours = RV.UNIFORM(0, 2).
ELSE IF (studytime <= 2).
	COMPUTE studytime_hours = RV.UNIFORM(2, 5).
ELSE IF (studytime <= 3).
	COMPUTE studytime_hours = RV.UNIFORM(5, 10).
ELSE IF (studytime <= 4).
	COMPUTE studytime_hours = RV.UNIFORM(10, 15).
END IF.
EXECUTE.
```

Brief explanation:

- SPSS checks each row's `studytime` category.
- It assigns a random hour value inside a category-specific range.
- This creates a continuous variable (`studytime_hours`) suitable for scatterplots.

> Screenshot placeholder: `studytime` to `studytime_hours` transformation.

---

## Visualization

Recommended charts used in this workflow:

Path: `Graphs > Chart builder`


- Bar chart
- Boxplot
- Scatterplot (`studytime_hours` vs target variables)

If we hadn't converted `studytime` to a continuous variable, we would see a stacked scatterplot with only 4 distinct `x` values (1, 2, 3, 4), which would limit the ability to observe trends and correlations. By creating `studytime_hours`, we can visualize a more continuous relationship between study time and performance metrics.
> Screenshot placeholder: Bar chart.
>
> Screenshot placeholder: Boxplot.
>
> Screenshot placeholder: Scatterplot.

---


## Merging Datasets

- Situation 1: suppose we have a separate dataset with additional student information (e.g., `student_info.sav`) that we want to merge with our cleaned dataset (`main.sav`).
- Situation 2: Suppose we have new responses in the survey, so we want to add new cases to our existing dataset.

#### Merging by Adding Variables (Situation 1)

[we will use a dummy secind dataset that will contain the same student id's but with different variables. Let's prepare another dataset. `file>new>data`

the main dataset case 649 cases with corresponding id's from 1 to 649. We will create a second dataset with the same id's but with two new variables:
use loop feature in SPSS to create two new variable `student_id` (from 1 to 649),:
`
INPUT PROGRAM.
loop student_id = 1 to 1000.
END CASE.
END LOOP.
END FILE.
END INPUT PROGRAM.
EXECUTE.
`
`scholarship_status` (1 = Yes, 0 = No) and `socialMediaEngagement`(from 1 to 4, minimum = 1, maximum = 4). We will merge this dataset with our main dataset to enrich our analysis.
**try to create this two variables using the compute function and random number generation yourself, also label the values. screenshot below **]
> check previous section (feature engineering) for random number generation methods
> the new_variables.sps file contains the syntax to create the second dataset with the new variables, in case you cannot figure out how to do it yourself.

save the new data file as new_variables.sav in the `spss/files` folder. the new file look like this:
screenshot goes here

once our second dataset is ready, we can merge it with the main dataset by adding variables. This is useful when we have different variables for the same cases (students) in both datasets.
1. Open both datasets in SPSS.
2. Go to `Data > Merge Files > Add Variables`. 
3. select the second dataset (new_variables.sav) as the source of additional variables.
4. Add student_id as the key variable to match cases between the two datasets.
screenshot goes here
>issue: must sort the datasets by the key variable (student_id) before merging. To sort, go to `Data > Sort Cases` and select student_id for both datasets.

*** #### Always run frequencies after merging and look to the bottom of the output to check for any mismatches or missing values that may have resulted from the merge. This will help ensure that the merge was successful and that all cases are properly aligned.

#### Merging by Adding Variables (Situation 1)
- If we have new cases (students) to add, we can use `Data > Merge Files > Add Cases` to append the new records to our existing dataset.
- Ensure that the variable structure (names and types) matches between the datasets to avoid issues during the merge.
- After merging, run frequencies to check for any discrepancies or missing values.

---
### Select cases in SPSS

purpose: Temporarily isolate a specific subset of data (e.g., only "Female" students or "Income > 5000") for analysis while hiding the rest

path: `Data → Select Cases → If condition is satisfied → Condition`

example:
1. To analyze only students with internet access, we can set the condition as `internet = 'yes'`.
`SELECT IF (internet = 'yes').
EXECUTE.`
now every analysis we run will only include students with internet access. The other cases will be temporarily excluded from the analysis but remain in the dataset.
2. to analyze only students who study more than 3 hours, we can set the condition as `studytime >=3`
`SELECT IF (studytime >= 3).
EXECUTE.`
3. To restore all cases, we can use:
`USE ALL.
EXECUTE.`

---
### Descriptive Statistics in SPSS

1. Descriptive Statistics: `Analyze > Descriptive Statistics > Descriptives` for mean, std deviation, min, max.
2. place the target variables in the variable box 
3. Click `Options` to select additional statistics (e.g., variance, range) and click `Continue`.
4. Click `OK` to run the analysis and view results in the output viewer.
>  Creating frequency tables are shown earlier in the data cleaning section, but they are also a key part of descriptive statistics for categorical variables.
screenshot goes here
---
### Custom Tables in SPSS
it is a powerful tool for analyzing and presenting data in a structured format. but it's often so confusing.
We will try understanding custom tables with examples. before that here is some quick instructions:
1. Go to `Analyze > Tables > Custom Tables`.
2. . The "Golden Rule" of Rows vs. Columns
To stop the confusion, remember this simple visualization:

*Rows (The "Groups")*: Put the variable you want to compare here (e.g., Gender, District, Year). Rows grow downward, creating a list of categories.
*Columns (The "Data")*: Put the variable you want to measure here (e.g., Income, Test Scores, "Yes/No" answers). Columns grow sideways.
*Pro-Tip*: If you just want a simple profile (like a census), put your main categories in Rows and your Statistics (Counts, Percentages) in Columns.
*Select a row variable and click summary statistics (bottom left) like row/column N% etc, Mean, Variance etc*

*Let's practice with some research questions and apply our knowledge:*
1.Demographic Distribution: How is the student population distributed across different districts and sex?
2. Support vs. Performance: Do students with extra educational support (schoolsup) or those who pay for extra classes (paid) achieve higher finalGrade averages?
3. How is the studytime_hours and final grade for students who have scholarship and have internet access at home, vs those who don't and all the other combinations?
4. Lifestyle Risk Factors: Is there a relationship between workday alcohol consumption (Dalc) and the number of past class failures, and does this pattern differ between sex?
5. The "Social-Academic" Balance: how do levels of freetime and goout (socializing) interact to affect the finalGrade, and does a student’s scholarship_status change this outcome?


`
1. Rows: District,columns:sex | Statistics: Row N% (to see the percentage of sex per district)
`
screenshot goes here

2. Rows: schoolsup, paid | Columns: finalGrade | Statistics: Column Mean, Max,Min, Std

screenshot goes here

3. Rows: scholarship_status, internet (as we are showing the combinations of scholarship and internet, drag internet to the right side of scholarship_status in Rows ) | Columns: studytime_hours, finalGrade | Statistics: Column Mean

screenshot goes here

## SPSS Syntax Quick Reference

Short guide to common SPSS syntax patterns:

### Basic Command Pattern

- Most commands end with a period `.`
- Use `EXECUTE.` to force immediate transformation execution

### Compute Variables

Use `COMPUTE` to create or overwrite a variable from an expression.

```spss
COMPUTE bmi = weight / ((height/100) ** 2).
EXECUTE.
```

### Recode Values

Use `RECODE` to map value groups into new values.

```spss
RECODE score (Lowest thru 39 = 0) (40 thru Highest = 1) INTO pass_flag.
EXECUTE.
```

### Filtering Cases

Use `SELECT IF` to keep rows matching a condition.

```spss
SELECT IF (PrimaryLast = 1).
EXECUTE.
```

### Frequencies for Data Checks

Use `FREQUENCIES` for quick QA on distributions and missingness.

```spss
FREQUENCIES VARIABLES = sex studytime finalGrade.
```

---

## Export Cleaned Dataset

After validation:

1. Save final `.sav`
2. Export to Excel

Path: `File > Export > Excel`

Place cleaned files in `data/cleaned`.

---

## Notes

- Keep the source data unchanged in `data/raw`.
- Keep all transformation steps in `spss/syntax/Syntax.sps` for reproducibility.
