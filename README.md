GettingCleaningDataCoursera
===========================
## README
The run_analysis.R script assumes the existence of the 
"UCI HAR Dataset" (and a directory with the same name to 
be present in the current working directory).
Change the working directory to your directory in which 
you have the "UCI HAR Dataset" subdirectory. Then simply execute the script (it takes no arguments). It will produce a tidy data set and also write it to a file named "tidyDataset.txt" inside the "UCI HAR Dataset" directory. 

This script reads the test and train data and merges them 
into one dataset, then it extracts only the measurements 
that are mean values and standard deviation values.

It replaces the numeric representations of the activity type
in the original dataset with the descriptive names (that were
also provided in the original dataset). Example of activities
are "WALKING", "STANDING". The original file 'activity_labels.txt'
includes the full list of activities.

Then, it make sure that all columns have descriptive colum names.
It leverages the already descriptive names in the original 'features.txt'
file, but removes parentheses for better readabilty. Examples are 
'tBodyAcc-mean-X' (average of body acceleration in the x-axis direction in the time domain) and 'fBodyAcc-std-Y' (standard deviation of body acceleration in the y-axis direction in the frequency domain).
It also adds descriptive
names for the 'subject' and 'activity' data (column names: "subject" and "activity"). 

Finally, it produces a tidy data set, where for each of the extracted variables 
it reports the average value for each subject and each activity.
This tidy data set is consistent with the definition in 
Hadly Wickman's "Tidy Data" (each variable forms a column; each observations forms a row; each type of observational unit forms a table). Note that in our data 
set there is only a single observational unit (i.e., subjects are people).
 
#### In more details the run_analysis.R script does the following (for each step we show the code below):
#### 0. It first checks data set directory exists (this script assumes its existence).
#### 1. Merges the training and the test sets to create one data set.
#### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#### 3. Uses descriptive activity names to name the activities in the data set
#### 4. Appropriately labels the data set with descriptive variable names. 
#### 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

### Step 0. Check that data set exists and then read in all relevant files
```{r}
if (!file.exists("UCI HAR Dataset")) {
    stop("Dataset directory does not exist. Exiting.") 
}
setwd("./UCI HAR Dataset")
myAct <- read.table("./activity_labels.txt")
myFeatures <- read.table("./features.txt")
myTest <- read.table("./test//X_test.txt")
myTestLabels <- read.table("./test//y_test.txt")
myTestSubject <- read.table("./test/subject_test.txt")
myTrain <- read.table("./train/X_train.txt")
myTrainLabels <- read.table("./train/y_train.txt")
myTrainSubject <- read.table("./train/subject_train.txt")
```

### Step 1. Merge the training and the test sets to create one data set.
### Note: we will add the 'subject' and 'activity' columns later
```{r}
myMerged <- rbind(myTrain, myTest)
```

### Step 2. Extract only the measurements on the mean and standard deviation for each measurement. 
```{r}
myFactor <- grepl("mean\\(\\)|std\\(\\)", myFeatures[,2])
myMergedExtract <- myMerged[,myFactor]
```

### Step 3. Use descriptive activity names to name the activities in the data set:
#### first, merge labels from training and test datasets
#### second, translate from numeric representation to descriptive activity names
#### third, incorporate 'activity' column into dataset 
```{r}
myActLabels <- rbind(myTrainLabels, myTestLabels) 
myActLabels$V1 <- factor(myActLabels$V1, levels=myAct$V1, labels=myAct$V2)
myMergedExtract <- cbind(myActLabels, myMergedExtract)
```

### Step 3.5. merge 'subject' columns from training and test datasets and incorporate it into dataset
```{r}
mySubjects <- rbind(myTrainSubject, myTestSubject)
myMergedExtract <- cbind(mySubjects, myMergedExtract)
```

### Step 4. Appropriately labels the data set with descriptive variable names. 
#### We use the variable names from the features.txt file
#### since they are descriptive,
#### but we remove the parentheses to make it more user friendly.
#### We also add two desciptive names for the subject and activity columns
```{r}
myColNames <- myFeatures[myFactor,2]
myColNames <- gsub("\\(\\)", "", myColNames)
colnames(myMergedExtract) <- c("subject", "activity", as.character(myColNames))
```

### Step 5. Creates a second, independent tidy data set 
### with the average of each variable for each activity and each subject. 
#### We also restored the subject and activity column names (that aggregate function removed).
```{r}
myTidyDataset <- aggregate(x = myMergedExtract[,3:68], by = list(myMergedExtract$subject, myMergedExtract$activity), FUN = "mean")
myTidyColNames <- colnames(myTidyDataset)
myTidyColNames <- sub("Group.1", "subject", myTidyColNames)
myTidyColNames <- sub("Group.2", "activity", myTidyColNames)
colnames(myTidyDataset) <- myTidyColNames
```

### Final step: Write data to file, go to original directory, and return data frame
```{r}
write.table(myTidyDataset, file="tidyDataset.txt", row.names=FALSE)
setwd("../")
myTidyDataset
```
