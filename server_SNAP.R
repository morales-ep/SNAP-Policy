# *******************************************************
# ==== SERVER Script for SNAP Policy Shiny Dashboard ====
# *******************************************************
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(plotly) # For interactive graphs; maybe use for mapping
#library(leaflet) # use for mapping?
library(lubridate)
#library(tigris) # Allows us to download US Census data; used to create state borders in the next code block
#################################

## Experiment w/ visualizing outreach data after 2007 ##
# Use for KFF Research Assistant job application

# From STS-115 shiny dashboard
snap %>%
  filter(month(yearmonth) == 10 & year(yearmonth) > "2007") %>% # Oct 2008 = 2009 fiscal year
  ggplot(aes(x = round(outreach, 1))) + 
  geom_freqpoly(binwidth = 20) +
  theme_bw() +
  labs(title = "Frequency of SNAP outreach spending after 2008", # Data starts w/ 2009 fiscal year
       subtitle = "Data comprises fiscal year policies",
       x = "Outreach ($ in thousands)", y = "Count")
# Uses data from fiscal years 2009 - 2016


# Oct 2007 outreach = 2008 fiscal year outreach spending
 snap %>%
   filter(month(yearmonth) == 10 & year(yearmonth) > "2006") %>%
   #ggplot(mapping = aes(y = round(outreach, digits = 1), x = year(yearmonth))) +
   ggplot(mapping = aes(x = round(outreach, digits = 1))) +
   geom_freqpoly(binwidth = 20) +
   #geom_line() +
   #scale_x_date(date_labels = "%Y") +
   theme_bw() +
   labs(title = "Frequency of SNAP outreach spending after 2007",
        subtitle = "Data comprises fiscal year policies", x = "Outreach ($ in thousands)")


# Try creating a jitter plot (relationship between categorical and quantiative data)
# Make sure to recap outreach data fiscal year info -> Do we actually have 2016 fiscal year data?
# ^ We have 2016 fiscal year data bc OCT 2015 is start of 2016 fiscal year
snap %>%
  filter(month(yearmonth) == 10 & year(yearmonth) > "2007" & year(yearmonth) < "2016") %>%
  ggplot(aes(x = factor(year(yearmonth)), y = round(outreach, 1))) + 
  geom_jitter() +
  theme_bw() +
  labs(title = "Frequency of SNAP outreach spending after 2007",
       subtitle = "Data comprises fiscal year policies",
       y = "Outreach ($ in thousands)", x = "Year")


##########################
# ==== CHOROPLETH MAP ====
##########################

# GOALS:
# - Create an interactive choropleth map containing data from SNAP Policy database
#   - Plotly choropleth map help: https://plotly.com/r/choropleth-maps/

# FIND OUT HOW TO DOWNLOAD DATA FILE DIRECTLY FROM GitHub
# ^ ---- CONTINUE HERE ----