###########================================================###############
#                Data preparation                                        #
###########================================================###############


 ##########----------------1.1: Reading the data------------############### 


#Set the directory to where the german data file is located
setwd("D:/Softwares/R/Training/")

#Read the data by importing the csv file 
g.data <- read.csv("german.data.csv", header = F)
