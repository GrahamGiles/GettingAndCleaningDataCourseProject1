## Load and read all relevant files containing raw data

setwd("C:/Users/rr177704/Desktop/Courses/Getting and Cleaning Data/A/UCI HAR Dataset/")
Activity.Labels <- read.table("activity_labels.txt")
colnames(Activity.Labels) <- c("id","Activity")
Features <- read.table("features.txt")
colnames(Features) <- c("id", "feature")

setwd("C:/Users/rr177704/Desktop/Courses/Getting and Cleaning Data/A/UCI HAR Dataset/train")
Training.Subjects <- read.table("subject_train.txt")
Training.Set <- read.table("x_train.txt")
Training.Labels <- read.table("y_train.txt")

setwd("C:/Users/rr177704/Desktop/Courses/Getting and Cleaning Data/A/UCI HAR Dataset/test")
Test.Subjects <- read.table("subject_test.txt")
Test.Set <- read.table("x_test.txt")
Test.Labels <- read.table("y_test.txt")


##Merge Activity Labels with Training & Test labels

colnames(Activity.Labels) <- c("id", "Activity")

colnames(Training.Labels) <- "id"
Training.Activity.Labels <- join(Training.Labels, Activity.Labels, by = "id")

colnames(Test.Labels) <- "id"
Test.Activity.Labels <- join(Test.Labels, Activity.Labels, by = "id")

##Set column names in each of the Training and Test sets to the relevant features

Features.Vec <- as.vector(as.character(Features$feature))

colnames(Training.Set) <- Features.Vec

colnames(Test.Set) <- Features.Vec

## Bind Subject ID, and Activity sequentially based on window

Test.Subjects.Activity <- cbind(Test.Subjects, Test.Activity.Labels$Activity)
Training.Subjects.Activity <- cbind(Training.Subjects, Training.Activity.Labels$Activity)
colnames(Test.Subjects.Activity) <- c("Subject.ID", "Activity")
colnames(Training.Subjects.Activity) <- c("Subject.ID", "Activity")

## Bind Subject ID, and Activity to the data sets

Test.Set <- cbind(Test.Subjects.Activity, Test.Set)
Training.Set <- cbind(Training.Subjects.Activity, Training.Set)

## Filter features that DO NOT contain the strings "mean" or "std". The cases have been 
## ignored.

Features$feature <- as.character(Features$feature)
pattern <- "mean|std"
Features.mean.std <- filter(Features, !grepl(pattern, Features$feature, ignore.case=TRUE))

## Because 2 columns were added to each of the Training and Test sets as per above,
## 2 shall be added to each sequential identifier within the filtered Features set.
Features.mean.std <- mutate(Features.mean.std, id = id+2)

## Convert data sets into a data table, and then create a numeric vector for the positions
## of each of the columns in the data set that DO NOT include the words "mean" or "std"

Test.Set.Filtered <- data.table(Test.Set)
Features.MSTD.NVec <- as.vector(as.numeric(Features.mean.std$id))
Test.Set.Filtered[,(Features.MSTD.NVec):=NULL]

Training.Set.Filtered <- data.table(Training.Set)
Features.MSTD.NVec <- as.vector(as.numeric(Features.mean.std$id))
Training.Set.Filtered[,(Features.MSTD.NVec):=NULL]

## Merge the two data sets

Merged.Set <- rbind(Test.Set.Filtered, Training.Set.Filtered)

## Group by Activity, Subject ID, and then take the means of each of the variables.

Merged.Set.Sum <- Merged.Set %>% group_by(Activity,Subject.ID) %>% summarise_each(funs(mean))

## Write to a text file

write.table(Merged.Set.Sum, "MergedSetSum.txt")