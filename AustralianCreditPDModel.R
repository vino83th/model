# Selection Path location
Path = "C:/users/vjayaratnam/Documents/SkyDrive/Vinoth1/Credit Risk/Presentation/australian1.csv"

# install packages
install.packages("lattice")
install.packages("ROCR")
install.packages("rpart")

# load library
library(lattice)
library(ROCR)
library(rpart)

#loading csv file 
AustralianCR.data<-read.csv(Path)

##############################
### Data Cleaning process ####
##############################

#check the header
head(AustralianCR.data)

#if header in not exist then
names(AustralianCR.data) <- c("Data1", "Data2", "Data3", "Data4", "Data5", "Data6", "Data7", "Data8", "Data9", "Data10", "Data11", "Data12", "Data13", "Data14", "Data15")

#check the header
head(AustralianCR.data)

# check the data chars
is.numeric(AustralianCR.dataAustralianCR.data$Data1)
is.factor(AustralianCR.data$Data1)
is.list(AustralianCR.data$Data1)
is.nan(AustralianCR.data$Data1)
is.matrix(AustralianCR.data$Data1)

# String will compeactly display the structure of any R object
str(AustralianCR.data)

#additionally, to make the code more legible and easier to write, we can attach the object 
attach(AustralianCR.data)

# Plot the datas and check arributes 
# Plot
plot(Data1, type = "l", col = "royalblue")
plot(Data2, type = "l", col = "brown")
plot(Data3, type = "l", col = "royalblue")
plot(Data4, type = "l", col = "brown")
plot(Data5, type = "l", col = "royalblue")
plot(Data6, type = "l", col = "brown")
plot(Data7, type = "l", col = "royalblue")
plot(Data8, type = "l", col = "brown")
plot(Data9, type = "l", col = "royalblue")
plot(Data10, type = "l", col = "brown")
plot(Data11, type = "l", col = "royalblue")
plot(Data12, type = "l", col = "brown")
plot(Data13, type = "l", col = "royalblue")
plot(Data14, type = "l", col = "brown")

# Histogram
Histogram(Data1)
Histogram(Data2)
Histogram(Data3)
Histogram(Data4)
Histogram(Data5)
Histogram(Data6)
Histogram(Data7)
Histogram(Data8)
Histogram(Data9)
Histogram(Data10)
Histogram(Data11)
Histogram(Data12)
Histogram(Data13)
Histogram(Data14)

# Clasification of the Data 2
AustralianCR.data$Data16 <- as.factor(ifelse(Data2<=10,"0-10", ifelse(Data2<=40,"10-40","40+")))
head(AustralianCR.data$Data16)

# Clasification of the Data 3
AustralianCR.data$Data17 <- as.factor(ifelse(Data3<=5,"0-5", ifelse(Data3<=12,"5-12","12+")))
head(AustralianCR.data$Data12)

# creating dependent variable 
AustralianCR.data$Default <- as.factor(ifelse(Data15 == 1, "0", "1"))

is.factor(AustralianCR.data$Default)
contrasts(AustralianCR.data$Default)
head(AustralianCR.data$Default)

# we attach the data again to include the newly created variables
attach(AustralianCR.data)


# A mosaic plot is a graphical display that allows you to examine the relationship among two or more categorical variables. 

mosaicplot(Default ~ Data16, col = T)
mosaicplot(Default ~ Data3, col = T)
mosaicplot(Default ~ Data4, col = T)

# The term spineplot has been applied over the last decade or so to a type of bar chart used particularly for showing frequencies, proportions, or percentages of two cross-classified categorical variables.

spineplot(Default ~ Data6, color = TRUE)
spineplot(Default ~ Data7, color = TRUE)
spineplot(Default ~ Data8, color = TRUE)

# This is the default panel function for xyplot
xyplot(Data2 ~ Data3)

# combine plots
# 4 figures arranged in 2 rows and 2 columns
par(mfrow=c(3,3))
plot(Data2,Data3, main="Scatterplot of Data2 vs. Data2")
plot(Data5,Data6, main="Scatterplot of Data5 vs Data6")
hist(Data7, main="Histogram of Data7")
boxplot(Data9, main="Boxplot of Data9")
plot(Data2,Data11, main="Scatterplot of Data2 vs. Data11")
plot(Data5,Data12, main="Scatterplot of Data5 vs Data12")
spineplot(Default ~ Data6, color = TRUE)
mosaicplot(Default ~ Data4, col = T)
plot(Data5,Data10, main="Scatterplot of Data5 vs Data10")

# Barchar
barchart(Data16, col = "grey")
barchart(Data17, col = "grey")

# Histogram
histogram(Data11, col = "grey")
histogram(Data12, col = "grey")

# Selects 55.5% of this random sample and assigns it to object "d"
d <- sort(sample(nrow(AustralianCR.data), nrow(AustralianCR.data)*0.555))
# the sort command in the beginning just sorts these randomly generated row numbers in an ascending order 

# Development Sample

dev<-AustralianCR.data[d,]
val<-AustralianCR.data[-d,]

# checking Dimentions
dim(AustralianCR.data)
dim(dev)
dim(val) 



##################################
### Logistic Regression Model ####
##################################

##################################
###    Predictive Modelling   ####
##################################

AustCredit.logit <- glm( Default~ 
                          Data1 + 
                          Data2 + 
                          Data3 +
                          Data4 +
                          Data5 +
                          Data6 +
                          Data7 +
                          Data8 +
                          Data9 +
                          Data10 +
                          Data11 +
                          Data12 +
                          Data13 +
                          Data14 +  
                          Data16 +
                          Data17 
                                  , family = binomial(link = "logit"), data = dev)

