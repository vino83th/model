###########================================================###############
#                Data preparation                                        #
###########================================================###############


 ##########----------------1.1: Reading the data------------############### 


#Set the directory to where the german data file is located
setwd("C:/users/vjayaratnam/Documents/SkyDrive/Vinoth1/Credit Risk/Presentation/")

#Read the data by importing the csv file 
g.data <- read.csv("GermanData.csv", header = F)

head(g.data)
names(g.data) <- c("chk_acct", "duration", "history", "purpose", "amount", "sav_acct", "employment", "install_rate", "pstatus", "other_debtor", "time_resid", "property", "age", "other_install", "housing", "other_credits", "job", "num_depend", "telephone", "foreign", "response")
head(g.data)
is.numeric(g.data$property)
is.factor(g.data$property)
is.numeric(g.data$age)
is.double(g.data$amount)
is.numeric(g.data$amount)
