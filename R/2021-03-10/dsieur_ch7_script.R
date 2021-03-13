# useful shortcut#
  # Run current line/selection: cmd + return (MAC), ctrl + Enter (Windows)
  # Assignment sign (<-) : Option + - (M), Alt + - (W)
  # Pipe sign (%) : cmd + shift + M (M), ctrl + shift + M (W)

# install.packages(c("tidyverse", "apaTables", "sjPlot", "dataedu", "summarytools", "ggpubr"))

# dataedu wasn't available for R ver 3.6.3 so I installed dev version of dataedu
remotes::install_github("data-edu/dataedu")

# this was not in the book but useful to get descriptives
install.packages("summarytools")

# Load packages
library(tidyverse)
library(apaTables)
library(sjPlot)
library(readxl)
library(dataedu)
library(summarytools)
library(ggpubr)

############################
# import data from dataedu #
############################

# Pre-survey for the F15 and S16 semesters
pre_survey <- dataedu::pre_survey

# Gradebook and log-trace data for F15 and S16 semesters
course_data <- dataedu::course_data

# Log-trace data for F15 and S16 semesters - this is for time spent
course_minutes <- dataedu::course_minutes

#############
# view data #
#############
head(pre_survey) # first six rows
View(pre_survey) # a full view in a separate tab
glimpse(pre_survey) # list of variables, values for the first couple of cases

# get a quick look at each variable in df
view(dfSummary(pre_survey)) 

## take a look at course_data, course_minutes; what do you notice?

########################
# 1.process pre_survey #
########################
pre_survey  <-
  pre_survey  %>%
  # Rename the qustions something easier to work with because R is case sensitive
  # and working with variable names in mix case is prone to error
  rename(
    q1 = Q1MaincellgroupRow1,
    q2 = Q1MaincellgroupRow2,
    q3 = Q1MaincellgroupRow3,
    q4 = Q1MaincellgroupRow4,
    q5 = Q1MaincellgroupRow5,
    q6 = Q1MaincellgroupRow6,
    q7 = Q1MaincellgroupRow7,
    q8 = Q1MaincellgroupRow8,
    q9 = Q1MaincellgroupRow9,
    q10 = Q1MaincellgroupRow10
  ) %>%
  # Convert all question responses to numeric
  mutate_at(vars(q1:q10), list( ~ as.numeric(.))) # q1-10 are already numeric, so this doesn't seem necessary

# you could insert suffix to the var names indicate the three dimensions
# e.g. q1.i, q2.u, 3.p where i = interest, u = utility, p = perceived competence

###########################################
#1a.practice mutate = making a new variable #
###########################################
# create a df (dataframe) with two columns/vars, male & females
df <- tibble(
  male = 5, 
  female = 5
)

# Use mutate to create a new column called "total_students" 
# populate that column with the sum of the "male" and "female" variables
df %>% mutate(total_students = male + female)

# let's keep this new column in df
df <- df %>%  mutate(total_students = male + female)

######################################################
# 1b. reverse_score function with mutate & case_when #
######################################################
# This part of the code is where we write the function:
# Function for reversing scales 
reverse_scale <- function(question) {
  # Reverses the response scales for consistency
  #   Arguments:
  #     question - survey question
  #   Returns: 
  #    a numeric converted response
  # Note: even though 3 is not transformed, case_when expects a match for all
  # possible conditions, so it's best practice to label each possible input
  # and use TRUE ~ as the final statement returning NA for unexpected inputs
  x <- case_when(
    question == 1 ~ 5,
    question == 2 ~ 4,
    question == 3 ~ 3, 
    question == 4 ~ 2,
    question == 5 ~ 1,
    TRUE ~ NA_real_
  )
  x
}

# let's see how it works
reverse_scale(pre_survey$q4)
pre_survey$q4

# And here's where we use that function to reverse the scales
# We use the pipe operator %>% here
# Reverse scale for questions 4 and 7
pre_survey <-
  pre_survey %>%
  mutate(q4 = reverse_scale(q4), # mutate with the original var name to overwrite
         q7 = reverse_scale(q7))

# Note: psych package has reverse.code() function so you don't have to write your own function

#####################################################
#1c. pivot_longer to make pre_survey into long form #
#####################################################

