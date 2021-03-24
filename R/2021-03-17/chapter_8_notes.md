---
title: 'Walkthrough 2: Approaching Gradebook Data From a Data Science Perspective'
subtitle: 'Chapter 8 of "Data Science in Education Using R"'
author: "Presented by Morgan Grovenburg"
date: "March 17, 2021"
output: 
  html_document:
    keep_md: TRUE
---



## 8.1 Topics Emphasized

-   Tidying data

-   Transforming data

-   Visualizing data

-   Modeling data

## 8.2 Functions Introduced

-   `janitor::remove_empty()`

-   `stringr::contains()`

-   `cor()`

## 8.3 Vocabulary

-   correlation

-   directory

-   environment

-   linear model

-   linearity

-   missing values/ NA

-   outliers

-   string

## 8.4 Chapter Overview

This walkthrough explores the ubiquitous but not-often-analyzed classroom gradebook dataset. We will use data science tools and techniques and focus more on analyses, including correlations and linear models.

### 8.4.1 Background

This walkthrough goes through a series of analyses using the data science framework. The first analysis centers around a common K-12 classroom tool: the gradebook. While gradebook data is common in education, it is sometimes ignored in favor of data collected by evaluators and researchers or data from state-wide tests. Nevertheless, it represents an important, untapped data source, and one for which a data science approach can reveal the potential of analyzing a range of education data sources.

### 8.4.2 Data Sources

