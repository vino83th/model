# Selection Path location
Path = "C:/users/vjayaratnam/Documents/SkyDrive/Vinoth1/Credit Risk/Presentation/australian1.csv"

#loading csv file 
AustralianCR.data<-read.csv(Path)

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


