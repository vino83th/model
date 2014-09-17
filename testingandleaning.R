data<-read.csv("C:/users/vjayaratnam/Documents/SkyDrive/Vinoth1/Credit Risk/Presentation/GermanData.csv")
head(data)
names(data) <- c("chk_acct", "duration", "history", "purpose", "amount", "sav_acct", "employment", "install_rate", "pstatus", "other_debtor", "time_resid", "property", "age", "other_install", "housing", "other_credits", "job", "num_depend", "telephone", "foreign", "response")
head(data)
is.numeric(g.data$property)
is.factor(g.data$property)
is.numeric(g.data$age)
is.double(g.data$amount)
is.numeric(g.data$amount)
str(data)
attach(data)
head(amount)
# Plot
plot(amount, type = "l", col = "royalblue")
plot(age, type = "l", col = "brown")
# Histogram
hist(amount)
hist(age)

data$amt.fac <- as.factor(ifelse(amount <= 2500, "0-2500", 
                                  ifelse(amount <= 5000, "2600-5000", "5000+")))
head(data$amt.fac)

data$age.fac <- as.factor(ifelse(age<=30, '0-30', ifelse(age <= 40, '30-40', '40+')))
head(data$age.fac)

data$default <- as.factor(ifelse(response == 1, "0", "1"))
is.factor(data$default)
contrasts(data$default)
head(data$default)

attach(data)

mosaicplot(default ~ age.fac, col = T)
mosaicplot(default ~ job, col = T)
mosaicplot(default ~ chk_acct, col = T)

spineplot(default ~ age.fac)

library(lattice)
xyplot(amount ~ age)

install.packages("lattice")


xyplot(amount ~ age | default)


barchart(age.fac, col = "grey")
barchart(amt.fac, col = "grey")

histogram(employment, col = "grey")
histogram(sav_acct, col = "grey")

dev<-data[d,]
val<-data[-d,]

dim(data)
dim(dev)
dim(val) 

m1.logit <- glm(default ~ 
                          amt.fac + 
                          age.fac + 
                          duration +
                          chk_acct +
                          history +
                          purpose +
                          sav_acct +
                          employment +
                          install_rate + 
                          pstatus +
                          other_debtor +
                          time_resid +
                          property +
                          other_install + 
                          housing +
                          other_credits +
                          job +
                          num_depend + 
                          telephone + 
                          foreign
                                  , family = binomial(link = "logit"), data = dev)


summary(m1.logit)

val$m1.yhat <- predict(m1.logit, val, type = "response")

library(ROCR)
m1.scores <- prediction(val$m1.yhat, val$default)

plot(performance(m1.scores, "tpr", "fpr"), col = "red")
abline(0,1, lty = 8, col = "grey")

m1.perf <- performance(m1.scores, "tpr", "fpr")
ks1.logit <- max(attr(m1.perf, "y.values")[[1]] - (attr(m1.perf, "x.values")[[1]]))
ks1.logit



library(rpart)

t1.noprior <- rpart(default ~ 
                          amt.fac + 
                          age.fac + 
                          duration +
                          chk_acct +
                          history +
                          purpose +
                          sav_acct +
                          employment +
                          install_rate + 
                          pstatus +
                          other_debtor +
                          time_resid +
                          property +
                          other_install + 
                          housing +
                          other_credits +
                          job +
                          num_depend + 
                          telephone + 
                          foreign
                                , data = dev)
plot(t1.noprior)

text(t1.noprior)

printcp(t1.noprior)

t1.noprior.cp <- t1.noprior$cptable[which.min(t1.noprior$cptable[, "xerror"]), "CP"]
t1.noprior.prune <- prune(t1.noprior,t1.noprior.cp)

val$t1.yhat <- predict(t1.noprior.prune, val, type = "prob")

t1.scores <- prediction(val$t1.yhat[,2], val$default)
t1.perf <- performance(t1.scores, "tpr", "fpr")

plot(t1.perf, col = "green", lwd = 1.5)


plot(m1.perf, col = "red", lwd = 1, add = TRUE)
abline(0, 1, lty = 8, col = "grey")
legend("bottomright", legend = c("tree", "logit"), col = c("green", "red"), lwd = c(1.5,1))


ks1.tree <- max(attr(t1.perf, "y.values")[[1]] - (attr(t1.perf, "x.values")[[1]]))
ks1.tree


# AUC for the logistic model
m1.auc <- performance(m1.scores, "auc")
m1.auc

# AUC for the decision tree
t1.auc <- performance(t1.scores, "auc")
t1.auc


t1.prior <- rpart(default ~ 
                          amt.fac + 
                          age.fac + 
                          duration +
                          chk_acct +
                          history +
                          purpose +
                          sav_acct +
                          employment +
                          install_rate + 
                          pstatus +
                          other_debtor +
                          time_resid +
                          property +
                          other_install + 
                          housing +
                          other_credits +
                          job +
                          num_depend + 
                          telephone + 
                          foreign
                                , data = dev, parms = list(prior = c(0.9, 0.1)))


plot(t1.prior)

text(t1.prior)

val$t1.p.yhat <- predict(t1.prior, val, type = "prob")


t1.p.scores <- prediction(val$t1.p.yhat[,2], val$default)
t1.p.perf <- performance(t1.p.scores, "tpr", "fpr")

# Plot the ROC curve
plot(t1.p.perf, col = "blue", lwd = 1)

# Add the diagonal line and the ROC curve of the logistic model, ROC curve of the tree without priors
plot(m1.perf, col = "red", lwd = 1, add = TRUE)
plot(t1.perf, col = "green", lwd = 1.5, add = TRUE)
abline(0, 1, lty = 8, col = "grey")
legend("bottomright", legend = c("tree w/o prior", "tree with prior", "logit"), col = c("green", "blue", "red"), lwd = c(1.5, 1, 1))

#KS statistic
ks1.p.tree <- max(attr(t1.p.perf, "y.values")[[1]] -(attr(t1.p.perf, "x.values")[[1]]))
ks1.p.tree

#AUC
t1.p.auc <- performance(t1.p.scores, "auc")
t1.p.auc 
