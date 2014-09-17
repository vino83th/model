###########================================================###############
#                Data preparation                                        #
###########================================================###############


 ##########----------------1.1: Reading the data------------############### 


#Set the directory to where the german data file is located
setwd("C:/users/vjayaratnam/Documents/SkyDrive/Vinoth1/Credit Risk/Presentation/")

#Read the data by importing the csv file 
g.data <- read.csv("GermanData.csv", header = F)

# install packages
install.packages("lattice")
install.packages("ROCR")
install.packages("rpart")

# load library
library(lattice)
library(ROCR)
library(rpart)

##############################
### Data Cleaning process ####
##############################

#check the header
head(g.data)

names(g.data) <- c("chk_acct", "duration", "history", "purpose", "amount", "sav_acct", "employment", "install_rate", "pstatus", "other_debtor", "time_resid", "property", "age", "other_install", "housing", "other_credits", "job", "num_depend", "telephone", "foreign", "response")
head(g.data)

# check the data chars
is.numeric(g.data$property)
is.factor(g.data$property)
is.numeric(g.data$age)
is.double(g.data$amount)
is.numeric(g.data$amount)

# String will compeactly display the structure of any R object
str(g.data)

#additionally, to make the code more legible and easier to write, we can attach the object 
attach(g.data)

# Plot the datas and check arributes 
# Plot
par(mfrow=c(5,5))
plot(chk_acct, type = "l", col = "royalblue")
plot(duration, type = "1", col = "brown")
plot(history, type = "l", col = "royalblue")
plot(purpose, type = "l", col = "brown")
plot(amount, type = "l", col = "royalblue")
plot(sav_acct, type = "l", col = "brown")
plot(employment, type = "l", col = "royalblue")
plot(install_rate, type = "l", col = "brown")
plot(pstatus, type = "l", col = "royalblue")
plot(other_debtor, type = "l", col = "brown")
plot(time_resid, type = "l", col = "royalblue")
plot(property, type = "l", col = "brown")
plot(age, type = "l", col = "royalblue")
plot(other_install, type = "l", col = "brown")
plot(housing, type = "l", col = "royalblue")
plot(other_credits, type = "l", col = "brown")
plot(job, type = "l", col = "royalblue")
plot(num_depend, type = "l", col = "brown")
plot(telephone, type = "l", col = "royalblue")
plot(foreign, type = "l", col = "brown")
plot(response, type = "l", col = "royalblue")


# histogram
par(mfrow=c(5,5))
histogram(chk_acct)
histogram(duration)
histogram(history)
histogram(purpose)
histogram(amount)
histogram(sav_acct)
histogram(employment)
histogram(install_rate)
histogram(pstatus)
histogram(other_debtor)
histogram(time_resid)
histogram(property)
histogram(age)
histogram(other_install)
histogram(housing)
histogram(other_credits)
histogram(job)
histogram(num_depend)
histogram(telephone)
histogram(foreign)
histogram(response)
