# Copyright 2023 Observational Health Data Sciences and Informatics
#
# This file is part of olglmmCovid
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Execute the Study
#'
#' @details
#' This function executes the OLGLMM-COVID Study.
#' 
#' @param databaseDetails      The connection details and OMOP CDM details. Created using \code{PatientLevelPrediction::createDatabaseDetails}.
#' @param siteId               The reference name used for your database site
#' @param outputFolder         Name of local folder to place results - make sure control is in here; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param cohortTable          The name of the table to create the cohorts
#' @param createCohorts        Create the cohortTable table with the target population and outcome cohorts?
#' @param createData           Create the labelled data set (this is required before runAnalysis)
#' @param createPlot           Plot the number of covid hospitalizations by month 
#' @param sampleSize           The number of patients in the target cohort to sample (if NULL uses all patients)
#' @param run                  Runs the analysis - this require downloading the json control from https://pda-ota.pdamethods.org/ 
#'                             predictions.  This step requires downloading the updated json control from https://pda-ota.pdamethods.org/                        
#' @param verbosity            Sets the level of the verbosity. If the log level is at or higher in priority than the logger threshold, a message will print. The levels are:
#'                                         \itemize{
#'                                         \item{DEBUG}{Highest verbosity showing all debug statements}
#'                                         \item{TRACE}{Showing information about start and end of steps}
#'                                         \item{INFO}{Show informative information (Default)}
#'                                         \item{WARN}{Show warning messages}
#'                                         \item{ERROR}{Show error messages}
#'                                         \item{FATAL}{Be silent except for fatal errors}
#'                                         }  
#' @param wave1Start     The start date for the first wave in the data in "yyyymmdd" format    
#' @param wave1End     The end date for the first wave in the data in "yyyymmdd" format  
#' @param wave2Start     The start date for the second wave in the data in "yyyymmdd" format  
#' @param wave2End     The end date for the second wave in the data in "yyyymmdd" format 
#' @param wave3Start     The start date for the third wave in the data in "yyyymmdd" format  
#' @param wave3End     The end date for the third wave in the data in "yyyymmdd" format 
#'
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "postgresql",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'
#' execute(databaseDetails,
#'         siteId = 'db1',
#'         outputFolder = "c:/temp/study_results", 
#'         createCohorts = T,
#'         createData = T,
#'         sampleSize = 10000,
#'         run = F,
#'         verbosity = "INFO"
#'         )
#' }
#'
#' @export
execute <- function(
  databaseDetails,
  siteId,
  outputFolder,
  cohortTable = 'olglmm_covid',
  createCohorts = F,
  createData = F,
  createPlot = createData,
  sampleSize = NULL,
  run = F,
  verbosity = "INFO",
  wave1Start = '20201101',
  wave1End = '20210201',
  wave2Start = '20210701',
  wave2End = '20211001',
  wave3Start = '20210701', # TODO edit this to date
  wave3End = '20211001' # TODO edit this to date
) {
  
  
  dates <- list(
    first = list(startDate = wave1Start, endDate = wave1End),
    second = list(startDate = wave2Start, endDate = wave2End),
    third = list(startDate = wave3Start, endDate = wave3End)
  )
  
  if (!file.exists(outputFolder)){
    dir.create(outputFolder, recursive = TRUE)
  }
  
  website <- 'https://pda-ota.pdamethods.org/'
  
  # load the analysis
  analysisListFile <- system.file(
    "settings",
    "analysisList.json",
    package = "olglmmCovid"
  )
  
  if(file.exists(analysisListFile)){
    analysisList <- ParallelLogger::loadSettingsFromJson(analysisListFile)
  }else{
    stop('No analysisList available')
  }
  
  if(createCohorts) {
    ParallelLogger::logInfo("Creating cohorts")
    
    cohortDefinitionSet <- createCohortDefinitionSetFromJobContext(
      cohortDefinitions = analysisList$cohortDefinitions
    )
    
    cohortTableName <- CohortGenerator::getCohortTableNames(
      cohortTable = cohortTable 
      )
    
    CohortGenerator::createCohortTables(
      connectionDetails = databaseDetails$connectionDetails, 
      cohortDatabaseSchema = databaseDetails$cohortDatabaseSchema, 
      cohortTableNames = cohortTableName, 
      incremental = T
      )
    
    CohortGenerator::generateCohortSet(
      connectionDetails = databaseDetails$connectionDetails, 
      cdmDatabaseSchema = databaseDetails$cdmDatabaseSchema, 
      tempEmulationSchema = databaseDetails$tempEmulationSchema, 
      cohortDatabaseSchema = databaseDetails$cohortDatabaseSchema, 
      cohortTableNames = cohortTableName, 
      cohortDefinitionSet = cohortDefinitionSet, 
      incremental = T, 
      incrementalFolder = file.path(outputFolder, 'cohorts')
      )
    
    counts <- CohortGenerator::getCohortCounts(
      connectionDetails = databaseDetails$connectionDetails, 
      cohortDatabaseSchema = databaseDetails$cohortDatabaseSchema, 
      cohortTable = cohortTable
      )
    
    utils::write.csv(counts, file.path(outputFolder, 'cohortCounts.csv'))
    
  } 
  
  if(createPlot){
    ParallelLogger::logInfo('Generating date plot')
    generateDatePlot(
      databaseDetails = databaseDetails,
      outputFolder = outputFolder
    )
  }
  
  if(createData){
    ParallelLogger::logInfo('Extracting date')
    # save the settings
    
    timeSettings <- data.frame(
      wave = names(dates),
      starts = unlist(lapply(dates, function(x) x$startDate)),
      ends = unlist(lapply(dates, function(x) x$endDate))
    )
    utils::write.csv(timeSettings, file.path(outputFolder, 'timeSettings.csv'), row.names = F)
    
    for(wave in timeSettings$wave){
      
      if(!dir.exists(file.path(outputFolder, wave))){
        dir.create(file.path(outputFolder, wave), recursive = T)
      }
      # restrict to the input date:
      ParallelLogger::logInfo(paste0(wave, " date: ",dates[[wave]]$startDate, "-", dates[[wave]]$endDate ))
      analysisList$studySettings$restrictPlpDataSettings$studyStartDate <- dates[[wave]]$startDate
      analysisList$studySettings$restrictPlpDataSettings$studyEndDate <- dates[[wave]]$endDate
      
      if(!is.null(sampleSize)){
        analysisList$studySettings$restrictPlpDataSettings$sampleSize <- sampleSize
      }
      
      ParallelLogger::logInfo("Creating labelled dataset")
      
      databaseDetails$cohortId <- analysisList$studySettings$targetId
      databaseDetails$targetId <- analysisList$studySettings$targetId
      databaseDetails$outcomeIds <- analysisList$studySettings$outcomeId
      
      databaseDetails$cohortTable <- cohortTable
      databaseDetails$outcomeDatabaseSchema <- databaseDetails$cohortDatabaseSchema
      databaseDetails$outcomeTable <- cohortTable
      
      covariateSettings <- updateCovariateSettings(
        covariateSettings = analysisList$studySettings$covariateSettings,
        cohortSchema = databaseDetails$cohortDatabaseSchema,
        cohortTable = cohortTable
        )
      
      plpData <- tryCatch(
        {
        PatientLevelPrediction::getPlpData(
        databaseDetails = databaseDetails, 
        covariateSettings = covariateSettings, 
        restrictPlpDataSettings = analysisList$studySettings$restrictPlpDataSettings
        )}, 
        error = function(e){ParallelLogger::logInfo(e); return(NULL)}
      )
      
      if(!is.null(plpData)){
      labels <- PatientLevelPrediction::createStudyPopulation(
        plpData = plpData, 
        outcomeId = analysisList$studySettings$outcomeId, 
        populationSettings = analysisList$studySettings$populationSettings
      )
      
      # convert to matrix
      
      dataObject <- PatientLevelPrediction::toSparseM(
        plpData = plpData, 
        cohort = labels
      )
      
      #sparse matrix: dataObject$dataMatrix
      #labels: dataObject$labels
      
      columnDetails <- as.data.frame(dataObject$covariateRef)
      
      cnames <- columnDetails$covariateName[order(columnDetails$columnId)]
      
      ipMat <- as.matrix(dataObject$dataMatrix)
      ipdata <- as.data.frame(ipMat)
      colnames(ipdata) <-  makeFriendlyNames(cnames)
      ipdata$outcome <- dataObject$labels$outcomeCount
      
      #TODO - EDIT THIS FOR NEW SETTINGS 0-4, 5+ ?
      # modify the covariates
      # Charlson comorbidity categories: 0-1, 2-4, and 5
      if('Charlson_index___Romano_adaptation' %in% colnames(ipdata)){
        ParallelLogger::logInfo('Processing Charlson index into categories')
        # Charlson comorbidity categories: 0-4, and 5
        
        # make 0-4 the reference
        ipdata$Charlson_index___Romano_adaptation5p <- rep(0, nrow(ipdata))
        ipdata$Charlson_index___Romano_adaptation5p[ipdata$Charlson_index___Romano_adaptation >= 5] <- 1
        
        ipdata <- ipdata[!colnames(ipdata) == 'Charlson_index___Romano_adaptation']
      }
      
      # 
      if('age_in_years' %in% colnames(ipdata)){
        ParallelLogger::logInfo('Processing age into categories')
        
        # make 18-64 the reference
        ##ipdata$age18_64 <- rep(0, nrow(ipdata))
        ##ipdata$age18_64[ipdata$age_in_years >= 0 & ipdata$age_in_years <= 64] <- 1
        
        ipdata$age65_80 <- rep(0, nrow(ipdata))
        ipdata$age65_80[ipdata$age_in_years >= 65 & ipdata$age_in_years <= 79] <- 1
        
        ipdata$age80p <- rep(0, nrow(ipdata))
        ipdata$age80p[ipdata$age_in_years >= 80] <- 1
        
        ipdata <- ipdata[,colnames(ipdata) != 'age_in_years']
      }
      
      # make the female gender the reference
      ipdata <- ipdata[,colnames(ipdata) != 'gender___FEMALE']
      
      # save the data:
      utils::write.csv(
        x = ipdata, 
        file = file.path(outputFolder,wave,'data.csv'), 
        row.names = F
      )
      
      } # end if not null
      
    } # end wave
    
  }
  
  if(run){
    
    jsonFileLocation <- list(
      first = file.path(outputFolder,'first', 'control.json'),
      second = file.path(outputFolder,'second', 'control.json'),
      third = file.path(outputFolder,'third', 'control.json')
    )
    
    for(wave in names(jsonFileLocation)){
      
      control <- tryCatch(
        {readChar(jsonFileLocation[[wave]], file.info(jsonFileLocation[[wave]])$size)},
        error= function(cond) {
          ParallelLogger::logInfo('Issue with loading control json file...');
          ParallelLogger::logError(cond);
          return(NULL)
        })
      
      
      if(!is.null(control)){

        # check control name 
        control <- jsonlite::fromJSON(control)
        if(length(grep(wave, control$project_name))==0){
          ParallelLogger::logWarn('Control project_name suggests incorrect wave')
        }
        
        ipdata <- utils::read.csv(file.path(outputFolder, wave, 'data.csv'))
        
        if(!is.null(control)){
          pda::pda(
            ipdata = ipdata, 
            site_id = siteId, 
            dir = file.path(outputFolder, wave)
          )
          
          ParallelLogger::logInfo(paste0('result json ready to check in ', file.path(outputFolder, wave)))
          ParallelLogger::logInfo(paste0('If you are happy to share, please upload this to ', website))
          
        } else {
          ParallelLogger::logInfo(paste0('No control for wave ', wave))
        }
      }
    } # end wave
    
  } # end run
  
  invisible(NULL)
}


makeFriendlyNames <- function(columnNames){
  
  columnNames <- gsub("[[:punct:]]", " ", columnNames)
  columnNames <- gsub(" ", "_", columnNames)
  return(columnNames)
  
}