# Pivot the dataset from wide to long format
# And name the long format df as measure_mean
measure_mean <-
  pre_survey %>%
  # Gather questions and responses
  pivot_longer(cols = q1:q10,
               names_to = "question", # give a new var/col name "question" where question # will go
               values_to = "response") # give a new var/col name "response" where response values will go

# create a new var called measure to denote 3 dimensions of motivation 
measure_mean <- measure_mean %>% 
  # Here's where we make the column of question categories called "measure"
  mutate(
    measure = case_when(
      question %in% c("q1", "q4", "q5", "q8", "q10") ~ "int",
      question %in% c("q2", "q6", "q9") ~ "uv",
      question %in% c("q3", "q7") ~ "pc",
      TRUE ~ NA_character_)
  )

###################################################
# 1d. Get mean scores for each motivation measure #
# Across ~912 students who responded the pre-survey
# using group_by() and summarize()
###################################################

measure_mean <- measure_mean %>%
  # First, we group by the new variable "measure"
  group_by(measure) %>%
  # Here's where we compute the mean of the responses
  summarize(
    # Creating a new variable to indicate the mean response for each measure
    mean_response = mean(response, na.rm = TRUE),
    # Creating a new variable to indicate the percent of each measure that 
    # had NAs in the response field
    percent_NA = mean(is.na(response))
  )

measure_mean

##############################
# 2. Process the course data #
##############################

View(course_data)

# split course section into components
course_data <- 
  course_data %>%
  # Give course subject, semester, and section their own columns
  separate(
    col = CourseSectionOrigID,
    into = c("subject", "semester", "section"),
    sep = "-",
    remove = FALSE # this is to keep the original var
  )

#############################################
# 3. Join/merge course_data with pre_survey #
#############################################

#rename pre_survey id vars
pre_survey <-
  pre_survey %>%
  rename(student_id = opdata_username, #new_var_name = old_var_name
         course_id = opdata_CourseID)

pre_survey

################################################
#3a.  extract 5 digits inbetween _ _ in student_id #
################################################

#trying str_sub just with one string value
str_sub("_99888_1", start = 2)
str_sub("_99888_1", start = -3)
str_sub("_99888_1", start = 2, end = -3)

# Re-create the variable "student_id" so that it excludes the extraneous characters
pre_survey <- pre_survey %>% 
  mutate(student_id = str_sub(student_id, start = 2, end = -3))

# Save the new variable as numeric so that R no longer thinks it is text 
pre_survey <- pre_survey %>% 
  mutate(student_id = as.numeric(student_id))

###########################################################
#3b rename id vars in course_data and join with pre_survey
##########################################################
course_data <-
  course_data %>%
  rename(student_id = Bb_UserPK,
         course_id = CourseSectionOrigID)

# new df merges course_data with pre_survey
dat <-
  left_join(course_data, pre_survey,
            by = c("student_id", "course_id"))
dat

############################################
#4. Process course_minutes & join with dat
############################################
course_minutes <-
  course_minutes %>%
  rename(student_id = Bb_UserPK,
         course_id = CourseSectionOrigID)

course_minutes <-
  course_minutes %>%
  # Change the data type for student_id in course_minutes so we can match to 
  # student_id in dat
  mutate(student_id = as.integer(student_id))

dat <- 
  dat %>% 
  left_join(course_minutes, 
            by = c("student_id", "course_id"))

# dat has many gradebook_items per student per course
# we want just one row per student & course combo
# using distinct()
dat <-
  distinct(dat, course_id, student_id, .keep_all = TRUE)

# rename final grade var
dat <- rename(dat, final_grade = FinalGradeCEMS)

###########################################
# 5. Analysis
###########################################

#######################################################################
# 5a.Scatter plot to examine relationship between final grade & time spent
#######################################################################
view(dfSummary(dat)) 

#scatter plot to see relationship between timespent & final grade
p1 <- dat %>%
  # aes() tells ggplot2 what variables to map to what feature of a plot
  # Here we map variables to the x- and y-axis
  ggplot(aes(x = TimeSpent, y = final_grade)) + 
  # Creates a point with x- and y-axis coordinates specified above
  geom_point(color = dataedu_colors("green")) + 
  theme_dataedu() +
  labs(x = "Time Spent",
       y = "Final Grade")

# add a line of best fit
p1 +  geom_smooth(method = "lm")