This walkthrough uses a simulated dataset. We can [download the excel file from GitHub](https://github.com/data-edu/data-science-in-education/blob/master/data/gradebooks/ExcelGradeBook.xlsx) to our computer by clicking on the 'Download' button.

### 8.4.3 Methods

This analysis uses a linear model, which relates one or more X, or independent variables, to a Y, or dependent variable, and a correlation analysis.

## 8.5 Load Packages

Begin by loading the libraries that will be used:


```r
# Install packages only once
#install.packages("tidyverse")
#install.packages("here")
#install.packages("readxl")
#install.packages("janitor")
#install.packages("remotes")
#remotes::install_github("data-edu/dataedu")

# Load libraries
library(tidyverse)
library(here)
library(readxl) #to read and import Excel spreadsheets
library(janitor) #provides a number of functions related to cleaning and preparing data
library(dataedu)
library(knitr) #not part of walkthrough
```

## 8.6 Import Data

[Download the excel file from GitHub](https://github.com/data-edu/data-science-in-education/blob/master/data/gradebooks/ExcelGradeBook.xlsx) if you have not already done so.

Here's a snippet of the downloaded excel file: ![ExcelGradeBook.xlsx](original_excel_screenshot.PNG "ExcelGradeBook.xlsx")

### 8.6.1 Import Using a File Path

The function `getwd()` will help locate the current working directory. This tells where on the computer R is currently working with files.


```r
# See the current working directory
getwd()
```

```
## [1] "C:/Users/laptop/Documents/R/bookclub-dsieur/R/2021-03-17"
```

The following code runs the function `read_excel()` which reads and saves the data from `ExcelGradeBook.xlsx` to an object also called `ExcelGradeBook`. Note the two arguments specified in this code: `sheet = 1` and `skip = 10`. This Excel file is similar to one you might encounter in real life with superfluous features that we are not interested in. This file has 5 different sheets and the first 10 rows contain things we won't need. Thus, `sheet = 1` tells `read_excel()` to just read the first sheet in the file and disregard the rest. Then, `skip = 10` tells `read_excel()` to skip reading the first 10 rows of the sheet and start reading from row 11, which is where the column headers and data actually start inside the Excel file.


```r
ExcelGradeBook <- read_excel("C:/Users/laptop/Downloads/ExcelGradeBook.xlsx", sheet = 1, skip = 10)
```

Note that the above path is unique to my machine and will not work for you. Please adjust the path to match the specifics of your file location.

You may have noticed that the path I used above does not match my working directory. When I downloaded the file, it automatically went to my Downloads folder which is not in my working directory. One benefit of using the path file is that the file does not need to be located in my working directory to be imported. However, there is a big con to this that I will explain next.

### 8.6.2 Import Using `here()`

Alternatively, we can read in the file using `here()`. This uses your root directory, so you will need to make sure the file is located there. So I made a copy of the file from my downloads from the previous example (if I move it, the previous example won't work) to my root directory C:/Users/laptop/Documents/R/bookclub-dsieur. The reason to do this method over the path method above is that it makes our code reproducible when we share with others or even when we, individually, use a different computer! Instead of needing to edit the code itself, everything will run (without edits) as long as all of the files are located in the current root directory! Very cool! (For more information on the `here package` and project-oriented workflow, see [this article by Jenny Bryan](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/))


```r
# Use readxl package to read and import file and assign it a name
ExcelGradeBook <-
  read_excel(
    here("R", "2021-03-17", "ExcelGradeBook.xlsx"),
    sheet = 1,
    skip = 10
  )
```

`ExcelGradeBook.xlsx` is located in the folder `2021-03-17` in the folder `R` which is in my root directory.

The `ExcelGradeBook` file is now imported into RStudio. Next, we'll assign the data frame to a new name using the code below. Renaming cumbersome filenames can improve the readability of the code and make it easier for the user to call on the dataset later on in the code.


```r
# Rename data frame
gradebook <- ExcelGradeBook
```

The environment now has two versions of the dataset. There is `ExcelGradeBook`, which is the original dataset we've imported. There is also `gradebook`, which is a copy of `ExcelGradeBook`. We will make our edits to the `gradebook` version. If we make a mistake and mess up the `gradebook` data frame and are not able to fix it, we can reset the data frame to return to the same state as the original `ExcelGradeBook` data frame by running `gradebook <- ExcelGradeBook` again. This will overwrite any errors in the `gradebook` data frame with the originally imported `ExcelGradeBook` data frame.

## 8.7 Process Data

### 8.7.1 Tidy Data

Let's take a look at the first five observations our data frame:


```r
kable(gradebook[1:5, ])
```



| Class|Name      |Race |Gender |Age |Repeated Grades |Financial Status |Absent |Late |Make your own categories | Running Average|Letter Grade | Homeworks| Classworks| Formative Assessments| Projects| Summative Assessments|Another Type 2 | Classwork 1| Homework 1| Classwork 2|Homework 2 |Classwork 3 | Classwork 4| Classwork 5| Classwork 6| Homework 3| Formative Assessment 1| Project 1| Classwork 7| Homework 4|Project 2 | Classwork 8| Homework 5| Project 3| Homework 6| Classwork 9| Homework 7| Homework 8| Project 4| Project 5| Formative Assessment 2| Project 6| Classwork 10| Homework 9| Classwork 11| Homework 10| Classwork 12| Classwork 13| Project 7| Classwork 14| Classwork 15| Homework 11| Summative Assessment 1| Classwork 16| Homework 12| Classwork 17| Homework 13| Project 8| Project 9| Project 10| Summative Assessment 2|Assessment &#124; Insert new columns before here |
|-----:|:---------|:----|:------|:---|:---------------|:----------------|:------|:----|:------------------------|---------------:|:------------|---------:|----------:|---------------------:|--------:|---------------------:|:--------------|-----------:|----------:|-----------:|:----------|:-----------|-----------:|-----------:|-----------:|----------:|----------------------:|---------:|-----------:|----------:|:---------|-----------:|----------:|---------:|----------:|-----------:|----------:|----------:|---------:|---------:|----------------------:|---------:|------------:|----------:|------------:|-----------:|------------:|------------:|---------:|------------:|------------:|-----------:|----------------------:|------------:|-----------:|------------:|-----------:|---------:|---------:|----------:|----------------------:|:------------------------------------------------|
|     1|Student 1 |NA   |NA     |NA  |NA              |NA               |1      |0    |NA                       |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|NA             |          13|         10|          15|5          |15          |          15|          15|          15|         10|                     45|        10|          15|         10|10        |          15|          5|        10|          5|          15|         10|         10|        10|        10|                     50|        10|           15|         10|           15|           5|           15|           15|        10|           15|           15|          10|                     50|           15|          10|           15|           5|        10|        10|         10|                     30|NA                                               |
|     1|Student 2 |NA   |NA     |NA  |NA              |NA               |0      |1    |NA                       |        79.35196|C+           |  53.33333|   88.23529|              86.66667|       87|              73.33333|NA             |          10|          9|          12|4          |15          |          12|          15|          15|          7|                     44|         9|          11|          3|10        |          15|          0|        10|          4|          15|          0|          4|         9|         8|                     46|        10|           12|          0|           15|           3|            6|           14|         5|           15|           15|          10|                     40|           15|           9|           13|           3|         9|         7|         10|                     22|NA                                               |
|     1|Student 3 |NA   |NA     |NA  |NA              |NA               |2      |0    |NA                       |        86.65000|B+           |  62.00000|   88.33333|              93.33333|       86|             100.00000|NA             |          10|          9|          12|Excused    |Excused     |          12|          15|          15|          7|                     50|         9|          14|          3|10        |          15|          3|        10|          5|          15|          1|          4|         9|         8|                     50|         8|           10|          3|           15|           4|            6|           14|         7|           14|           15|          10|                     40|           15|          10|           15|           3|         9|         7|          9|                     30|NA                                               |
|     1|Student 4 |NA   |NA     |NA  |NA              |NA               |0      |0    |NA                       |        80.22353|B-           |  60.00000|   78.82353|              84.00000|       88|              80.00000|NA             |          10|          9|           5|4          |15          |          12|          15|          15|          7|                     40|         9|          13|          3|10        |          15|          2|        10|          4|          15|          3|          4|        10|        10|                     46|         9|            9|          3|           15|           2|            6|            9|         5|           11|           15|          10|                     40|           13|           9|            8|           3|         9|         8|          8|                     24|NA                                               |
|     1|Student 5 |NA   |NA     |NA  |NA              |NA               |0      |0    |NA                       |        86.50812|B+           |  72.38095|   74.11765|              86.66667|       92|              96.66667|NA             |           7|         10|          11|5          |8           |          12|           7|          12|         10|                     39|        10|          13|          5|10        |          15|          0|        10|          4|          14|          8|          9|        10|        10|                     41|        10|           13|          3|           13|           1|            4|           13|         6|           15|           15|           9|                     50|           15|           9|            2|           3|         8|         8|         10|                     29|NA                                               |

Yikes. We have rows and columns we don't need and column names that have spaces between words. The data is **not** tidy. All these things make the data tough to work with.

We COULD begin to overcome these challenges before importing the file into RStudio by deleting the unnecessary parts of the Excel file then saving it as a `.csv` file. However, if we clean the file outside of R, this means if we ever have to clean it up again (say, if the dataset is accidentally deleted and we need to re-download it from the original source) we would have to do everything from the beginning, and may not recall exactly what we did in Excel prior to importing the data to R.

It is recommended to clean the original data in R so that we can recreate all the steps necessary for analysis.

### 8.7.2 About {janitor}

{janitor} has many handy functions to clean and tabulate data. Some examples include:

-   `clean_names()`, which takes messy column names that have periods, capitalized letters, spaces, etc. into R-friendly column names

-   `get_dupes()`, which identifies and examines duplicate records

-   `tabyl()`, which tabulates data in a `data.frame` format, and can be 'adorned' with the `adorn_` functions to add total rows, percentages, and other dressings

Let's look at our column names:


```r
# look at original column names
colnames(gradebook)
```

```
##  [1] "Class"                                      
##  [2] "Name"                                       
##  [3] "Race"                                       
##  [4] "Gender"                                     
##  [5] "Age"                                        
##  [6] "Repeated Grades"                            
##  [7] "Financial Status"                           
##  [8] "Absent"                                     
##  [9] "Late"                                       
## [10] "Make your own categories"                   
## [11] "Running Average"                            
## [12] "Letter Grade"                               
## [13] "Homeworks"                                  
## [14] "Classworks"                                 
## [15] "Formative Assessments"                      
## [16] "Projects"                                   
## [17] "Summative Assessments"                      
## [18] "Another Type 2"                             
## [19] "Classwork 1"                                
## [20] "Homework 1"                                 
## [21] "Classwork 2"                                
## [22] "Homework 2"                                 
## [23] "Classwork 3"                                
## [24] "Classwork 4"                                
## [25] "Classwork 5"                                
## [26] "Classwork 6"                                
## [27] "Homework 3"                                 
## [28] "Formative Assessment 1"                     
## [29] "Project 1"                                  
## [30] "Classwork 7"                                
## [31] "Homework 4"                                 
## [32] "Project 2"                                  
## [33] "Classwork 8"                                
## [34] "Homework 5"                                 
## [35] "Project 3"                                  
## [36] "Homework 6"                                 
## [37] "Classwork 9"                                
## [38] "Homework 7"                                 
## [39] "Homework 8"                                 
## [40] "Project 4"                                  
## [41] "Project 5"                                  
## [42] "Formative Assessment 2"                     
## [43] "Project 6"                                  
## [44] "Classwork 10"                               
## [45] "Homework 9"                                 
## [46] "Classwork 11"                               
## [47] "Homework 10"                                
## [48] "Classwork 12"                               
## [49] "Classwork 13"                               
## [50] "Project 7"                                  
## [51] "Classwork 14"                               
## [52] "Classwork 15"                               
## [53] "Homework 11"                                
## [54] "Summative Assessment 1"                     
## [55] "Classwork 16"                               
## [56] "Homework 12"                                
## [57] "Classwork 17"                               
## [58] "Homework 13"                                
## [59] "Project 8"                                  
## [60] "Project 9"                                  
## [61] "Project 10"                                 
## [62] "Summative Assessment 2"                     
## [63] "Assessment | Insert new columns before here"
```

That output is long.

We can just look at the first ten by using `head()`:


```r
# look at original column names
head(colnames(gradebook)) 
```

```
## [1] "Class"           "Name"            "Race"            "Gender"         
## [5] "Age"             "Repeated Grades"
```

That's better.

Now let's clean the names and compare:


```r
gradebook <- 
  gradebook %>% 
  clean_names()

# look at cleaned column names
head(colnames(gradebook))
```

```
## [1] "class"           "name"            "race"            "gender"         
## [5] "age"             "repeated_grades"
```

Review the first five observations of the `gradebook` data frame now:


```r
kable(gradebook[1:5, ])
```



| class|name      |race |gender |age |repeated_grades |financial_status |absent |late |make_your_own_categories | running_average|letter_grade | homeworks| classworks| formative_assessments| projects| summative_assessments|another_type_2 | classwork_1| homework_1| classwork_2|homework_2 |classwork_3 | classwork_4| classwork_5| classwork_6| homework_3| formative_assessment_1| project_1| classwork_7| homework_4|project_2 | classwork_8| homework_5| project_3| homework_6| classwork_9| homework_7| homework_8| project_4| project_5| formative_assessment_2| project_6| classwork_10| homework_9| classwork_11| homework_10| classwork_12| classwork_13| project_7| classwork_14| classwork_15| homework_11| summative_assessment_1| classwork_16| homework_12| classwork_17| homework_13| project_8| project_9| project_10| summative_assessment_2|assessment_insert_new_columns_before_here |
|-----:|:---------|:----|:------|:---|:---------------|:----------------|:------|:----|:------------------------|---------------:|:------------|---------:|----------:|---------------------:|--------:|---------------------:|:--------------|-----------:|----------:|-----------:|:----------|:-----------|-----------:|-----------:|-----------:|----------:|----------------------:|---------:|-----------:|----------:|:---------|-----------:|----------:|---------:|----------:|-----------:|----------:|----------:|---------:|---------:|----------------------:|---------:|------------:|----------:|------------:|-----------:|------------:|------------:|---------:|------------:|------------:|-----------:|----------------------:|------------:|-----------:|------------:|-----------:|---------:|---------:|----------:|----------------------:|:-----------------------------------------|
|     1|Student 1 |NA   |NA     |NA  |NA              |NA               |1      |0    |NA                       |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|NA             |          13|         10|          15|5          |15          |          15|          15|          15|         10|                     45|        10|          15|         10|10        |          15|          5|        10|          5|          15|         10|         10|        10|        10|                     50|        10|           15|         10|           15|           5|           15|           15|        10|           15|           15|          10|                     50|           15|          10|           15|           5|        10|        10|         10|                     30|NA                                        |
|     1|Student 2 |NA   |NA     |NA  |NA              |NA               |0      |1    |NA                       |        79.35196|C+           |  53.33333|   88.23529|              86.66667|       87|              73.33333|NA             |          10|          9|          12|4          |15          |          12|          15|          15|          7|                     44|         9|          11|          3|10        |          15|          0|        10|          4|          15|          0|          4|         9|         8|                     46|        10|           12|          0|           15|           3|            6|           14|         5|           15|           15|          10|                     40|           15|           9|           13|           3|         9|         7|         10|                     22|NA                                        |
|     1|Student 3 |NA   |NA     |NA  |NA              |NA               |2      |0    |NA                       |        86.65000|B+           |  62.00000|   88.33333|              93.33333|       86|             100.00000|NA             |          10|          9|          12|Excused    |Excused     |          12|          15|          15|          7|                     50|         9|          14|          3|10        |          15|          3|        10|          5|          15|          1|          4|         9|         8|                     50|         8|           10|          3|           15|           4|            6|           14|         7|           14|           15|          10|                     40|           15|          10|           15|           3|         9|         7|          9|                     30|NA                                        |
|     1|Student 4 |NA   |NA     |NA  |NA              |NA               |0      |0    |NA                       |        80.22353|B-           |  60.00000|   78.82353|              84.00000|       88|              80.00000|NA             |          10|          9|           5|4          |15          |          12|          15|          15|          7|                     40|         9|          13|          3|10        |          15|          2|        10|          4|          15|          3|          4|        10|        10|                     46|         9|            9|          3|           15|           2|            6|            9|         5|           11|           15|          10|                     40|           13|           9|            8|           3|         9|         8|          8|                     24|NA                                        |
|     1|Student 5 |NA   |NA     |NA  |NA              |NA               |0      |0    |NA                       |        86.50812|B+           |  72.38095|   74.11765|              86.66667|       92|              96.66667|NA             |           7|         10|          11|5          |8           |          12|           7|          12|         10|                     39|        10|          13|          5|10        |          15|          0|        10|          4|          14|          8|          9|        10|        10|                     41|        10|           13|          3|           13|           1|            4|           13|         6|           15|           15|           9|                     50|           15|           9|            2|           3|         8|         8|         10|                     29|NA                                        |

The data frame looks a bit cleaner but there are still some things we can remove.

We can remove the columns, rows, or both that have no information in them with `remove_empty()`:


```r
# Removing rows with nothing but missing data
gradebook <- 
  gradebook %>% 
  remove_empty(c("rows", "cols"))
```

And review the first five observations of our data frame again:


```r
kable(gradebook[1:5, ])
```



| class|name      |absent |late | running_average|letter_grade | homeworks| classworks| formative_assessments| projects| summative_assessments| classwork_1| homework_1| classwork_2|homework_2 |classwork_3 | classwork_4| classwork_5| classwork_6| homework_3| formative_assessment_1| project_1| classwork_7| homework_4|project_2 | classwork_8| homework_5| project_3| homework_6| classwork_9| homework_7| homework_8| project_4| project_5| formative_assessment_2| project_6| classwork_10| homework_9| classwork_11| homework_10| classwork_12| classwork_13| project_7| classwork_14| classwork_15| homework_11| summative_assessment_1| classwork_16| homework_12| classwork_17| homework_13| project_8| project_9| project_10| summative_assessment_2|
|-----:|:---------|:------|:----|---------------:|:------------|---------:|----------:|---------------------:|--------:|---------------------:|-----------:|----------:|-----------:|:----------|:-----------|-----------:|-----------:|-----------:|----------:|----------------------:|---------:|-----------:|----------:|:---------|-----------:|----------:|---------:|----------:|-----------:|----------:|----------:|---------:|---------:|----------------------:|---------:|------------:|----------:|------------:|-----------:|------------:|------------:|---------:|------------:|------------:|-----------:|----------------------:|------------:|-----------:|------------:|-----------:|---------:|---------:|----------:|----------------------:|
|     1|Student 1 |1      |0    |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|          13|         10|          15|5          |15          |          15|          15|          15|         10|                     45|        10|          15|         10|10        |          15|          5|        10|          5|          15|         10|         10|        10|        10|                     50|        10|           15|         10|           15|           5|           15|           15|        10|           15|           15|          10|                     50|           15|          10|           15|           5|        10|        10|         10|                     30|
|     1|Student 2 |0      |1    |        79.35196|C+           |  53.33333|   88.23529|              86.66667|       87|              73.33333|          10|          9|          12|4          |15          |          12|          15|          15|          7|                     44|         9|          11|          3|10        |          15|          0|        10|          4|          15|          0|          4|         9|         8|                     46|        10|           12|          0|           15|           3|            6|           14|         5|           15|           15|          10|                     40|           15|           9|           13|           3|         9|         7|         10|                     22|
|     1|Student 3 |2      |0    |        86.65000|B+           |  62.00000|   88.33333|              93.33333|       86|             100.00000|          10|          9|          12|Excused    |Excused     |          12|          15|          15|          7|                     50|         9|          14|          3|10        |          15|          3|        10|          5|          15|          1|          4|         9|         8|                     50|         8|           10|          3|           15|           4|            6|           14|         7|           14|           15|          10|                     40|           15|          10|           15|           3|         9|         7|          9|                     30|
|     1|Student 4 |0      |0    |        80.22353|B-           |  60.00000|   78.82353|              84.00000|       88|              80.00000|          10|          9|           5|4          |15          |          12|          15|          15|          7|                     40|         9|          13|          3|10        |          15|          2|        10|          4|          15|          3|          4|        10|        10|                     46|         9|            9|          3|           15|           2|            6|            9|         5|           11|           15|          10|                     40|           13|           9|            8|           3|         9|         8|          8|                     24|
|     1|Student 5 |0      |0    |        86.50812|B+           |  72.38095|   74.11765|              86.66667|       92|              96.66667|           7|         10|          11|5          |8           |          12|           7|          12|         10|                     39|        10|          13|          5|10        |          15|          0|        10|          4|          14|          8|          9|        10|        10|                     41|        10|           13|          3|           13|           1|            4|           13|         6|           15|           15|           9|                     50|           15|           9|            2|           3|         8|         8|         10|                     29|

Now that the empty rows and columns have been removed, we notice there are two columns, `absent` and `late`, where it seems someone started putting data into but then decided to stop:


```r
gradebook %>% 
  select(absent, late)
```

```
## # A tibble: 25 x 2
##    absent late 
##    <chr>  <chr>
##  1 1      0    
##  2 0      1    
##  3 2      0    
##  4 0      0    
##  5 0      0    
##  6 0      0    
##  7 0      0    
##  8 0      0    
##  9 0      0    
## 10 <NA>   <NA> 
## # ... with 15 more rows
```

These two columns didn't get removed by the last chunk of code because they technically contained some data in those columns. Since the simulated enterer of this simulated class data decided to abandon using the `absent` and `late` columns in this gradebook, we can remove it from our data frame as well.

Let's use the `select()` function, which tells R what columns we want to keep. We'll use negative signs to say we want the dataset without `absent` and `late`:


```r
# Remove a targeted column because we don't use absent and late at this school.
gradebook <- 
  gradebook %>% 
  select(-absent, -late)
```

Inspect the first five observations of the data frame once more to see the difference:


```r
kable(gradebook[1:5, ])
```



| class|name      | running_average|letter_grade | homeworks| classworks| formative_assessments| projects| summative_assessments| classwork_1| homework_1| classwork_2|homework_2 |classwork_3 | classwork_4| classwork_5| classwork_6| homework_3| formative_assessment_1| project_1| classwork_7| homework_4|project_2 | classwork_8| homework_5| project_3| homework_6| classwork_9| homework_7| homework_8| project_4| project_5| formative_assessment_2| project_6| classwork_10| homework_9| classwork_11| homework_10| classwork_12| classwork_13| project_7| classwork_14| classwork_15| homework_11| summative_assessment_1| classwork_16| homework_12| classwork_17| homework_13| project_8| project_9| project_10| summative_assessment_2|
|-----:|:---------|---------------:|:------------|---------:|----------:|---------------------:|--------:|---------------------:|-----------:|----------:|-----------:|:----------|:-----------|-----------:|-----------:|-----------:|----------:|----------------------:|---------:|-----------:|----------:|:---------|-----------:|----------:|---------:|----------:|-----------:|----------:|----------:|---------:|---------:|----------------------:|---------:|------------:|----------:|------------:|-----------:|------------:|------------:|---------:|------------:|------------:|-----------:|----------------------:|------------:|-----------:|------------:|-----------:|---------:|---------:|----------:|----------------------:|
|     1|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|          13|         10|          15|5          |15          |          15|          15|          15|         10|                     45|        10|          15|         10|10        |          15|          5|        10|          5|          15|         10|         10|        10|        10|                     50|        10|           15|         10|           15|           5|           15|           15|        10|           15|           15|          10|                     50|           15|          10|           15|           5|        10|        10|         10|                     30|
|     1|Student 2 |        79.35196|C+           |  53.33333|   88.23529|              86.66667|       87|              73.33333|          10|          9|          12|4          |15          |          12|          15|          15|          7|                     44|         9|          11|          3|10        |          15|          0|        10|          4|          15|          0|          4|         9|         8|                     46|        10|           12|          0|           15|           3|            6|           14|         5|           15|           15|          10|                     40|           15|           9|           13|           3|         9|         7|         10|                     22|
|     1|Student 3 |        86.65000|B+           |  62.00000|   88.33333|              93.33333|       86|             100.00000|          10|          9|          12|Excused    |Excused     |          12|          15|          15|          7|                     50|         9|          14|          3|10        |          15|          3|        10|          5|          15|          1|          4|         9|         8|                     50|         8|           10|          3|           15|           4|            6|           14|         7|           14|           15|          10|                     40|           15|          10|           15|           3|         9|         7|          9|                     30|
|     1|Student 4 |        80.22353|B-           |  60.00000|   78.82353|              84.00000|       88|              80.00000|          10|          9|           5|4          |15          |          12|          15|          15|          7|                     40|         9|          13|          3|10        |          15|          2|        10|          4|          15|          3|          4|        10|        10|                     46|         9|            9|          3|           15|           2|            6|            9|         5|           11|           15|          10|                     40|           13|           9|            8|           3|         9|         8|          8|                     24|
|     1|Student 5 |        86.50812|B+           |  72.38095|   74.11765|              86.66667|       92|              96.66667|           7|         10|          11|5          |8           |          12|           7|          12|         10|                     39|        10|          13|          5|10        |          15|          0|        10|          4|          14|          8|          9|        10|        10|                     41|        10|           13|          3|           13|           1|            4|           13|         6|           15|           15|           9|                     50|           15|           9|            2|           3|         8|         8|         10|                     29|

### 8.7.3 Create New Variables and Further Process the Data

The following code chunk first creates a new data frame named `classwork_df`, then selects particular variables from the gradebook dataset using `select()`, and finally 'gathers' all the homework data into new columns.

We can use functions from the package {stringr} within `select()`. Here, we'll use the function `contains()` from {stringr} to tell R to select columns that contain a certain string (that is, text). The function searches for any column with the string `classwork_`. The underscore makes sure the variables from `classwork_1` all the way to `classwork_17` are included in `classwork_df`.

`pivot_longer()` transforms the dataset into tidy data, where each variable forms a column, each observation forms a row, and each type of observational unit forms a table.

Note that `scores` are in character format. We use `mutate()` to transform them to numeric.


```r
# Creates new data frame, selects desired variables from gradebook, and gathers all classwork scores into key/value pairs
classwork_df <-
  gradebook %>%
  select(
    name,
    running_average,
    letter_grade,
    homeworks,
    classworks,
    formative_assessments,
    projects,
    summative_assessments,
    contains("classwork_")) %>%
  mutate_at(vars(contains("classwork_")), list(~ as.numeric(.))) %>%
  pivot_longer(
    cols = contains("classwork_"),
    names_to = "classwork_number",
    values_to = "score"
  )
```

```
## Warning in ~as.numeric(.): NAs introduced by coercion
```

View the first 20 observations of the new data frame and notice which columns were selected for this new data frame. Also, note how all the classwork scores were gathered under new columns `classwork_number` and `score`. We will use this `classwork_df` data frame later:


```r
kable(classwork_df[1:20, ])
```



|name      | running_average|letter_grade | homeworks| classworks| formative_assessments| projects| summative_assessments|classwork_number | score|
|:---------|---------------:|:------------|---------:|----------:|---------------------:|--------:|---------------------:|:----------------|-----:|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_1      |    13|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_2      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_3      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_4      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_5      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_6      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_7      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_8      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_9      |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_10     |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_11     |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_12     |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_13     |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_14     |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_15     |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_16     |    15|
|Student 1 |        99.38235|A+           | 100.00000|   99.21569|              96.66667|      100|             100.00000|classwork_17     |    15|
|Student 2 |        79.35196|C+           |  53.33333|   88.23529|              86.66667|       87|              73.33333|classwork_1      |    10|
|Student 2 |        79.35196|C+           |  53.33333|   88.23529|              86.66667|       87|              73.33333|classwork_2      |    12|
|Student 2 |        79.35196|C+           |  53.33333|   88.23529|              86.66667|       87|              73.33333|classwork_3      |    15|

## 8.8 Analysis

### 8.8.1 Visualize Data

Visual representations of data are more human friendly than just looking at numbers alone. This next line of code shows a summary of the data by each column:


```r
# Summary of the data by columns
summary(gradebook)
```

```
##      class       name           running_average letter_grade      
##  Min.   :1   Length:25          Min.   :78.79   Length:25         
##  1st Qu.:1   Class :character   1st Qu.:80.58   Class :character  
##  Median :1   Mode  :character   Median :84.76   Mode  :character  
##  Mean   :1                      Mean   :86.23                     
##  3rd Qu.:1                      3rd Qu.:90.48                     
##  Max.   :1                      Max.   :99.38                     
##    homeworks        classworks    formative_assessments    projects     
##  Min.   : 53.33   Min.   :70.98   Min.   : 67.33        Min.   : 84.00  
##  1st Qu.: 68.57   1st Qu.:76.86   1st Qu.: 79.33        1st Qu.: 88.00  
##  Median : 72.38   Median :82.35   Median : 85.33        Median : 92.00  
##  Mean   : 76.31   Mean   :83.85   Mean   : 85.71        Mean   : 91.55  
##  3rd Qu.: 86.67   3rd Qu.:91.37   3rd Qu.: 94.00        3rd Qu.: 94.00  
##  Max.   :100.00   Max.   :99.22   Max.   :100.00        Max.   :100.00  
##  summative_assessments  classwork_1      homework_1     classwork_2   
##  Min.   : 50.00        Min.   : 5.00   Min.   : 8.00   Min.   : 5.00  
##  1st Qu.: 80.00        1st Qu.: 8.00   1st Qu.: 9.00   1st Qu.: 8.00  
##  Median : 83.33        Median :11.00   Median : 9.00   Median :12.00  
##  Mean   : 86.53        Mean   :10.92   Mean   : 9.24   Mean   :10.68  
##  3rd Qu.: 96.67        3rd Qu.:13.00   3rd Qu.:10.00   3rd Qu.:14.00  
##  Max.   :113.33        Max.   :15.00   Max.   :10.00   Max.   :15.00  
##   homework_2        classwork_3         classwork_4     classwork_5  
##  Length:25          Length:25          Min.   :12.00   Min.   : 5.0  
##  Class :character   Class :character   1st Qu.:13.00   1st Qu.: 8.0  
##  Mode  :character   Mode  :character   Median :14.00   Median :12.0  
##                                        Mean   :13.72   Mean   :11.4  
##                                        3rd Qu.:15.00   3rd Qu.:15.0  
##                                        Max.   :15.00   Max.   :15.0  
##   classwork_6      homework_3    formative_assessment_1   project_1    
##  Min.   : 6.00   Min.   : 0.00   Min.   :25.00          Min.   : 7.00  
##  1st Qu.: 9.00   1st Qu.: 7.00   1st Qu.:36.00          1st Qu.: 9.00  
##  Median :14.00   Median : 9.00   Median :41.00          Median :10.00  
##  Mean   :12.08   Mean   : 8.48   Mean   :41.08          Mean   : 9.16  
##  3rd Qu.:15.00   3rd Qu.:10.00   3rd Qu.:48.00          3rd Qu.:10.00  
##  Max.   :15.00   Max.   :10.00   Max.   :50.00          Max.   :10.00  
##   classwork_7      homework_4     project_2          classwork_8   homework_5  
##  Min.   :11.00   Min.   : 0.00   Length:25          Min.   :15   Min.   :0.00  
##  1st Qu.:13.00   1st Qu.: 3.00   Class :character   1st Qu.:15   1st Qu.:3.00  
##  Median :13.00   Median : 9.00   Mode  :character   Median :15   Median :4.00  
##  Mean   :13.52   Mean   : 6.92                      Mean   :15   Mean   :3.52  
##  3rd Qu.:15.00   3rd Qu.:10.00                      3rd Qu.:15   3rd Qu.:5.00  
##  Max.   :15.00   Max.   :10.00                      Max.   :15   Max.   :5.00  
##    project_3      homework_6    classwork_9      homework_7     homework_8   
##  Min.   : 7.0   Min.   :0.00   Min.   : 2.00   Min.   : 0.0   Min.   : 4.00  
##  1st Qu.: 9.0   1st Qu.:3.00   1st Qu.: 8.00   1st Qu.: 3.0   1st Qu.: 6.00  
##  Median :10.0   Median :4.00   Median :11.00   Median : 8.0   Median : 9.00  
##  Mean   : 9.6   Mean   :3.76   Mean   :10.88   Mean   : 6.4   Mean   : 7.88  
##  3rd Qu.:10.0   3rd Qu.:5.00   3rd Qu.:15.00   3rd Qu.: 9.0   3rd Qu.:10.00  
##  Max.   :10.0   Max.   :5.00   Max.   :15.00   Max.   :10.0   Max.   :10.00  
##    project_4      project_5     formative_assessment_2   project_6    
##  Min.   : 8.0   Min.   : 8.00   Min.   :28.00          Min.   : 8.00  
##  1st Qu.: 9.0   1st Qu.: 8.00   1st Qu.:37.00          1st Qu.: 9.00  
##  Median : 9.0   Median : 9.00   Median :44.00          Median : 9.00  
##  Mean   : 9.4   Mean   : 9.04   Mean   :42.52          Mean   : 9.24  
##  3rd Qu.:10.0   3rd Qu.:10.00   3rd Qu.:48.00          3rd Qu.:10.00  
##  Max.   :10.0   Max.   :10.00   Max.   :50.00          Max.   :10.00  
##   classwork_10     homework_9    classwork_11    homework_10    classwork_12  
##  Min.   : 8.00   Min.   : 0.0   Min.   :12.00   Min.   :0.00   Min.   : 4.00  
##  1st Qu.:13.00   1st Qu.: 2.0   1st Qu.:14.00   1st Qu.:1.00   1st Qu.: 6.00  
##  Median :15.00   Median : 3.0   Median :15.00   Median :2.00   Median : 9.00  
##  Mean   :13.28   Mean   : 5.6   Mean   :14.36   Mean   :2.56   Mean   :10.36  
##  3rd Qu.:15.00   3rd Qu.:10.0   3rd Qu.:15.00   3rd Qu.:5.00   3rd Qu.:15.00  
##  Max.   :15.00   Max.   :10.0   Max.   :15.00   Max.   :5.00   Max.   :15.00  
##   classwork_13     project_7      classwork_14    classwork_15    homework_11  
##  Min.   : 9.00   Min.   : 5.00   Min.   :11.00   Min.   :10.00   Min.   : 9.0  
##  1st Qu.:12.00   1st Qu.: 7.00   1st Qu.:13.00   1st Qu.:13.00   1st Qu.: 9.0  
##  Median :14.00   Median : 9.00   Median :15.00   Median :15.00   Median :10.0  
##  Mean   :13.12   Mean   : 8.24   Mean   :13.84   Mean   :14.04   Mean   : 9.6  
##  3rd Qu.:15.00   3rd Qu.:10.00   3rd Qu.:15.00   3rd Qu.:15.00   3rd Qu.:10.0  
##  Max.   :15.00   Max.   :10.00   Max.   :15.00   Max.   :15.00   Max.   :10.0  
##  summative_assessment_1  classwork_16    homework_12     classwork_17  
##  Min.   :36.00          Min.   :10.00   Min.   : 4.00   Min.   : 1.00  
##  1st Qu.:40.00          1st Qu.:13.00   1st Qu.: 7.00   1st Qu.: 7.00  
##  Median :45.00          Median :15.00   Median : 9.00   Median :13.00  
##  Mean   :44.96          Mean   :13.92   Mean   : 8.44   Mean   :10.32  
##  3rd Qu.:50.00          3rd Qu.:15.00   3rd Qu.:10.00   3rd Qu.:15.00  
##  Max.   :55.00          Max.   :15.00   Max.   :10.00   Max.   :15.00  
##   homework_13     project_8       project_9       project_10   
##  Min.   :0.00   Min.   : 8.00   Min.   : 7.00   Min.   : 8.00  
##  1st Qu.:2.00   1st Qu.: 9.00   1st Qu.: 8.00   1st Qu.: 9.00  
##  Median :3.00   Median : 9.00   Median : 9.00   Median :10.00  
##  Mean   :3.24   Mean   : 9.08   Mean   : 8.92   Mean   : 9.28  
##  3rd Qu.:5.00   3rd Qu.:10.00   3rd Qu.:10.00   3rd Qu.:10.00  
##  Max.   :6.00   Max.   :10.00   Max.   :10.00   Max.   :10.00  
##  summative_assessment_2
##  Min.   :15.00         
##  1st Qu.:24.00         
##  Median :25.00         
##  Mean   :25.96         
##  3rd Qu.:29.00         
##  Max.   :34.00
```

But let's do more than just print numbers to a screen. We'll use the {ggplot2} package from within {tidyverse} to graph some of the data to help get a better grasp of what the data looks like. This code uses {ggplot2} to graph categorical variables into a bar graph. Here we can see the variable `letter_grade` is plotted on the x-axis showing the counts of each letter grade on the y-axis:


```r
# Bar graph for categorical variable
gradebook %>%
  ggplot(aes(x = letter_grade,
             fill = running_average > 90)) +
  geom_bar() +
  labs(title = "Bar Graph of Student Grades",
       x = "Letter Grades",
       y = "Count",
       fill = "A or Better") +
  scale_fill_dataedu() +
  theme_dataedu()
```

![](chapter_8_notes_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

Using {ggplot2}, we can create many types of graphs. Using our `classwork_df` from earlier, we can see the distribution of scores and how they differ from classwork to classwork using boxplots. We are able to do this because we have made the `classworks` and `scores` columns into tidy formats:


```r
# Boxplot of scores per classwork
classwork_df %>%
  ggplot(aes(x = classwork_number,
             y = score,
             fill = classwork_number)) +
  geom_boxplot() +
  labs(title = "Distribution of Classwork Scores",
       x = "Classwork",
       y = "Scores") +
  scale_fill_dataedu() +
  theme_dataedu() +
  theme(
    # removes legend
    legend.position = "none",
    # angles the x axis labels
    axis.text.x = element_text(angle = 45, hjust = 1)
    )
```

```
## Warning: Removed 1 rows containing non-finite values (stat_boxplot).
```

![](chapter_8_notes_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

### 8.8.2 Model Data

**Deciding on an Analysis**

Using this spreadsheet, we can start to form hypotheses about the data. For example, we can ask ourselves, "Can we predict overall grade using formative assessment scores?" For this, we will try to predict a response variable Y (overall grade) as a function of a predictor variable X (formative assessment scores). The goal is to create a mathematical equation for overall grade as a function of formative assessment scores when only formative assessment scores are known.

**Visualize Data to Check Assumptions**

It's important to visualize data to see any distributions, trends, or patterns before building a model. We use {ggplot2} to understand these variables graphically.

**Linearity**

First, we plot X and Y to determine if we can see a linear relationship between the predictor and response. The x-axis shows the formative assessment scores while the y-axis shows the overall grades. The graph suggests a correlation between overall class grade and formative assessment scores. As the formative scores goes up, the overall grade goes up too.


```r
# Scatterplot between formative assessment and grades by percent
# To determine linear relationship
gradebook %>%
  ggplot(aes(x = formative_assessments,
             y = running_average)) +
  geom_point(color = dataedu_colors("green")) +
  labs(title = "Relationship Between Overall Grade and Formative Assessments",
       x = "Formative Assessment Score",
       y = "Overall Grade in Percentage") +
  theme_dataedu()
```

![](chapter_8_notes_files/figure-html/unnamed-chunk-16-1.png)<!-- -->

We can layer different types of plots on top of each other in {ggplot2}. Here the scatterplot is layered with a line of best fit, suggesting a positive linear relationship:


```r
# Scatterplot between formative assessment and grades by percent
# To determine linear relationship
# With line of best fit
gradebook %>%
  ggplot(aes(x = formative_assessments,
             y = running_average)) +
  geom_point(color = dataedu_colors("green")) +
  geom_smooth(method = "lm",
              se = TRUE) +
  labs(title = "Relationship Between Overall Grade and Formative Assessments",
       x = "Formative Assessment Score",
       y = "Overall Grade in Percentage") +
  theme_dataedu()
```

```
## `geom_smooth()` using formula 'y ~ x'
```

![](chapter_8_notes_files/figure-html/unnamed-chunk-17-1.png)<!-- -->

**Outliers**

Now we use boxplots to determine if there are any outliers in formative assessment scores or overall grades. As we would like to conduct a linear regression, we're hoping to see no outliers in the data:


```r
# Boxplot of formative assessment scores
# To determine if there are any outliers
gradebook %>%
  ggplot(aes(x = "",
             y = formative_assessments)) +
  geom_boxplot(fill = dataedu_colors("yellow")) +
  labs(title = "Distribution of Formative Assessment Scores",
       x = "Formative Assessment",
       y = "Score") +
  theme_dataedu()
```

![](chapter_8_notes_files/figure-html/unnamed-chunk-18-1.png)<!-- -->


```r
# Boxplot of overall grade scores in percentage
# To determine if there are any outliers
gradebook %>%
  ggplot(aes(x = "",
             y = running_average)) +
  geom_boxplot(fill = dataedu_colors("yellow")) +
  labs(title = "Distribution of Overall Grade Scores",
       x = "Overall Grade",
       y = "Score in Percentage") +
  theme_dataedu()
```

![](chapter_8_notes_files/figure-html/unnamed-chunk-19-1.png)<!-- -->

We don't see any for these two variables, so we can proceed with the model.

### 8.8.3 Correlation Analysis

We want to know the strength of the relationship between the two variables, formative assessment scores and overall grade percentage. The strength is denoted by the "correlation coefficient." The correlation coefficient goes from -1 to 1. If one variable consistently increases with the increasing value of the other, then they have a positive correlation (towards 1). If one variable consistently decreases with the increasing value of the other, then they have a negative correlation (towards -1). If the correlation coefficient is 0, then there is no relationship between the two variables:


```r
cor(gradebook$formative_assessments, gradebook$running_average)
```

```
## [1] 0.6632553
```

Correlation is good for finding relationships but it does *not* imply that one variable causes the other (correlation does not mean causation).

## 8.9 Results

Now that we've checked our assumptions and seen a linear relationship, we can build a linear model - a mathematical formula that calculates your running average as a function of our formative assessment score. This is done using the `lm()` function, where the arguments are:

-   Our predictor (`formative_assessments`)

-   Our response (`running_average`)

-   The data (`gradebook`)

`lm()` is available in "base R" - that is, no additional packages beyond what is loaded with R automatically are necessary.


```r
linear_mod <- 
  lm(running_average ~ formative_assessments, data = gradebook)

summary(linear_mod)
```

```
## 
## Call:
## lm(formula = running_average ~ formative_assessments, data = gradebook)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -7.2814 -2.7925 -0.0129  3.3179  8.5353 
## 
## Coefficients:
##                       Estimate Std. Error t value Pr(>|t|)    
## (Intercept)           50.11511    8.54774   5.863 5.64e-06 ***
## formative_assessments  0.42136    0.09914   4.250 0.000302 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 4.657 on 23 degrees of freedom
## Multiple R-squared:  0.4399,	Adjusted R-squared:  0.4156 
## F-statistic: 18.06 on 1 and 23 DF,  p-value: 0.0003018
```

When we fit a model to two variables, we create an equation that describes the relationship between those two variables based on their averages. This equation uses the `(Intercept)`, which is 50.11511, and the coefficient for `formative_assessments`, which is .42136. The equation reads like this:

```{}
running_average = 50.11511 + 0.42136*formative_assessments
```

We interpret these results by saying "For every one unit increase in formative assessment scores, we can expect a .421 unit increase in running average scores." This equation estimates the relationship between formative assessment scores and running average scores in the student population.

**More on Interpreting Models**

If you were describing the formative assessment system to stakeholders, you might say something like, "We can generally expect our students to show a .421 increase in their running average score for every one point increase in their formative assessment scores." That makes sense, because your goal is to explain what happens **in general**.

But we can rarely expect every prediction about individual students to be correct, even with a reliable model. So when using this equation to inform how you support an individual student, it's important to consider all the real-life factors, visible and invisible, that influence an individual student outcome creating residuals. Residuals are the differences between predicted values and actual values that aren't explained by your linear model equation.

## 8.10 Conclusion

We first *imported* our data, then *cleaned and transformed* it. Once we had the data in a tidy format, we were able to *explore* the data using data visualization before *modeling* the data using linear regression.

If we ran this analysis for someone else: a teacher or an administrator in a school, we might be interested in sharing the results in the form of a report or document. Thus, the only remaining step in this analysis would be to communicate our findings.

I recommend using a tool such as [RMarkdown](https://rmarkdown.rstudio.com/). It provides the functionality to easily generate reports that include both text (like the words you just read) as well as code and the output from code that are displayed together in a single document (PDF, Word, HTML, and other formats).
