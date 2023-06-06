library(olglmmCovid)
# USER INPUTS
#=======================

siteId <- 'VA'

# The folder where the study intermediate and result files will be written:
outputFolder <- "your dirctory to save results" # e.g., "C:/OLGLMMResults"

# Details for connecting to the server:
dbms <- "sql server"
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