# with ggpubr, you can add correlation to the graph
require(ggpubr)
p2 <- ggscatter(dat, x = "TimeSpent", y = "final_grade",
                color = "springgreen4",
                add = "reg.line",  # Add regressin line
                add.params = list(color = "blue", fill = "lightgray"), # Customize reg. line
                conf.int = TRUE # Add confidence interval
                )
# Add correlation coefficient
p2 + 
  stat_cor(method = "pearson", label.x = 3900, label.y = 130,
           p.accuracy = 0.001, r.accuracy = 0.01)

###################################################
# 5b.Linear regression with time spent as predictor
###################################################
m_linear <-
  lm(final_grade ~ TimeSpent, data = dat)

summary(m_linear)

# get publication ready table with tab_model function
require(sjPlot)
tab_model(m_linear,
          title = "Table 7.1")
# you can copy and paste it into Word!

# or save it with apa.re.table function
apa.reg.table(m_linear, filename = "regression-table-output.doc")

###################################################
# 5c.Correlations among the 3 motivation variables
###################################################

# pivot survey_responses to long form
survey_responses <-
  pre_survey %>%
  # Gather questions and responses
  pivot_longer(cols = q1:q10,
               names_to = "question",
               values_to = "response") %>%
  mutate(
    # Here's where we make the column of question categories
    measure = case_when(
      question %in% c("q1", "q4", "q5", "q8", "q10") ~ "int",
      question %in% c("q2", "q6", "q9") ~ "uv",
      question %in% c("q3", "q7") ~ "pc",
      TRUE ~ NA_character_
    )) 

# create mean_response for each student for each measure
survey_responses <-
  survey_responses %>%
  group_by(student_id, measure) %>%
  # Here's where we compute the mean of the responses for each stdt & measure combo
  summarize(
    # Mean response for each measure
    mean_response = mean(response, na.rm = TRUE)
  ) 

# Filter NA (missing) responses and pivot to wide form
survey_responses <-
  survey_responses %>%
  filter(!is.na(mean_response)) %>%
  pivot_wider(names_from = measure, 
              values_from = mean_response)
survey_responses

# get correlation table
survey_responses %>%
  apa.cor.table(filename = "corr-table-output.doc")
# note the correlation table includes student_id. 
# probably want to delete it in Word

#############################################################################
# 5d. Linear regression with hours sptent (rather than minutes) as predictor
############################################################################

# creating a new variable for the amount of time spent in hours
dat <- 
  dat %>% 
  mutate(TimeSpent_hours = TimeSpent / 60)

# the same linear model as above, but with the TimeSpent variable in hours
m_linear_1 <- 
  lm(final_grade ~ TimeSpent_hours, data = dat)

# viewing the output of the linear model
tab_model(m_linear_1,
          title = "Table 7.2")

##################################################################
# 5e. Linear regression with standardized time spent as predictor
##################################################################
# this is to standardize the TimeSpent variable to have a mean of 0 and a standard deviation of 1
# this makes intercept more interpretable
dat <- 
  dat %>% 
  mutate(TimeSpent_std = scale(TimeSpent))

# the same linear model as above, but with the TimeSpent variable standardized
m_linear_2 <- 
  lm(final_grade ~ TimeSpent_std, data = dat)

# viewing the output of the linear model
tab_model(m_linear_2,
          title = "Table 7.3")

#####################################################################
#6. Multiple regression model with time spent & subject as predictors
#####################################################################
# a linear model with the subject added 
# independent variables, such as TimeSpent_std and subject, can simply be separated with a plus symbol:
m_linear_3 <- 
  lm(final_grade ~ TimeSpent_std + subject, data = dat)
# note: subject is a categorical variable and it seems AnPhA (animal physiology)
# is set as the reference category (numbers assinged by alphabetical order)

tab_model(m_linear_3,
          title = "Table 7.4")

# Combine all four models in one table & show standard errors rather than CIs
tab_model(m_linear, m_linear_1, m_linear_2, m_linear_3,
          show.ci = FALSE, show.se = TRUE)

#####################################################################
#7. What other analyses can you think of?
#####################################################################

# Add total scores of pre-course motivation as a predictor?
# --> use mutate to create sum_motiv variable

# Does the effect of time spent vary by subjects/courses?
# --? add time x subject interaction term 

