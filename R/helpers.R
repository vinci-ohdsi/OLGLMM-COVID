createCohortDefinitionSetFromJobContext <- function(cohortDefinitions) {
  if (length(cohortDefinitions) <= 0) {
    stop("No cohort definitions found")
  }
  cohortDefinitionSet <- CohortGenerator::createEmptyCohortDefinitionSet()
  for (i in 1:length(cohortDefinitions)) {
    cohortJson <- cohortDefinitions[[i]]$cohortDefinition
    cohortExpression <- CirceR::cohortExpressionFromJson(cohortJson)
    cohortSql <- CirceR::buildCohortQuery(
      cohortExpression, 
      options = CirceR::createGenerateOptions(
        generateStats = T
        )
      )
    cohortDefinitionSet <- rbind(cohortDefinitionSet, data.frame(
      cohortId = as.double(cohortDefinitions[[i]]$cohortId),
      cohortName = cohortDefinitions[[i]]$cohortName,
      sql = cohortSql,
      json = cohortJson,
      stringsAsFactors = FALSE
    ))
  }
  
  return(cohortDefinitionSet)
}


updateCovariateSettings <- function(
  covariateSettings,
  cohortSchema,
  cohortTable
){
  
  if(inherits(covariateSettings, 'covariateSettings')){
    covariateSettings <- list(covariateSettings)
  }
  
  covariateSettings <- lapply(
    covariateSettings, function(x){
      updateCohortDetails(x, cohortSchema, cohortTable)
    }
  )
  
  return(covariateSettings)
}


updateCohortDetails <- function(
    covariateSettings,
    cohortDatabaseSchema,
    cohortTable
    ){
  
  if(!is.null(covariateSettings$cohortTable)){
    covariateSettings$cohortTable <- cohortTable
  }
  if(!is.null(covariateSettings$cohortDatabaseSchema)){
    covariateSettings$cohortDatabaseSchema <- cohortDatabaseSchema
  }
  
  return(covariateSettings)
}


