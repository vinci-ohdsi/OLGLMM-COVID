Instructions To Run Study 
===================
- This study requires running steps to 1) determine wave dates, 2) download data, 3) run analysis and 4) submitting results to https://pda-ota.pdamethods.org/ 
- We will organize a 1-hour virtual meeting where we will demonstrate what to do and answer any questions. 
- After step 4 is finished, results will be generated and each site will be sent their own site ranking.  A manuscript will be written.


## Step 0a - Register (skip this if you already have an account)
- register an account at https://pda-ota.pdamethods.org/

## Step 0b - Sign Up for the first/second/thrid wave studies
- Create a directory where you want to save the results to.  We will refer to this directory as `outputFolder`.  Create three folders in the `outputFolder` called `first`, `second` and `third`. 

- There are three studies investigating the main three COVID waves. Get the `project name` and `inviation code` per wave from the study lead.  This will then enable you to download the control jsons for the studies. 

- Please place the first wave control.json file into the `outputFolder/first`, the second wave control.json file into the `outputFolder/second` folder and the thrid wave control.json file into the `outputFolder/third` folder.

## Step 1 - Determine wave dates for your database
- run the following code to create the study cohorts and create a plot with the number of hospitalization on the y-axis and the date on the x-axis.  This will be used to determine the start/end of the first/second/third waves.

You need to specify the database details for the OMOP CDM database you are analyzing, `siteId` the unique reference for your site and `outputFolder` the directory to saved the plot to (this should be the same place as Step 1b).  After running the code you will see a new file in `outputFolder` called `countPerDate.pdf`.

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/OLGLMMResults"

# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'

# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

tempEmulationSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'olglmm_covid'

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = cdmDatabaseSchema, 
  cdmDatabaseName = cdmDatabaseSchema,
  tempEmulationSchema = tempEmulationSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outcomeDatabaseSchema = cohortDatabaseSchema,
  outcomeTable = cohortTable,
  cdmVersion = 5
)

execute(
  databaseDetails = databaseDetails,
  siteId = siteId,
  outputFolder = outputFolder,
  cohortTable = cohortTable,
  createCohorts = T,
  createData = F,
  createPlot = T,
  run = F,
  verbosity = "INFO"
  )
```

Open the `countPerDate.pdf` file to view the covid trajectory for your dataset.  Determine when the first/second/third wave started (yyyymmdd) and ended (yyyymmdd).


## Step 2 - Download the data for each wave

Now run the following code to extract summary data for each wave (but use your dates):

```r
execute(
  databaseDetails = databaseDetails,
  siteId = siteId,
  outputFolder = outputFolder,
  cohortTable = cohortTable,
  createCohorts = F,
  createData = T,
  createPlot = F,
  run = F,
  verbosity = "INFO",
  wave1Start = '20201101',
  wave1End = '20210201',
  wave2Start = '20210701',
  wave2End = '20211001',
  wave3Start = '20210701',
  wave3End = '20211001' 
    )
```

After running the code you will see a file called `data.csv` in the directories `outputFolder/first`, `outputFolder/second` and `outputFolder/third`.


## Step 3 - Run Analysis
- Make sure each first/second/third folder contains the data.csv and the control.json.

- run the following code to create the json summary for each wave.  After running the code you will see a new file in `outputFolder/first`, `outputFolder/second` and `outputFolder/third` folders called `<siteId>_initialize.json`.

```r
library(dGEMcovid)
# USER INPUTS
#=======================

siteId <- 'an id given to you by the study lead'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/OLGLMMResults"

# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'

# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

tempEmulationSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'olglmm_covid'

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = cdmDatabaseSchema, 
  cdmDatabaseName = cdmDatabaseSchema,
  tempEmulationSchema = tempEmulationSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outcomeDatabaseSchema = cohortDatabaseSchema,
  outcomeTable = cohortTable,
  cdmVersion = 5
)

arrange_all <- dplyr::arrange_all
as_tibble <- dplyr::as_tibble
summarise <- dplyr::summarise
group_by_at <- dplyr::group_by_at
n <- dplyr::n
left_join <- dplyr::left_join

execute(
  databaseDetails = databaseDetails,
  siteId = siteId,
  outputFolder = outputFolder,
  createCohorts = F, 
  cohortTable = cohortTable,
  createData = F, 
  createPlot = F, 
  run = T,
  verbosity = "INFO"
        )
```
## Step 4 - Submit Results
- You now need to inspect the `<siteId>_initialize.json` and if happy log into https://pda-ota.pdamethods.org/  and upload the file to the correct study (first/second/third).
- Your part is now done.  Sit back and wait for the study lead to send you the results.
