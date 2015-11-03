# (install and) load the library
#devtools::install_github('keboola/r-docker-application')
library('keboola.r.docker.application')

# intialize application
app <- DockerApplication$new('/data/')
app$readConfig()

# do something clever
tables <- app$getInputTables()
for (i in 1:nrow(tables)) {
    name <- tables[i, 'destination'] 
    
    #read table data
    data <- read.csv(tables[i, 'full_path'])
    
    # read table metadata
    manifest <- app$getTableManifest(name)
    if ((length(manifest$primary_key) == 0) && (nrow(data) > 0)) {
        data[['primary_key']] <- seq(1, nrow(data))
    } else {
        data[['primary_key']] <- NULL
    }
    names(data) <- paste0('batman_', names(data))
    
    # read output mapping
    outName <- app$getExpectedOutputTables()[i, 'full_path']
    outDestination <- app$getExpectedOutputTables()[i, 'destination']

    # write output data
    write.csv(data, file = outName, row.names = FALSE)
    
    # write table metadata
    app$writeTableManifest(outName, destination = outDestination, primaryKey = c('batman_primary_key'))
}
