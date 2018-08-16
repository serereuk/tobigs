rm(list = ls())

if(!require(caret)) install.packages("caret"); library(caret)
if(!require(e1071)) install.packages("e1071"); library(e1071)
if(!require(dplyr)) install.packages("dplyr"); library(dplyr)

apt_train <- read.csv('~/Downloads/앙상블-2/train_apt.csv')
apt_test <- read.csv('~/Downloads/앙상블-2/test_apt.csv')

str(apt_train)
remain <- colSums(is.na(apt_train)) < 300
train2 <- apt_train[,remain]
test2 <- apt_test[, c(remain[c(-1,-50)]) ]
train2 <- na.omit(train2)
test2 <- na.omit(test2)
train2$X <- c(1:length(train2$X))
train2$price <- log1p(train2$price)
summary(lm(price ~.-X, data = train2)) # 0.7963

train2[,grep("commute", names(train2))] <- scale(train2[, grep("commute", names(train2))])
test2[,grep("commute", names(test2))] <- scale(test2[,grep("commute", names(test2))])
train2[, c("lat", "lng")] <- scale(train2[, c("lat", "lng")])
test2[, c("lat", "lng")] <- scale(test2[, c("lat", "lng")])
train2[, c("mean_middle_rank", "min_dist_mart", "min_elementary_dist", "park_sum_area", "private_area", "public_area")] <-
  log1p(train2[, c("mean_middle_rank", "min_dist_mart", "min_elementary_dist", "park_sum_area", "private_area", "public_area")])
test2[, c("mean_middle_rank", "min_dist_mart", "min_elementary_dist", "park_sum_area", "private_area", "public_area")] <-
  log1p(test2[, c("mean_middle_rank", "min_dist_mart", "min_elementary_dist", "park_sum_area", "private_area", "public_area")])



summary(lm(price ~.-X, data = train2)) # 0.8212 성능 향상

library(xgboost)
library(caret)
train_ex1 <- createDataPartition(train2$price, p = 0.7, list = F)
train_ex <- train2[train_ex1,]
test_ex <- train2[-train_ex1,]
model1 <- xgboost(data = data.matrix(train_ex[,c(-1, -36)]), label = train_ex$price, nrounds = 200)
cor(train_ex[,36], predict(model1, data.matrix(train_ex[,c(-1, -36)])))
cor(test_ex[,36], predict(model1, data.matrix(test_ex[,c(-1, -36)]))) # 0.96 정도, 약간 오버피팅 된듯하지만 마음에 든다

library(gbm)
model2 <- gbm(price~.-X, data = train_ex, distribution = "gaussian", shrinkage = 0.1, cv.folds = 2, interaction.depth = 3)
best.iter <- gbm.perf(model2, method = "cv")
cor(test_ex[,36], predict(model2, test_ex, best.iter)) # 0.92 정도
summary(model2)

#library(randomForest)
#model3 <- randomForest(price~.-X, data = train_ex) # 시간이 오래걸림 안함

# 결과 
write.csv(exp(predict(model1, data.matrix(test2))), "서석현.csv")
