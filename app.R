########################################
# #### R Script for Shiny Dashboard #### 
# #### SNAP Policy Data 1996-2016 ######
########################################

library(tidyverse) # ggplot2, dplyr, forcats
library(lubridate) # Date-time handling
library(plotly) # For interactive choropleth matp
library(shiny)
library(shinydashboard)


# ==== Data Wrangling ====
# Import SNAP dataset directly from Github Repo
# snap <- read.csv(file = "https://github.com/morales-ep/SNAP-Policy/blob/master/SNAP_Policy_Database.csv?raw=true", stringsAsFactors = FALSE)

# Import SNAP dataset from your "Datasets" Github repo
snap <- read.csv(file = "https://github.com/morales-ep/Datasets/blob/master/SNAP_Policy_Database.csv?raw=true", 
                 stringsAsFactors = FALSE)


# Brief assessment of dataset
glimpse(snap)
sum(is.na(snap)) # Check total number of missing values

# View dataset in spreadsheet format
# View(snap)

# Check which States & Territories are in the dataset
levels(factor(snap$statename))
# All states + DC are in dataset
# Territories (e.g. Puerto Rico) are not included; What does this say about SNAP implementation?

# ---- Data Cleaning ----

# Replace all missing values in data w/ NAs
# NAs are represented by blank cells *SEE DATA DICTIONARY*
is.na(snap) <- snap == ""

# Check which variables have NAs and the amount in the ENTIRE dataset
data.frame(missing_values = colSums(sapply(snap, FUN = is.na)),
           percent_missing = round((colSums(sapply(snap, FUN = is.na))) / nrow(snap) * 100, 2))


# Convert yearmonth variable to appropriate data type; truncate date to 1st of each month
snap$yearmonth <- ymd(snap$yearmonth, truncated = 1)

str(snap)
glimpse(snap)
# IMPORTANT NOTE: Categorical variables (i.e. observations using 0,1 scheme) are saved as INTERGER data types

# Convert Categorical variables to Factor data type; Refer to data dictionary for help
snap[, c("bbce", "bbce_asset", "bbce_a_veh", "bbce_hh", "bbce_sen",
         "call", "cap")] <- lapply(snap[,c("bbce", "bbce_asset", "bbce_a_veh", "bbce_hh", "bbce_sen", "call", "cap")], FUN = factor)

snap[,c(33:42, 44:48)] <- lapply(snap[,c(33:42, 44:48)], FUN = factor)

str(snap) # Check results



# ==== Global Variables ====
# Get the outreach data for each State in each fiscal year and remove 2016 rows
state.ym.out <- snap %>%
  filter((month(yearmonth) == 10 | (month(yearmonth) == 9 & year(yearmonth) == 1996))) %>%
  select(state_pc, yearmonth, outreach) %>%
  arrange(yearmonth) %>%
  filter(year(yearmonth) != 2016)
 
# Add an extra year to dates after 1996-09-01 to format data for appropriate fiscal year
state.ym.out$yearmonth <- if_else(condition = month(state.ym.out$yearmonth) != 9,
                                  true = years(1) + state.ym.out$yearmonth,
                                  false = state.ym.out$yearmonth)


# Create a line graph for TOTAL (National) SNAP outreach spending 1996-2016 fiscal years
# Remove NAs in outreach (Oct-Dec 2016)
outreach.total <- snap %>%
  filter((month(yearmonth) == 10 | (month(yearmonth) == 9 & year(yearmonth) == 1996))) %>%
  group_by(yearmonth) %>%
  summarize(total.outreach = sum(outreach, na.rm = TRUE)) %>%
  filter(year(yearmonth) != 2016) %>% # Remove 2016 observation
  ungroup()

# Add 1 year to all observations, excluding first row
outreach.total$yearmonth[2:length(outreach.total$yearmonth)] <- years(1) + outreach.total$yearmonth[2:length(outreach.total$yearmonth)]


