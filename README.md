# **Crime Data Processing Pipeline**

---

## **Overview**
This R script processes, cleans, and aggregates crime data from historical records and multiple yearly datasets (2020, 2021). It consolidates information into a structured format, applies data transformations, and integrates supplementary datasets like population data, COVID-19 cases, and socio-economic indicators for comprehensive analysis.

---

## **Table of Contents**
1. [Purpose](#purpose)  
2. [Features](#features)  
3. [Workflow](#workflow)  
4. [Outputs](#outputs)  
5. [Requirements](#requirements)  
6. [Use Cases](#use-cases)

---

## **Purpose**
The script aims to:
- Process crime data files from various Excel sources.
- Standardize, clean, and aggregate the data for analysis.
- Integrate population, COVID-19, and socio-economic data.
- Prepare time-series crime data at detailed geographic levels.

---

## **Features**
- **Dynamic File Handling**: Handles multiple folders and Excel files with varying structures.
- **Data Cleaning**: Standardizes column names, filters invalid data, and resolves location inconsistencies.
- **Data Aggregation**: Summarizes crime data by year, week, and geographic areas.
- **Bogotá-Specific Processing**: Processes data for Bogotá at the UPZ (Zonal Planning Unit) level.
- **Normalization**: Adjusts crime counts based on population data.
- **Quarantine Integration**: Adds quarantine period flags for pandemic-specific analysis.
- **Supplementary Data**:
  - **COVID-19 cases**
  - **Socio-economic indicators** from the 2017 Multipurpose Survey.

---

## **Workflow**

### 1. **Data Preparation**
- Reads crime data from Excel files.
- Cleans and standardizes column names using helper functions (`get_names`, `change_col_names`).

### 2. **Data Cleaning**
- Filters rows with missing `municipio` and incorrect locality entries.
- Resolves location inconsistencies by standardizing codes.

### 3. **Data Aggregation**
- Groups crime events by:
  - **Year (Año)**
  - **Week (Semana)**
  - **Geographic areas** (`departamento`, `municipio`, `barrio`).

### 4. **Bogotá-Specific Processing**
- Filters crime data for Bogotá.
- Aggregates weekly crime counts at the UPZ level.
- Ensures a complete time-series by filling missing dates.

### 5. **Supplementary Data Integration**
- **Population Data**: Adjusts crime counts per 1,000 inhabitants.  
- **COVID-19 Cases**: Adds normalized COVID-19 case rates per locality.  
- **Socio-economic Data**: Merges survey-based covariates such as unemployment, poverty, and infrastructure conditions.

### 6. **Quarantine Information**
- Adds a `cuarentena` flag to identify specific weeks under lockdown.

### 7. **Final Output**
- Combines all processed data into a unified dataset for further analysis.

---

## **Outputs**

### **Intermediate Outputs**
- **Cleaned Crime Datasets**:  
  Individual CSV files for each crime type and year, stored in:
  ```
  Bases Procesadas/Series Históricas/
  ```

- **Bogotá-Specific Aggregates**:  
  Weekly aggregated crime data at UPZ level.

### **Final Output**
A unified CSV file containing:
- Crime counts normalized by population.
- COVID-19 case rates.
- Socio-economic indicators.
- Quarantine flags.  

**File Location**:  
```
Bases Procesadas/base_final22_rev.csv
```

---

## **Requirements**

### **Software**
- R (version ≥ 4.0.0)
- R Libraries:
  - `tidyverse`
  - `readxl`
  - `lubridate`
  - `stringi`

### **Data Inputs**
- Excel files of crime data.
- Population datasets.
- COVID-19 case files.
- Socio-economic survey data (2017 Multipurpose Survey).

---

## **Use Cases**
- **Crime Trend Analysis**:  
  Analyze crime trends over time across geographic areas (e.g., departments, UPZ levels in Bogotá).

- **Impact of COVID-19**:  
  Study the relationship between quarantine periods and changes in crime rates.

- **Socio-economic Correlation**:  
  Investigate correlations between socio-economic conditions (e.g., unemployment, poverty) and crime occurrences.

---

## **How to Use**
1. Place all required data files in the specified folder structure:
   ```
   Bases Policia/Información Historica/
   Bases Policia/Datos 2020/
   Bases Policia/Datos 2021/
   EM 2017/Planeación Distrital/
   covid_cases/
   ```
2. Run the script in R or RStudio.
3. Access the output datasets in the `Bases Procesadas/` directory.

---

## **Contributing**
Feel free to submit issues, feedback, or feature requests.

---

## **License**
This project is licensed under the MIT License.

