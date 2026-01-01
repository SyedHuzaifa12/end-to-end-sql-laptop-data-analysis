# End-to-End SQL Data Cleaning & Exploratory Data Analysis

## 📌 Project Overview
This project demonstrates an **end-to-end SQL workflow** involving data cleaning, transformation, and exploratory data analysis (EDA) on an **uncleaned laptop dataset sourced from Kaggle**.

The objective is to showcase **real-world SQL skills** by handling messy data, engineering features, and extracting meaningful business insights using **pure SQL**.

---

## 🎯 Objectives
- Clean and standardize raw, inconsistent data
- Handle missing values and duplicates
- Perform univariate, bivariate, and multivariate analysis
- Engineer meaningful features for deeper insights
- Derive actionable business recommendations

---

## 📁 Project Structure

```text
end-to-end-sql-laptop-data-analysis/
│
├── README.md
│
├── data/
│   ├── laptops_raw.csv
│   └── laptops_cleaned.csv
│
├── sql/
│   ├── data_cleaning.sql
│   └── exploratory_data_analysis.sql
│
├── results/
│   ├── key_insights.md
│   └── business_recommendations.md
│
└── assets/
    └── images/
        ├── workflow_diagram.png
        └── eda_logic_flow.png
```
---

## 📊 Dataset Information
- **Source:** Kaggle
- **Type:** Uncleaned real-world dataset
- **Size:** ~1300 records
- **Domain:** Consumer Electronics (Laptops)

### Key Challenges in Dataset
- Inconsistent data types (numeric values stored as text)
- Embedded units (e.g., `GB`, `kg`, `GHz`)
- Duplicate records
- Missing and malformed values
- Mixed categorical and numerical attributes

---

## 🧹 Data Cleaning (`data_cleaning.sql`)
The data cleaning phase includes:
- Creating a backup of raw data
- Removing null-only and duplicate records
- Standardizing categorical values (OS, brands)
- Converting data types appropriately
- Extracting structured features from text columns
- Feature extraction for CPU, GPU, screen resolution, and memory

---

## 📈 Exploratory Data Analysis (`exploratory_data_analysis.sql`)
EDA was performed entirely using SQL and includes:
- Head, tail, and random sampling
- Numerical analysis (8-number summary, outliers, distributions)
- Categorical analysis (value counts, contingency tables)
- Numerical–numerical and numerical–categorical relationships
- Missing value treatment
- Feature engineering
- One-hot encoding logic

---

## 🧠 Feature Engineering
Key engineered features:
- **PPI (Pixels Per Inch)** – for display quality analysis
- **Screen size category** – small / medium / large
- **Memory type** – SSD / HDD / Hybrid
- **Touchscreen flag**
- **Primary & secondary storage (in GB)**

---

## 📌 Results & Insights
Detailed insights are documented separately:
- 📄 `results/key_insights.md`
- 📄 `results/business_recommendations.md`

---

## 🛠️ Tools & Technologies
- SQL (MySQL 8+)
- Kaggle Dataset
- MySQL Workbench

---

## 🚀 Why This Project Matters
This project reflects **industry-style SQL work**, focusing on:
- Data quality
- Analytical thinking
- Business-oriented insights
- Clean and maintainable SQL scripts

---

## 📬 Contact
If you’d like to discuss this project or provide feedback, feel free to connect.
