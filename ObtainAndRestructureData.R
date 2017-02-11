library(rio)
library(dplyr)
library(reshape2)

#Set working directory
setwd("C:/Users/warose/Desktop/PersonalProjects/Global Migration Dashboard/Countries")

#Create download Link and Intended File Directory
dataLink <- "http://www.un.org/en/development/desa/population/migration/data/empirical2/data/UN_MigFlow_All_CountryFiles.zip"
fileName <- "UN_MigFlow_All_CountryFiles.zip"
filePath <- paste0(getwd(),"/",fileName)

#Download the Data
download.file(dataLink, filePath)

#Unzip the data into folder
unzip(filePath)

#List out all countries' xlsx files
fileList <- list.files()
fileList <- fileList[!grepl(".zip", list.files())]
fileCount <- length(fileList)

#Convert xlsx files to csv
newfileList <- gsub(".xlsx", ".csv", fileList)
for(x in 1:fileCount){
  
  convert(fileList[x], newfileList[x])
  
}

#Loop to Read all files into R and combine them into single table
for(y in 1:fileCount){
  
  df <- read.csv(newfileList[y], stringsAsFactors = FALSE)
  rownum <- which(df=="Type")
  
  #rename columns
  newColumnNames <- as.character(df[rownum,])
  colnames(df) <- newColumnNames
  
  #trim unnecessary rows
  df <- df[-(1:rownum),] #top rows
  
  bottomRemove <- which(is.na(df$Type))
  df <- df[-bottomRemove,] #bottom rows
  
  #trim unnecessary column
  columnRemove <- which(newColumnNames=="NA")
  df <- df[-columnRemove]
  
  #create country name column
  country <- gsub(".csv", "", newfileList[y])
  df$Country <- rep(country, nrow(df))
  
  #melt table to long format
  dontMelt <- c(1:4, ncol(df))
  dontMelt <- names(df)[dontMelt]
  
  df <- melt(df, id.vars = dontMelt)
  
  #convert variables to correct data types
  df$variable <- as.numeric( as.character(df$variable) )
  df$value <- as.numeric(df$value)
  
  #first file read into R is turned to the main table and each
  #subsequent file is joined to it
  if(y == 1){
    full <- df
  } else {
    full <- full_join(full, df)
  }
  
}

#rename 2 columns
names(full)[6:7] <- c("Year","Count")

#export file for tableau
write.csv(full, "GlobalMigrationData.csv", row.names = FALSE)
