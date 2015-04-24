---
title: "Readme - Getting and Cleaning Data Course Project"
author: "Graham Giles"
date: "Friday, April 24, 2015"
output: pdf_document
---

All relevant files (excluding the Inertia data) were loaded into R. The Inertia data was not loaded into R because it was determined that it was not necessary to achieve the objectives of the assignment. 

```{r}

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
```

The Training.Labels and Test.Labels set included the activities performed in chronological order based on the time windows described in Codebook.md. This section of the code matches the activity name with the chronological activity in order to apply activity names to the chronological activity pattern.

```{r}
colnames(Activity.Labels) <- c("id", "Activity")

colnames(Training.Labels) <- "id"
Training.Activity.Labels <- join(Training.Labels, Activity.Labels, by = "id")

colnames(Test.Labels) <- "id"
Test.Activity.Labels <- join(Test.Labels, Activity.Labels, by = "id")
```

It was determined that the number of columns in Training.Set and Test.Set equalled to the number of features listed inthe Features set. Therefore, the Feature names were turned into a vector, and used as column names, and therefore variables for the Test and Training set.

```{r}
Features.Vec <- as.vector(as.character(Features$feature))

colnames(Training.Set) <- Features.Vec

colnames(Test.Set) <- Features.Vec
```

It was determined that the number of columns in Test.Subjects and Training.Subjects corresponded to Test.Set and Training.Set respectively and the Test.Activity.Labels and Training.Labels.Set respectively. As such, since each row identifies the subject who performed the activity for each window sample in the Subjects sets, the Subject activity pattern for each of the Training and Test sets was bound to the Training and Test sets. 


```{r}
Test.Subjects.Activity <- cbind(Test.Subjects, Test.Activity.Labels$Activity)
Training.Subjects.Activity <- cbind(Training.Subjects, Training.Activity.Labels$Activity)
colnames(Test.Subjects.Activity) <- c("Subject.ID", "Activity")
colnames(Training.Subjects.Activity) <- c("Subject.ID", "Activity")


Test.Set <- cbind(Test.Subjects.Activity, Test.Set)
Training.Set <- cbind(Training.Subjects.Activity, Training.Set)
```

According to the course project requiremetns, we are to take the average of the mean and standard deviation variables. As such, we searched for variables that DID NOT include the words "mean" and "std" (case agnostic), so that we culd remove those variables later.

```{r}
Features$feature <- as.character(Features$feature)
pattern <- "mean|std"
Features.mean.std <- filter(Features, !grepl(pattern, Features$feature, ignore.case=TRUE))
```
Because 2 columns were added to each of the Training and Test sets as per above, 2 shall be added to each sequential identifier within the filtered Features set.

```{r}
Features.mean.std <- mutate(Features.mean.std, id = id+2)
```

Convert data sets into a data table, and then create a numeric vector for the positions
of each of the columns in the data set that DO NOT include the words "mean" or "std". Then we filtered those columns out to leave is with ONLY the columns that include the words "mean" or "std".

```{r}
Test.Set.Filtered <- data.table(Test.Set)
Features.MSTD.NVec <- as.vector(as.numeric(Features.mean.std$id))
Test.Set.Filtered[,(Features.MSTD.NVec):=NULL]

Training.Set.Filtered <- data.table(Training.Set)
Features.MSTD.NVec <- as.vector(as.numeric(Features.mean.std$id))
Training.Set.Filtered[,(Features.MSTD.NVec):=NULL]
```

The two processed data sets will now be merged as per the course project requirements.

```{r}
Merged.Set <- rbind(Test.Set.Filtered, Training.Set.Filtered)
```

Group by Activity, Subject ID, and then take the means of each of the variables to get the average as per the Course Project requirements and write to a tidy text file.

```{r}
Merged.Set.Sum <- Merged.Set %>% group_by(Activity,Subject.ID) %>% summarise_each(funs(mean))

write.table(Merged.Set.Sum, "MergedSetSum.txt")
```
