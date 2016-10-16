## Getting and Cleaning Data Final Assignment

## Preparation - Load web data into local folder and Read into R  ##
## Download the Zip file to Data folder
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "HumanData.zip")

## Unzip file
unzip("HumanData.zip")
## Read files in the unzipped folder - UCI HAR Dataset
path <- getwd()
path
pathIn <- file.path(path, "UCI HAR Dataset")
list.files(pathIn, recursive=TRUE)
## Read data into R
## Read Subjects files into R
SubjTrainDt<-read.table(file.path(pathIn,"train","subject_train.txt"))
SubjTestDt<-read.table(file.path(pathIn,"test","subject_test.txt"))

## Read Activity Data into R
ActTrainDt<- read.table(file.path(pathIn,"train","Y_train.txt"))
ActTestDt<- read.table(file.path(pathIn,"test","Y_test.txt"))

## Read the train and test data files into R
TrainData<-read.table(file.path(pathIn,"train","X_train.txt"))
TestData<-read.table(file.path(pathIn,"test","X_test.txt"))

## Read Feature and activity label Data into R
FeturData<-read.table(file.path(pathIn,"features.txt"))
ActivitiesLabel<-read.table(file.path(pathIn,"activity_labels.txt"))


## Task 1: Merge the Training and the Test data into one data set ##
##Combine Subjects data and name variables properly
library(dplyr)
subjData <- rbind(SubjTrainDt, SubjTestDt)
names(subjData)
SubjectData<-rename(subjData,subject_id=V1)
names(SubjectData)

##Combine Activity Data and name variables properly
ActyData<-rbind(ActTrainDt,ActTestDt)
names(ActyData)
ActivityData<-rename(ActyData,activity_id=V1)
head(ActivityData)

##Combine Train and Test Data and add variable names from feature file
MainData<-rbind(TrainData,TestData)
feature_names<- FeturData[,2]
colnames(MainData)<-feature_names
##Merge Subjects and Activity Data
SubjectData<-cbind(SubjectData,ActivityData)

## Merge to Main Data
MainData<-cbind(SubjectData,MainData)


## Task 2: Extracts only the measurements on the mean and standard deviation for each measurement ##
col_index<-grep("mean|std", names(MainData), ignore.case = TRUE)
col_names<-names(MainData)[col_index]
meanstddata<-MainData[,c("subject_id","activity_id",col_names)]


## Task 3: Uses decriptive activity names to name the activities in the data set ##
head(ActivitiesLabel, 2)
Activity_label<-rename(ActivitiesLabel,activity_id = V1 , activity_name = V2)
head(Activity_label,2)
## Merge label data to main data set
descnames<-merge(Activity_label,meanstddata, by.x = "activity_id", by.y = "activity_id", all = TRUE)


## Task 4: Appropriately labels the data set with descriptive variable names ##
library(reshape2)
orgnized_data<- melt(descnames, id=c("activity_id","activity_name","subject_id"))


## Task 5: Create a tidy data set with average of each variable for each activity and subject ##
## Calculate mean and create a new tidy data set in R
mean_data<- dcast(orgnized_data, activity_id + activity_name + subject_id ~ variable, mean)
## Export the data set to local repo
write.table(mean_data, "Tidy_data.txt")