# Calculate TOTAL outreach in each State FY 1996-2016
tot.outreach.state <- snap %>%
  filter((month(yearmonth) == 10 | (month(yearmonth) == 9 & year(yearmonth) == 1996))) %>%
  group_by(state_pc) %>%
  summarise(total.outreach = round(sum(outreach, na.rm = TRUE), 3)) %>%
  arrange(desc(total.outreach)) %>%
  ungroup()




# ==== Dashboard Sidebar Code ====
sidebar <- dashboardSidebar(
    
    # sidebarMenu for menuItems
    sidebarMenu(
        
        # menuItem for Dashboard
        menuItem(text = "Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        
        # menuItem for background info & metadata about the dataset
        menuItem(text = "About the Data", tabName = "about", icon = icon("info-circle")),
        
        # menuItem for interactive table
        menuItem(text = "Interactive Table", tabName = "table", icon = icon("table"))
        
        # Include option to download data file at the bottom of the sidebar?
        
    ) # sidebarMenu end
) # sidebar end


# ==== Dashboard Body Code ====
body <- dashboardBody(
    
    # tabItems to match w/ sidebarMenu items
    tabItems(
        
        # ---- Dashboard UI ----
        # Dashboard should contain at least 4-6 info boxes and a 2-3 plots
        tabItem(tabName = "dashboard",
                
                # First row of 1-2 info boxes
                fluidRow(
                    
                    # Info box for number of Policies w/ BBCE end of FY 2016
                    infoBoxOutput(outputId = "bbce_Yes", width = 6),
                    
                    # Info box of States operating Combined Application Project (CAP)
                    infoBoxOutput(outputId = "cap", width = 6)
                    
                ), # End of 1st row
                
                # 2nd row of info boxes 3 & 4
                fluidRow(
                    
                    # Info box of policies operating call centers Statewide
                    infoBoxOutput(outputId = "cc", width = 6),
                    
                    # Info box of policies allowing online SNAP application submission
                    infoBoxOutput(outputId = "o_app", width = 6)
                    
                ), # 2nd row end
                
                
                # 3nd row containing Outreach tab box and Column Charts
                fluidRow(
                    
                    # Tab box 
                    tabBox(title = "Outreach Data",
                           
                           # Plotly line graph, checkbox input, and selection input box
                           tabPanel(title = "Over Time", #status =  "primary", 
                                    #collapsible = TRUE, solidHeader = TRUE,
                                    plotlyOutput(outputId = "Outreach"),
                                    checkboxInput(inputId = "ntl", 
                                                  label = "View total outreach", 
                                                  value = FALSE),
                                    selectInput(inputId = "location",
                                                label = "Select a State/Location",
                                                choices = state.ym.out$state_pc)),
                           
                           # boxplot-jitter plot and fiscal year input
                           tabPanel(title = "Distribution",
                                    #collapsible = TRUE, solidHeader = TRUE,
                                    plotOutput(outputId = "distOutreach"),
                                    selectInput(inputId = "fiscalYear",
                                                label = "Select Fiscal Year",
                                                choices = year(state.ym.out$yearmonth),
                                                selected = (year(state.ym.out$yearmonth) == 1996))),
                           # Default choice is FY 1996 -> Try to change this to 2016 FY
                           
                           # Plotly horizontal bar chart of TOTAL outreach by State 1996-2016
                           tabPanel(title = "Total Spending",
                                    #collapsible = TRUE, solidHeader = TRUE,
                                    plotlyOutput(outputId = "totOutreach")),
                           
                           # Outreach data FY 2016 by transitional SNAP benefits (transben)
                           tabPanel(title = "Transitional Benefits",
                                    plotlyOutput(outputId = "ben.out"))
                           
                    ), # tab box end
                    
                    # Column chart tab box
                    tabBox(title = "BBCE Column Charts",
                           tabPanel(title = "Chart 1", plotOutput(outputId = "col1")),
                           tabPanel(title = "Chart 2", plotOutput(outputId = "col2")),
                           tabPanel(title = "Chart 3", plotOutput(outputId = "col3")))
                    
                ), # 3rd row end
                
                
                # 4th row for freqpoly plots and count plots
                fluidRow(
                    
                    tabBox(title = "Frequency Polygons",
                           
                           # box for median certification period for SNAP units w/ earnings by "oapp"
                           tabPanel(title = "Plot 1", plotOutput(outputId = "freqpoly1")),
                           
                           # box for median cert period for elderly SNAP units by cap
                           tabPanel(title = "Plot 2", plotOutput(outputId = "freqpoly2")),
                           
                           # box for median cert period for nonearning, nonelderly SNAP households
                           tabPanel(title = "Plot 3", plotOutput(outputId = "freqpoly3"))
                           
                    ),
                    
                    tabBox(title = "Count Plots",
                           tabPanel(title = "Plot 1", plotlyOutput(outputId = "count1")),
                           tabPanel(title = "Plot 2", plotlyOutput(outputId = "count2"))
                    )
                    
                ), # 4th row end
                
                
                # 5th row of 2-4 info, value, or tab boxes
                fluidRow(
                    
                    # tab box for bbce variables of interest
                    tabBox(
                        title = "Broad-based Categorical Eligibility Variables by State, 2016",
                        tabPanel(title = "BBCE", tableOutput(outputId = "bbce1")), # bbce used
                        tabPanel(title = "No BBCE", tableOutput(outputId = "bbce2")),
                        selected = "No BBCE"
                    ),
                    
                    
                    # collapsible box for table of missing data info
                    box(title = "Missing Data",
                        solidHeader = TRUE,
                        plotOutput(outputId = "missing"))
                    
                ), # 5th row end
                
        ), # End of dashboard tab
        
        
        # ---- Additional Charts UI ----
        # Additional charts that examine "robustness" of SNAP policies (at end of 2016 FY?)
        tabItem(tabName = "charts"
                
                
                
        ), # End of Charts tab
        
        
        # ---- Interactive Table ----
        tabItem(tabName = "table",
                
                # Place an interactive data table below choropleth map
                tags$h1("Explore the data!"),
                
                hr(), # Horizontal Line
                
                dataTableOutput("snapData") 
                
        ), # End of Table tab
        
        
        # ---- About the Data ----
        tabItem(tabName = "about", 
                tags$h1("Data Source"),
                tags$p("This dashboard presents an analysis of a dataset shared by the US Department of Agriculture (USDA) and complied by its Economic Research Service (ERS). The dataset comprises Supplemental Nutrition Assistance Program (SNAP) State-level policy information, including Washington D.C., for each month of a given year from January 1996 to December 2016 and reports logistical data like eligibility criteria, recertification and reporting requirements, and coordination with other safety net programs. The SNAP Policy Database is derived from a wide array of sources but the majority of the data was provided by USDA's Food and Nutrition (FNS); the Center on Budget and Policy Priorities (CBPP) and the National Immigration Law Center (NILC) supplied additional data. Prior to the mid-1990s there were uniform SNAP administration federal protocols with little variation across each US state. The Welfare Reform Act of 1996 granted more power and flexibilty to States in how they administer SNAP, hence the SNAP Policy Database's inception."),
                
                # Link to Data Dictionary for help
                tags$strong("Data Dictionary"),
                tags$a("https://www.ers.usda.gov/data-products/snap-policy-data-sets/documentation/"),
                
                br(), # Line breaks
                br(),
                
                # Add a citation
                tags$strong("Citation"),
                tags$p("Economic Research Service (ERS), U.S. Department of Agriculture (USDA). SNAP Policy Database, SNAP Policy Data Sets.", a("https://www.ers.usda.gov/data-products/snap-policy-data-sets/")),
                
                hr(), # Add horizontal line
                
                tags$h1("Questions for Analysis"),
                tags$h4("How many States had robust SNAP policies at the end or in the final year of the data available?"),
                #tags$p("I asked this question because I wanted to know which States had SNAP policies and services that address food insecurity, poverty, and may be useful in the event of a public health or economic crisis."),
                
                tags$h4("How did overall SNAP outreach spending change over time, particularly after 2007?"),
                #tags$p("I asked this because I wanted to see how spending changed from the database's inception to the final year that data was recorded, and how they may relate to other policy variables."),
                
                tags$h4("How did certification period change over time or after a particular year? Does certification period change when including relevant policies?"),
                #tags$p("I asked this because I wanted to see if there were any changes in how responsive and accomodating SNAP policies were in terms of certification."),
                
                tags$h4("What was the frequency of SNAP policies that address food insecurity and social determinants of health?"),
                #tags$p("I asked this because I wanted to see how US states and the federal government responded to disasters, such as the Great Recession of the late 2000s, through social services like SNAP and how spending changed in ensuing years as a way of examining success or failure in responsiveness and efficacy."),
                
                
                hr(), # Horizontal line
                
                tags$h1("Insights"),
                tags$p("The database compiled by the USDA's Economic Research Service contains a grand total of 12,852 SNAP policies for each month of every year from 1996 to 2016 reported by all 50 US states, including the District of Columbia, and a total of 1071 reported fiscal year policies which start October 1st and end September 30th. The dataset was last updated on April 12, 2018 and does not include information about US territories, i.e., Guam, Puerto Rico, American Samoa, the Northern Mariana Islands, and the US Virgin Islands."),
                
                tags$p("By the end of FY 2016, more than half of US States, plus Washington D.C., had flexible and accomodating SNAP policies; less than half of all States did not operate a Combined Application Project (CAP) however. Interestingly at end of FY 2016 the median SNAP certification period for elderly households in States operating a CAP nearly mirrored that of States not operating CAP. This suggests that there may be other factors that influence certification period, particularly for senior SNAP units. Additionally, most States were granted waivers by the end of FY 2016 to conduct telephone interviews for both initial certification and recertification."),
                
                tags$p("According to the data, the total amount of SNAP outreach spent among all 50 States, including Washington D.C., steadily increased from FY 1996 to FY 2014; a sharp decrease in national SNAP outreach occurred in FY 2015 but followed an upward trend afterward. The most amount of outreach spent across the data's 20 year span was roughly $7 million USD which occured in FY 2014. California, New York, Washington, Texas, Conneticut spent the most on SNAP outreach, respectively, from FY 1996 to FY 2016. However, California was an outlier and likely caused the distribution of outreach among all States to skew upward. In FY 2016, most States did not offer transitional SNAP benefits to individuals leaving cash assistance or TANF programs and there did not appear to be a considerable difference in outreach based on this policy, though California was the only exception."),
                
                tags$p("The majority of SNAP policies after 2007 reported outreach spending of approximately less than $250,000 USD. However, the outreach data constitutes the sum of Federal, State, and grant spending so it is unclear exactly which sectors of the economy contributed to spending and how it varied after 2007."),
                
                hr(), # Horizontal line
                
                
                tags$h1("Knowledge Gaps"),
                
                tags$h4("CATEGORIZATION ISSUES"),
                tags$p("According to the data dictionary, oapp is a nominal categorical variable that represents the availability of online SNAP application submission in a US state. 0 denotes a no, 1 denotes yes, and 2 denotes yes, in only select parts of the State. The issue with this categorization, however, is that if we were to zoom in to a State that administered online applications in particular regions, we would be unable to determine at what jurisdiction level does that State's SNAP policy allow households to do so."),
                
                tags$p("In a plot that examined the frequency of SNAP policies for all States in the dataset's latest year-month report that allowed online application submission, it did not focus on a single state but it gave an idea of the obscurity in online SNAP application availability when assessing SNAP policies at a subregional level. Although there were a small count of reports that had online applications administered in select parts of the State, knowing where exactly might better illustrate the frequency distribution."),
                
                br(), # Line break
                
                tags$h4("AGGREGATION ISSUES"),
                tags$p("SNAP outreach data represents the sum of Federal, State, and grant spending which consequently makes it difficult to determine the extent of particular economic sectors' contributions to SNAP outreach spending during specific fiscal years or throughout the database's timeframe. Additionally interpretations made about outreach data requires extra attention in virtue of its reporting of US dollars in units of thousands."),
                
                tags$p("A boxplot was generated to depict the distribution in total SNAP outreach spending, a sum of sums essentially, across all US states. The visual analysis would have been more insightful if the database enabled users to differentiate between the outreach spending sources, especially for evaluating the amount according to grant type, i.e., block grants vs categorical grants."),
                
                tags$p("Another notable finding in the database is that the 1996 fiscal year outreach spending is represented by the September data, which marks the end of the fiscal year reporting, and that October 1996 outreach data constitutes the 1997 fiscal year. Thus, outreach data calculations need to account for this data entry issue."),
                
                br(), # Line Break
                
                tags$h4("PERSONAL KNOWLEDGE GAPS"),
                tags$p("A noteworthy observation about the SNAP Policy Database is that it does not include demographic information such as race/ethnicity, sex, and age. This affects the degree of data analysis because assessments of demographic distributions in SNAP patronization in order to determine which populations may be benefitting most from SNAP or who may be the most need of benefits is not possible; county-level data is also not include which affects my analysis in a similar way."),
                
                tags$p("The", em("transben"), "variable in the dataset is defined as 'the State offers transitional SNAP benefits to families leaving the TANF or State‐funded cash assistance programs.' If the dataset included demographic and subregional data, the figure containing boxplots of outreach distribution grouped by transitional SNAP benefit offering status might have helped with understanding which groups may be most reliant on SNAP, how it affects outreach spending, and how should the spending be conducted.")
                
        ) # End of "About the Data" tab
        
    ) # tabItems end
    
) # dashboardBody end


# ==== UI Page ====
ui <- dashboardPage(
    
    # Set dashboard theme to green
    skin = "green",
    
    dashboardHeader(title = "SNAP Policy Data"),
    sidebar,
    body
    
) # UI end




# ==== Server Code ====
server <- function(input, output) {
    
    # ---- Dashboard ----
    
    # ---- Info Boxes ----
    # info box output of States using BBCE
    output$bbce_Yes <- renderInfoBox({
        
        # Create variable to store data frame
        quant_insight1 <- snap %>%
            filter(year(yearmonth) == 2016 & bbce == 1) %>%
            group_by(state_pc) %>%
            distinct() %>%
            count(bbce) %>%
            nrow()
        # w/o nrow, each n = 12 for each State bc bbce is same throughout the year
        
        infoBox(title = 'States using Broad-Based Categorical Eligibility, 2016', 
                value = quant_insight1, 
                icon = icon("list", lib = 'glyphicon'), 
                color = "light-blue",
                fill = TRUE)
        
    })
    
    
    # info box output for Combined Application Project use in 2016
    output$cap <- renderInfoBox({
        
        # Data is missing final two months of 2016
        # Count number of States operating CAP at most recent date
        quant_insight2 <- snap %>%
            filter(year(yearmonth) == 2016 & month(yearmonth) == 10 & cap == 1) %>%
            distinct() %>%
            nrow()
        
        infoBox(title = "States operating Combined Application Project, 10-2016",
                value = quant_insight2,
                icon = icon("list-alt", lib = "glyphicon"),
                color = "light-blue",
                fill = TRUE)
        
    })
    
    
    # info box output for fingerprint requirement 10/2016
    output$cc <- renderInfoBox({
        
        # Data missing for final two months of 2016
        quant_insight3 <- snap %>%
            filter( (year(yearmonth) == 2016 & month(yearmonth) == 10) & call == 1) %>%
            distinct(state_pc) %>%
            nrow()
        
        infoBox(title = "States operating call centers statewide, 10-2016",
                value = quant_insight3,
                icon = icon("phone", lib = "glyphicon"),
                color = "light-blue",
                fill = TRUE)
        
    })
    
    
    # info box output for online application submission option 12/2016
    output$o_app <- renderInfoBox({
        
        # Data missing for final two months of 2016
        quant_insight4 <- snap %>%
            filter( (year(yearmonth) == 2016 & month(yearmonth) == 12) & oapp == 1) %>%
            distinct(state_pc) %>%
            nrow()
        
        infoBox(title = "States allowing online application submission, 12-2016",
                value = quant_insight4,
                icon = icon("folder-open", lib = "glyphicon"),
                color = "light-blue",
                fill = TRUE)
        
    })
    
    
    # ---- Outreach and Column/Bar Charts ----
    # Reactive expression for selecting Location for line graph
    state <- reactive({ input$location })
    
    # Render plotly line graph of outreach over time by State
    output$Outreach <- renderPlotly({
        
        # if checkbox not marked, display outreach data based on selected location
        if(input$ntl == FALSE) {
            
            plot_ly(data = state.ym.out %>% filter(state_pc == state()),
                    x = ~year(yearmonth), y = ~outreach,
                    type = "scatter",
                    mode = "lines",
                    hoverinfo = "text",
                    text = ~paste("</br> FY", year(yearmonth),
                                  "</br> Outreach: ", round(outreach, 3))) %>%
                layout(title = "SNAP Outreach, Fiscal Year 1996-2016",
                       xaxis = list(title = "Year"),
                       yaxis = list(title = "USD in Thousands"))
            
        } # This works after unchecking box and selecting a State in the list
        
        
        # otherwise display national outreach data over time
        else {
            
            plot_ly(data = outreach.total %>% filter(!is.na(total.outreach)),
                    x = ~year(yearmonth), y = ~total.outreach,
                    type = "scatter",
                    mode = "lines",
                    hoverinfo = "text",
                    text = ~paste("</br> FY:", year(yearmonth),
                                  "</br> Outreach:", round(total.outreach, 3))) %>%
                layout(title = "National SNAP Outreach, FY 1996-2016",
                       xaxis = list(title = "Fiscal Year"),
                       yaxis = list(title = "USD in Thousands"))
            
        }
        
    }) # Outreach line graph end
    
    
    # Reactive expression fiscal year user input
    fy <- reactive({ input$fiscalYear })
    
    # Render ploty boxplot + jitter plot 
    output$distOutreach <- renderPlot({
        
        ggplot(data = state.ym.out %>% filter(year(yearmonth) == fy()), 
               mapping = aes(x = factor(year(yearmonth)), y = outreach)) +
            geom_boxplot() +
            geom_jitter(color = "springgreen4", alpha = 1/2) +
            theme_bw() +
            labs(title = "Distribution of SNAP outreach by Fiscal Year",
                 subtitle = "Green Points represent outreach data in each State",
                 x = "Year", y = "USD in Thousands") +
            theme(axis.title.x = element_text(vjust = -1),
                  axis.title.y = element_text(vjust = 1.5))
        
    })
    
    
    # Render Plotly horizontal bar chart of Total outreach by State
    output$totOutreach <- renderPlotly({
        
        # Horizontal bar chart of TOTAL outreach spending by State 1996-2016 FY using Plotly
        plot_ly(data = tot.outreach.state,
                type = "bar", orientation = 'h',
                y = ~fct_reorder(state_pc, total.outreach),
                x = ~round(total.outreach, 3)) %>%
            layout(title = "Total Outreach by State, FY 1996-2016",
                   xaxis = list(title = "USD in Thousands"),
                   yaxis = list(title = "State"))
        
    }) # Total Outreach bar chart end
    
    
    # Render column of outreach data by transben data at end of 2016 FY (September 2016)
    output$ben.out <- renderPlotly({
        
        # Create local variable
        data.new <- snap %>%
            select(state_pc, yearmonth, outreach, transben) %>%
            filter(yearmonth == "2015-10-01") %>%
            arrange(transben)
        
        # Recode the factor levels of transben using if-else function
        data.new$transben <- if_else(condition = (data.new$transben == 0), 
                                     true = "No", false = "Yes")
        
        plot_ly(data = data.new,
                type = "bar", orientation = "h", color = ~transben,
                x = ~round(outreach, 3),
                y = ~fct_reorder(state_pc, outreach)) %>%
            layout(title = "Outreach by State and Transitional SNAP Benefits, FY 2016",
                   xaxis = list(title = "USD in Thousands"),
                   yaxis = list(title = "State"),
                   legend = list(title = list(text = "Transitional Benefits Offered")))
        
    })
    
    
    
    # Render column charts
    output$col1 <- renderPlot({
        
        # Column charts of bbce_inclmt by bbce_hh
        ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 12),
               mapping = aes(x = factor(bbce_inclmt))) +
            geom_bar(mapping = aes(fill = bbce_hh), color = "black", position = "dodge") +
            scale_fill_brewer(palette = "Oranges") +
            theme_bw() +
            labs(x = "Gross Income Limit as percentage of Federal poverty guidelines",
                 y = "Frequency",
                 title = "Count of Gross Income Limit policies by BBCE limitations for certain households, Dec 2016")
        
    })
    
    
    output$col2 <- renderPlot({
        
        # Column charts of bbce_inclmt by bbce_sen
        ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 12),
               mapping = aes(x = factor(bbce_inclmt))) +
            geom_bar(mapping = aes(fill = bbce_sen), color = "black", position = "dodge") +
            scale_fill_brewer(palette = "Purples") +
            theme_bw() +
            labs(x = "Gross Income Limit as percentage of Federal poverty guidelines",
                 y = "Frequency",
                 title = "Count of Gross Income Limit policies by special household restrictions under BBCE, Dec 2016",
                 subtitle = "Households with senior or disabled members with incomes above State-specified cut-off do not qualify for BBCE and would face the federal asset limit")
        
    })
    
    
    output$col3 <- renderPlot({
        
        # Column chart of polices by Asset test and Asset Amount Limit
        ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 12),
               mapping = aes(x = factor(bbce_a_amt))) +
            geom_bar(mapping = aes(fill = bbce_asset), color = "black", position = "dodge") +
            scale_fill_brewer(palette = "Greens") +
            theme_bw() +
            labs(x = "Asset Dollar Amount in Thousands",
                 y = "Frequency",
                 title = "Count of policies by Asset Test and Asset Amount Limit under BBCE, Dec 2016")
        
    })
    
    
    
    # ---- Frequency Polygons and Count Plots ----
    # Render frequency polygon graphs
    output$freqpoly1 <- renderPlot({
        
        # Frequency polygon(s) of median certification period (in months) for SNAP units w/ earnings by "oapp" (State allows online SNAP application submission)
        ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 9),
               mapping = aes(x = certearnmed)) +
            geom_freqpoly(mapping = aes(linetype = reportsimple), bins = 10) +
            theme_bw() +
            labs(title = "Median Certification Period for earning SNAP units by Simplified Reporting, End of FY 2016",
                 x = "Months",
                 y = "Count")
        
    })
    
    
    
    # Render 2nd freq-polygon graph
    output$freqpoly2 <- renderPlot({
        
        # Frequency polygon(s) of median cert period for elderly SNAP units by cap
        ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 9),
               mapping = aes(x = certeldmed, color = cap)) +
            geom_freqpoly(bins = 10) +
            scale_color_brewer(palette = "Paired") +
            theme_bw() +
            labs(title = "Median Certification Period for elderly SNAP units by CAP usage, End of FY 2016",
                 subtitle = "States operating a Combined Application Project streamline the SNAP application process for SSI recipients",
                 x = "Months",
                 y = "Count")
        
    })
    
    
    
    output$freqpoly3 <- renderPlot({
        
        ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 9),
               mapping = aes(x = certnonearnmed)) +
            geom_freqpoly(bins = 10) +
            theme_bw() +
            labs(title = "Median Certification Period for nonearning, nonelderly SNAP units, End of FY 2016",
                 x = "Months",
                 y = "Count")
        
    })
    
    
    
    output$count1 <- renderPlotly({
        
        # Frequency plot of "faceini" against "facerec" variable
        # Determine number of State policies at end of FY 2016 with waivers for telephone interview at initial certification and recertifcation
        g <- ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 9),
                    mapping = aes(x = faceini, y = facerec)) +
            geom_count() +
            theme_bw() +
            labs(title = "Phone interview certfication waivers, End of FY 2016",
                 x = "Phone Interview for Initial Certification",
                 y = "Phone Interview for Recertification")
        
        ggplotly(g)
        
    })
    
    
    output$count2 <- renderPlotly({
        
        # Create frequency plot for "transben" and "reportsimple"
        g <- ggplot(data = snap %>% filter(year(yearmonth) == 2016 & month(yearmonth) == 9),
                    mapping = aes(x = reportsimple, y = transben)) +
            geom_count() +
            theme_bw() +
            labs(title = "Transitional benefits and simplified reporting, End of FY 2016",
                 x = "Simplified Reporting",
                 y = "Transitional SNAP Benefits Offered")
        
        ggplotly(g)
        
    })
    
    
    
    # ---- BBCE Tables and Missing Data ----
    # tabBox output of tables displaying bbce variables of interest
    # States that use bbce
    output$bbce1 <- renderTable({
        
        snap %>%
            filter(year(yearmonth) == 2016 & bbce == 1) %>%
            select(state_pc, bbce, bbce_inclmt, bbce_asset, bbce_hh, bbce_sen) %>%
            distinct() %>%
            arrange(desc(bbce_inclmt))
        
    })
    
    # States that DON'T use bbce
    output$bbce2 <- renderTable({
        
        snap %>%
            filter(year(yearmonth) == 2016 & bbce == 0) %>%
            select(state_pc, bbce, bbce_inclmt, bbce_asset, bbce_hh, bbce_sen) %>%
            distinct() %>%
            arrange(desc(bbce_inclmt))
        
    })
    
    # Static table in box displaying missing data for each policy variable
    output$missing <- renderPlot({
        
        # Data frame showing amount of NAS in the ENTIRE dataset
        # Plus proportion of missing data in ENTIRE dataset
        missing_data <- tibble(policy_variables = names(snap),
                               missing_values = colSums(sapply(snap, FUN = is.na)),
                               percent_missing = round((colSums(sapply(snap, FUN = is.na))) /
                                                           nrow(snap) * 100, 2))
        
        # Display column chart of missing data
        ggplot(data = missing_data %>% filter(missing_values != 0), 
               mapping = aes(x = factor(missing_values), 
                             y = percent_missing)) + 
            geom_col(color = "black") + 
            geom_text(mapping = aes(label = policy_variables), 
                      position = position_stack(vjust = .5)) +
            geom_text(mapping = aes(label = paste(percent_missing, "%")), 
                      color = "darkgoldenrod1", fontface = "bold", alpha = 0.25,
                      position = position_nudge(x = 0.35, y = 0.5)) +
            theme_bw() +
            labs(title = "Stacked Column Chart of policy variables with Missing Data in entire dataset",
                 subtitle = "Rectangle size corresponds to percent value in gold",
                 y = "Total Percent Missing",
                 x = "Number of Missing Values")
        
    })
    
    
    
    # ---- Interactive Table ----
    # Render an interactive table of the complete SNAP policy dataset/database
    # "snap" (R object of data) is a global variable (defined outside of server function)
    output$snapData <- renderDataTable(
        snap, 
        options = list(
            autoWidth = TRUE,
            scrollX = TRUE
        )
    )
    
} # End of server



# ==== Run Shiny App ====
shinyApp(ui, server)