# The glm command is for "Generalized Linear Models"
# "~" is the separator between the dependent (or target variable) and the independent variables
# Independent variables are separated by the "+" sign
# "data" requires the data frame in the which the variables are stored
# "family" is used to specify the assumed distribution


 # We can check the output of the model as                                 
summary(AustCredit.logit)

# The predict command runs the regression model on the "val" dataset and stores the estimated  y-values, i.e, the yhat.
val$AustCredit.yhat <- predict(AustCredit.logit, val, type = "response")

# Receiver Operating Characteristic (ROC) curve 
## The prediction function of the ROCR library basically creates a structure to validate our predictions, "val$yhat" with respect to the actual y-values "val$default"
AustCredit.scores <- prediction(val$AustCredit.yhat, val$Default)

# We can then plot the ROC curve by plotting the performance fuction which checks how our model is performing.
plot(performance(AustCredit.scores, "tpr", "fpr"), col = "red")
abline(0,1, lty = 8, col = "grey")

# For this let's store the output of the "performance" function above to an R object
AustCredit.perf <- performance(AustCredit.scores, "tpr", "fpr")
ks1.logit <- max(attr(AustCredit.perf, "y.values")[[1]] - (attr(AustCredit.perf, "x.values")[[1]]))
ks1.logit

##################################
###   Recursive partitioning  ####
##################################

##########################################
###    Decision tree with no priors   ####
#########################################

AustCreditT.noprior  <- rpart( Default~ 
                          Data1 + 
                          Data2 + 
                          Data3 +
                          Data4 +
                          Data5 +
                          Data6 +
                          Data7 +
                          Data8 +
                          Data9 +
                          Data10 +
                          Data11 +
                          Data12 +
                          Data13 +
                          Data14 +  
                          Data16 +
                          Data17 
                                  , data = dev)
# Plots the trees
plot(AustCreditT.noprior)
# Adds the labels to the trees.
text(AustCreditT.noprior)

printcp(AustCreditT.noprior)
# Here we see that the value is .

#We can write a small script to find this value
AustCreditT.noprior.cp <- AustCreditT.noprior$cptable[which.min(AustCreditT.noprior$cptable[, "xerror"]), "CP"]
AustCreditT.noprior.prune <- prune(AustCreditT.noprior,AustCreditT.noprior.cp)

#We need to score the pruned tree model the same way we did for the Logistic model.
val$AustCreditT.yhat <- predict(AustCreditT.noprior.prune, val, type = "prob")


# We will also plot the ROC curve for this tree.
AustCreditT.scores <- prediction(val$AustCreditT.yhat[,2], val$Default)
AustCreditT.perf <- performance(AustCreditT.scores, "tpr", "fpr")

# Plot the ROC curve
plot(AustCreditT.perf, col = "green", lwd = 1.5)


# Add the ROC curve of the logistic model and the diagonal line
plot(AustCredit.perf, col = "red", lwd = 1, add = TRUE)
abline(0, 1, lty = 8, col = "grey")
legend("bottomright", legend = c("tree", "logit"), col = c("green", "red"), lwd = c(1.5,1))

#Similarly we can calculate the KS statistic as well
ks1.tree <- max(attr(AustCreditT.perf, "y.values")[[1]] - (attr(AustCreditT.perf, "x.values")[[1]]))
ks1.tree

# AUC for the logistic model
AustCredit.auc <- performance(AustCredit.scores, "auc")
AustCredit.auc

# AUC for the decision tree
AustCreditT.auc <- performance(AustCreditT.scores, "auc")
AustCreditT.auc


#######################################
###    Decision tree with priors   ####
#######################################


AustCreditT.prior  <- rpart( Default~ 
                          Data1 + 
                          Data2 + 
                          Data3 +
                          Data4 +
                          Data5 +
                          Data6 +
                          Data7 +
                          Data8 +
                          Data9 +
                          Data10 +
                          Data11 +
                          Data12 +
                          Data13 +
                          Data14 +  
                          Data16 +
                          Data17 
                                  , data = dev, parms = list(prior = c(0.9, 0.1)))
# Plots the trees
plot(AustCreditT.prior)
# Adds the labels to the trees.
text(AustCreditT.prior)

printcp(AustCreditT.prior)
# Here we see that the value is .


#We don't need to prune this model and can score it right away
val$AustCreditT.p.yhat <- predict(AustCreditT.prior, val, type = "prob")

#We can plot the ROC curve for the tree with priors.
AustCreditT.p.scores <- prediction(val$AustCreditT.p.yhat[,2], val$Default)
AustCreditT.p.perf <- performance(AustCreditT.p.scores, "tpr", "fpr")

# Plot the ROC curve
plot(AustCreditT.p.perf, col = "blue", lwd = 1)

# Add the diagonal line and the ROC curve of the logistic model, ROC curve of the tree without priors
plot(AustCredit.perf, col = "red", lwd = 1, add = TRUE)
plot(AustCreditT.perf, col = "green", lwd = 1.5, add = TRUE)
abline(0, 1, lty = 8, col = "grey")
legend("bottomright", legend = c("tree w/o prior", "tree with prior", "logit"), col = c("green", "blue", "red"), lwd = c(1.5, 1, 1))

#KS statistic
ks1.p.tree <- max(attr(AustCreditT.p.perf, "y.values")[[1]] -(attr(AustCreditT.p.perf, "x.values")[[1]]))
ks1.p.tree

#AUC
t1.p.auc <- performance(AustCreditT.p.scores, "auc")
t1.p.auc 
