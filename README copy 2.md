# SPSS Student Performance Workflow

![SPSS](https://img.shields.io/badge/Tool-IBM%20SPSS-1261A0?style=for-the-badge)
![Data Cleaning](https://img.shields.io/badge/Stage-Data%20Cleaning-0B8457?style=for-the-badge)
![Feature Engineering](https://img.shields.io/badge/Stage-Feature%20Engineering-6A4C93?style=for-the-badge)

This project is designed as a **PBL (Project-Based Learning)** workflow.
You learn SPSS by completing a realistic end-to-end student performance analysis project instead of only reading theory.

## Why This PBL Project Is Useful

By doing this project, learners can:

- Build practical SPSS skills from raw data to final output.
- Practice data cleaning decisions with real trade-offs (missing values, duplicates, outliers).
- Learn feature engineering for better analysis and visualization.
- Improve confidence with both SPSS GUI and SPSS syntax.
- Produce reproducible work that can be shared in academic or professional settings.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Workspace Structure](#workspace-structure)
3. [Data Import](#data-import)
4. [Phase 1: Data Cleaning](#phase-1-data-cleaning)
5. [Phase 2: Feature Engineering](#phase-2-feature-engineering)
6. [Visualization](#visualization)
7. [Merging Datasets](#merging-datasets)
8. [Select Cases in SPSS](#select-cases-in-spss)
9. [Descriptive Statistics in SPSS](#descriptive-statistics-in-spss)
10. [Custom Tables in SPSS](#custom-tables-in-spss)
11. [Export Cleaned Dataset](#export-cleaned-dataset)
12. [SPSS Syntax Quick Reference](#spss-syntax-quick-reference)
13. [Notes](#notes)

---

## Project Overview

This README documents a complete SPSS workflow for:

- Importing raw student data
- Cleaning inconsistent and missing values
- Handling duplicates and outliers
- Creating engineered features
- Producing charts for analysis
- Exporting a final cleaned dataset

The workflow is reproducible using both SPSS GUI actions and syntax.

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

- `famrel` has high missingness (about 44%): drop the variable if it has low analytical value.
- `studytime` has moderate missingness (about 13%): impute with mean.

Example syntax to drop a variable:

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

It is important to remove duplicates before creating new features to avoid propagating errors.

1. Define matching cases by selecting the variables that identify duplicates.
2. If there is no unique ID, use all variables for duplicate detection.
3. Sort within groups to determine which row becomes the primary case.
4. SPSS creates `PrimaryLast` automatically:
	 - `1` = primary row (keep)
	 - `0` = duplicate row

Keep only primary rows:

```spss
SELECT IF (PrimaryLast = 1).
EXECUTE.
```

> Screenshot placeholder: Duplicate-case settings and filtered result.

---

## Phase 2: Feature Engineering

### 1) Add Student ID

Assign a case-based ID:

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

Path: `Graphs > Chart Builder`

Recommended charts:

- Bar chart
- Boxplot
- Scatterplot (`studytime_hours` vs target variables)

If `studytime` is not converted to a continuous variable, scatterplots stack at only four x-values (1, 2, 3, 4), limiting trend visibility.

> Screenshot placeholder: Bar chart.
>
> Screenshot placeholder: Boxplot.
>
> Screenshot placeholder: Scatterplot.

---

## Merging Datasets

You may need two merge scenarios:

- **Situation 1 (Add Variables):** same students, additional variables from another file.
- **Situation 2 (Add Cases):** new student rows to append.

### Situation 1: Add Variables

Assume your cleaned file is `main.sav` and a second file (`new_variables.sav`) contains the same `student_id` plus new fields.

Create the second dataset (example for IDs):

```spss
INPUT PROGRAM.
LOOP student_id = 1 TO 649.
	END CASE.
END LOOP.
END FILE.
END INPUT PROGRAM.
EXECUTE.
```

Then create:

- `scholarship_status` (1 = Yes, 0 = No)
- `socialMediaEngagement` (1 to 4)

Save as `spss/files/new_variables.sav`.

Merge steps:

1. Open both datasets in SPSS.
2. Sort both by `student_id` (`Data > Sort Cases`).
3. Go to `Data > Merge Files > Add Variables`.
4. Select `new_variables.sav` as source.
5. Match by `student_id`.

> Screenshot placeholder: New variables dataset preview.
>
> Screenshot placeholder: Add Variables merge setup.

Always run frequencies after merging and inspect the output for mismatches or missing values.

### Situation 2: Add Cases

If you have new student responses:

1. Ensure variable names and types match the existing dataset.
2. Go to `Data > Merge Files > Add Cases`.
3. Append the new rows.
4. Run frequencies to validate the merged result.

> Screenshot placeholder: Add Cases merge setup.

---

## Select Cases in SPSS

Purpose: Temporarily isolate a subset of data for analysis while keeping other rows in the file.

Path: `Data > Select Cases > If condition is satisfied > Condition`

Examples:

1. Students with internet access:

```spss
SELECT IF (internet = 'yes').
EXECUTE.
```

2. Students who study 3 or more units:

```spss
SELECT IF (studytime >= 3).
EXECUTE.
```

3. Restore all cases:

```spss
USE ALL.
EXECUTE.
```

> Screenshot placeholder: Select Cases condition dialog.

---

## Descriptive Statistics in SPSS

1. Go to `Analyze > Descriptive Statistics > Descriptives`.
2. Move target variables to the analysis box.
3. Click `Options` to add statistics (variance, range, and others).
4. Click `OK` to run and inspect output.

Frequency tables are also essential descriptive checks for categorical variables.

> Screenshot placeholder: Descriptives output.

---

## Custom Tables in SPSS

Custom Tables are powerful for structured analysis and reporting.

1. Go to `Analyze > Tables > Custom Tables`.
2. Apply the golden rule:
	 - Rows = groups/categories you compare.
	 - Columns = measures/statistics you report.

Practice questions:

1. How is the student population distributed across district and sex?
2. Do `schoolsup` and `paid` groups differ in `finalGrade`?
3. How do `studytime_hours` and `finalGrade` vary across combinations of `scholarship_status` and `internet`?

Example setups:

1. Rows: `district`; Columns: `sex`; Statistics: Row N%
2. Rows: `schoolsup`, `paid`; Columns: `finalGrade`; Statistics: Mean, Max, Min, Std. Dev.
3. Rows: `scholarship_status`, `internet`; Columns: `studytime_hours`, `finalGrade`; Statistics: Mean

> Screenshot placeholder: Custom table example 1.
>
> Screenshot placeholder: Custom table example 2.
>
> Screenshot placeholder: Custom table example 3.

---
### Correlation Analysis
To analyze the relationship between `studytime_hours` and `finalGrade`:

1. Go to `Analyze > Correlate > Bivariate`.
2. Move both variables to the analysis box.
3. Ensure `Pearson` is selected.
4. Click `OK` to run and inspect output or click paste and run from syntax.

box this area: 
quicl guide to interprete correlation output:
- Correlation coefficient (r): ranges from -1 to 1. Closer to ±1 indicates a stronger relationship.
- Sign of r: positive means both variables increase together; negative means one increases while the other decreases.
- Sig. 2-tailed (p-value): typically, p < 0.05 indicates a statistically significant correlation.

> screenshot goes here
---
# Regression Analysis

lets visualize the relationship between `studytime_hours` and `finalGrade` with a scatterplot and then run a simple linear regression:

1. Scatterplot:
	- Go to `Graphs > Chart Builder`.
	- Choose Scatter/Dot and set `studytime_hours` on the x-axis and `finalGrade` on the y-axis.
	- Click `OK` to create the scatterplot.

> screenshot placeholder: Scatterplot of studytime_hours vs finalGrade.
2. Linear Regression:
	- Go to `Analyze > Regression > Linear`.
	- Set `finalGrade` as the dependent variable and `studytime_hours` as the independent variable.
	- Click `OK` to run the regression.
	-run another regression, this time indepentent variables will be `scholarship_status`, ``Dalc` , `scholarship_status`and dependent variable will be `finalGrade`

> screenshot placeholder: Linear regression output.
---

## Export Cleaned Dataset

After validation, export the cleaned data for sharing or further analysis:

1. Save final `.sav`.
2. Export to Excel (`File > Export > Excel`).
3. Store outputs in `data/cleaned`.

> Screenshot placeholder: Export dialog and final file.

---

## SPSS Syntax Quick Reference

### Basic Command Pattern

- Most commands end with a period `.`
- Use `EXECUTE.` to force immediate transformation execution

### Compute Variables

```spss
COMPUTE bmi = weight / ((height / 100) ** 2).
EXECUTE.
```

### Recode Values

```spss
RECODE score (Lowest THRU 39 = 0) (40 THRU Highest = 1) INTO pass_flag.
EXECUTE.
```

### Filter Cases

```spss
SELECT IF (PrimaryLast = 1).
EXECUTE.
```

### Frequencies for Data Checks

```spss
FREQUENCIES VARIABLES = sex studytime finalGrade.
```

---

## Notes

- Keep source data unchanged in `data/raw`.
- Keep all transformation steps in `spss/syntax/Syntax.sps` for reproducibility.
