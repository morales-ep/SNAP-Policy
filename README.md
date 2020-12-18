# SNAP-Policy

This is the main directory for a dashboard project that used the [SNAP Policy Database](https://www.ers.usda.gov/data-products/snap-policy-data-sets/about-the-snap-policy-database/) compiled by the Economic Research Service, United States Department of Agriculture.

![Image of ERS USDA](https://upload.wikimedia.org/wikipedia/commons/f/f6/US-EconomicResearchService-Logo.svg)


## SNAP Policy Dashboard, 1996-2016

### Project Motivation
The purpose of this project is to provide an analysis of SNAP policies over a 20 year span, from 1996 to 2016, through data visualizations presented via R Shiny dashboard. Several socioeconomic crises have been accentuated and further compounded in light of the COVID-19 pandemic including widespread [Food Insecurity in the United States.](https://ajph.aphapublications.org/doi/10.2105/AJPH.2020.305953). The goal of this project is to highlight SNAP policies that may influence SNAP household participation and help address food insecurity caused by natural disasters and/or economic catastrophies.

This GitHub repository contains a spreadsheet data file and code for analysis, data visualizations, and the R Shiny dashboard. This project expanded on an academic project completed in Spring Quarter 2020 for the [Science & Technology Studies 115](https://sts.ucdavis.edu/courses/data-studies) course at the [University of California, Davis](https://www.ucdavis.edu). **The dashboard was designed for policy analysts and individuals possessing domain knowledge of SNAP.**


## About SNAP and Food Security
The *Supplemental Nutrition Assistance Program* (SNAP), previously known as the Food Stamp Program, is the largest federally funded nutrition assistance program in the United States but is administered in partnership with the States including the District of Columbia. SNAP provides benefits to eligible low-income individuals and families via an Electronic Benefits Transfer card.

*Food insecurity* is defined as limited or uncertain access to sufficient, nutritious food for an active, healthy life. People experiencing severe food insecurity skip meals or go hungry because they lack sufficient financial resources to purchase food or otherwise lack access to food. The experience of food insecurity is stressful and has been associated with numerous harmful physical and mental health outcomes over the short and long term. Food insecurity was an ongoing national issue prior to the COVID-19 pandemic but since March 2020 it has proliferated at alarming rates, thus raising more concern about long-term health outcomes, workforce participation, and poverty overall.


## Key Policy Variables
* **bbce**: The State uses broad-based categorical eligibility to increase or eliminate the asset test and/or to increase the gross income limit for virtually all SNAP applicants.
  - Coding description: range = 0, 1, where 0 = no and 1 = yes

* **bbce_inclmt**: The gross income limit as a percentage of the Federal poverty guidelines used under broad-based categorical eligibility.
  - Coding description: range = -9, 200, where -9 = no broad-based categorical eligibility
  
* **bbce_asset**: The State eliminates the asset test under broad-based categorical eligibility.
  - Coding description: range = -9, 1, where -9 = no broad-based categorical eligibility, 0 = asset limit is increased but not eliminated, and 1 = asset limit is eliminated.

* **bbce_a_amt**: The dollar amount of the asset limit used under broad-based categorical eligibility (in thousands).
  - Coding description: range = -9, 25, where -9 = no broad-based categorical eligibility, or broad-based categorical eligibility eliminates the asset test.
  
* **bbce_hh**: The State limits broad-based categorical eligibility to certain types of households.
  - Coding description: range = -9, 2, where -9 = no broad-based categorical eligibility, 0 = no limits on broad-based categorical eligibility, 1 = broad-based categorical eligibility limited to households with at least one dependent child, 2 = broad-based categorical eligibility limited to households with dependent care expenses.

* **bbce_sen**: The State increases or eliminates the asset test for households with senior or disabled members under broad-based categorical eligibility only if their gross income is below a specified level.
  - *Note: Households with senior or disabled members whose income is above the State-specified cut-off (typically 200 percent of the poverty line) do not qualify for broad-based categorical eligibility and would face the federal asset limit.*
  - Coding description: range = -9, 1, where -9 = no broad-based categorical eligibility, 0 = no gross income limit for households with seniors or disabled members to qualify for broad-based categorical eligibility, 1 = gross income limit applied to households with seniors or disabled members to qualify for broad-based categorical eligibility.
  
* **call**: The State operates call centers, and whether or not call centers service the entire State or select regions within the State.
  - Coding description: range = 0, 2, where 0 = no call centers, 1 = call centers available Statewide, and 2 = call centers available only in select parts of the State.
  
* **cap**: The State operates a Combined Application Project for recipients of Supplemental Security Income (SSI), so that SSI recipients are able to use a streamlined SNAP application process.
  - Coding description: range = 0, 1, where 0 = no and 1 = yes.
  
* **certearnmed**: The median certification period (in months) for SNAP units with earnings.
  - Coding description: range = 2.8, 15.
  
* **certeldmed**: The median certification period (in months) for elderly SNAP units.
  - Coding description: range = 6, 48.
  
* **certnonearnmed**: The median certification period (in months) for nonearning, nonelderly SNAP units.
  - Coding description: range = 3, 19.
  
* **faceini**: The State has been granted a waiver to use a telephone interview in lieu of a face-to-face interview at initial certification, without having to document household hardship.
  - Coding description: range = 0, 1, where 0 = no waiver, 1 = waiver applies in at least part of the State.

* **facerec**: The State has been granted a waiver to use a telephone interview in lieu of a face-to- face interview at recertification, without having to document household hardship.
  - Coding description: range = 0, 1, where 0 = no waiver, 1 = waiver applies in at least part of the State.
  
* **oapp**: The State allows households to submit a SNAP application online.
  - Coding description: range = 0, 2, where 0 = no, 1 = yes, Statewide, and 2 = yes, in only select parts of the State.

* **outreach**: The sum of Federal, State, and grant outreach spending in nominal dollars (in thousands). 
  - *Note: This variable is derived from annual data, spread across 12 months of the relevant fiscal year.*
  - Coding description: range = 0, 1881.

* **reportsimple**: For households with earnings, the State uses the simplified reporting option that reduces requirements for reporting changes in household circumstances.
  - Coding description: range = 0, 1, where 0 = no and 1 = yes.

* **transben**: The State offers transitional SNAP benefits to families leaving the TANF or State‐funded cash assistance programs.
  - Coding description: range = 0, 1, where 0 = no and 1 = yes.

[Data Dictionary](https://www.ers.usda.gov/data-products/snap-policy-data-sets/documentation/)


### Data Source
#### SNAP Policy Database
* XLS file downloaded from [ers.usda.gov](https://www.ers.usda.gov): [SNAP Policy Data Sets](https://www.ers.usda.gov/data-products/snap-policy-data-sets/)
  - Data was obtained via download to local device and imported to RStudio
  - File is also available to download [here](https://github.com/morales-ep/SNAP-Policy/blob/master/SNAP_Policy_Database.xlsx)

* Data spans 1996-2016 and therefore does not capture changes in [SNAP participation among US Territories](https://www.cbpp.org/research/food-assistance/how-does-household-food-assistance-in-puerto-rico-compare-to-the-rest-of)
  - More information about the SNAP Policy Database [here](https://www.ers.usda.gov/data-products/snap-policy-data-sets/about-the-snap-policy-database/)


# References
1. Economic Research Service (ERS), U.S. Department of Agriculture (USDA). SNAP Policy Database, SNAP Policy Data Sets. https://www.ers.usda.gov/data-products/snap-policy-data-sets/
2. Julia A. Wolfson, Cindy W. Leung, “Food Insecurity During COVID-19: An Acute Crisis With Long-Term Health Implications”, American Journal of Public Health 110, no. 12 (December 1, 2020): pp. 1763-1765. https://doi.org/10.2105/AJPH.2020.305953
3. Gundersen C, Ziliak JP. Food insecurity and health outcomes. Health Aff (Millwood). 2015;34(11):1830–1839. https://doi.org/10.1377/hlthaff.2015.0645 Crossref, Medline, Google Scholar
