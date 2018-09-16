## Install and load necessary packages
if(!("dplyr" %in% row.names(installed.packages())))
        install.packages("dplyr")

library(dplyr)

## Read training data
train1 <- read.table("train/subject_train.txt")
train2 <- read.table("train/y_train.txt")
train3 <- read.table("train/X_train.txt")
train <- cbind(train1, train2, train3)
rm("train1","train2","train3")

## Read test data
test1 <- read.table("test/subject_test.txt")
test2 <- read.table("test/y_test.txt")
test3 <- read.table("test/X_test.txt")
test <- cbind(test1, test2, test3)
rm("test1","test2","test3")

## Create combined dataset
fullset <- rbind(train, test)
rm("test","train")

## Subset required columns and add variable names
fnames <- read.table("features.txt")
fnames <- as.character(fnames[,2])

col_nos <- grep("(.*mean\\(\\))|(.*std\\(\\))", fnames)
result_names <- paste0("Avg.",fnames[col_nos])
fnames <- c("Subject_ID", "Activity", fnames[col_nos])  ## required variable names
col_nos <- c(1, 2, (col_nos + 2))  ## indices of required columns

healthdata <- fullset[,col_nos]
names(healthdata) <- fnames
rm("fullset")

## Add activity names
activity <- read.table("activity_labels.txt")
activity <- as.character(activity[,2])
healthdata$Activity <- as.character(healthdata$Activity)
for(i in 1:6) {
       healthdata$Activity <- gsub( as.character(i), activity[i], healthdata$Activity ) 
}

## Calculate average values for each subject, for each activity
result <- data.frame(Subject_ID=rep(1:30,6), Activity=rep(sort(activity), each=30 ))
for(i in 3:68) {
        s <- split(healthdata[,i], list(healthdata$Subject_ID, healthdata$Activity))
        m <- sapply(s, mean)
        m <- as.numeric(m)
        result <- cbind(result,m)
}
names(result) <- c("Subject_ID", "Activity", result_names)

write.table(result, "health_summary.txt", sep="\t", row.names = FALSE )

