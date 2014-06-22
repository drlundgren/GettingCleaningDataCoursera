## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

## Step 0. Check that data set exists and then read in all relevant files
## -------------------------------------------------------------------------
## check that data set directory exists. if not, exit.
if (!file.exists("UCI HAR Dataset")) {
    stop("Dataset directory does not exist. Exiting.") 
}
## change to the dataset directory
setwd("./UCI HAR Dataset")
## read in all relevant files
myAct <- read.table("./activity_labels.txt")
myFeatures <- read.table("./features.txt")
myTest <- read.table("./test//X_test.txt")
myTestLabels <- read.table("./test//y_test.txt")
myTestSubject <- read.table("./test/subject_test.txt")
myTrain <- read.table("./train/X_train.txt")
myTrainLabels <- read.table("./train/y_train.txt")
myTrainSubject <- read.table("./train/subject_train.txt")

## Step 1. Merge the training and the test sets to create one data set.
## Note: we will add the 'subject' and 'activity' columns later
## -------------------------------------------------------------------------
myMerged <- rbind(myTrain, myTest)


## Step 2. Extract only the measurements on the mean and standard deviation for each measurement. 
## -------------------------------------------------------------------------
myFactor <- grepl("mean\\(\\)|std\\(\\)", myFeatures[,2])
myMergedExtract <- myMerged[,myFactor]


## Step 3. Use descriptive activity names to name the activities in the data set
## -------------------------------------------------------------------------
## first, merge labels from training and test datasets
myActLabels <- rbind(myTrainLabels, myTestLabels) 
## second, translate from numeric representation to descriptive activity names
myActLabels$V1 <- factor(myActLabels$V1, levels=myAct$V1, labels=myAct$V2)
## third, incorporate 'activity' column into dataset 
myMergedExtract <- cbind(myActLabels, myMergedExtract)


## Step 3.5. Now we will also incorporate 'subject' column into the dataset
## -------------------------------------------------------------------------
## merge subjects from training and test datasets
mySubjects <- rbind(myTrainSubject, myTestSubject)
## incorporate 'subject' column into dataset
myMergedExtract <- cbind(mySubjects, myMergedExtract)


## Step 4. Appropriately labels the data set with descriptive variable names. 
## -------------------------------------------------------------------------
## we use the variable names from the features.txt file
## since they are descriptive,
## but we remove the parentheses to make it more user friendly.
myColNames <- myFeatures[myFactor,2]
myColNames <- gsub("\\(\\)", "", myColNames)
## we also add two desciptive names for the subject and activity columns
colnames(myMergedExtract) <- c("subject", "activity", as.character(myColNames))


## Step 5. Creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject. 
## -------------------------------------------------------------------------
myTidyDataset <- aggregate(x = myMergedExtract[,3:68], by = list(myMergedExtract$subject, myMergedExtract$activity), FUN = "mean")
## the aggregate function changed the subject and activity column names. We fix this.
myTidyColNames <- colnames(myTidyDataset)
myTidyColNames <- sub("Group.1", "subject", myTidyColNames)
myTidyColNames <- sub("Group.2", "activity", myTidyColNames)
colnames(myTidyDataset) <- myTidyColNames


## Final step: Write data to file and return data frame
## -------------------------------------------------------------------------
## write to file
write.table(myTidyDataset, file="tidyDataset.txt", row.names=FALSE)
## step back into parent directory
setwd("../")
## return data frame
myTidyDataset

