rm(list = ls())
setwd("~/Downloads") #디렉토리 설정
library(data.table)
forestfire <- fread("forestfires.csv")
library(ggplot2)
library(dplyr)
library(cowplot)
theme_set(theme_grey()) # 그래프 모양 설정용

# 연속형 변수들 히스토그램
n <- names(forestfire)
plots <- apply(forestfire[,c(5:13), with=FALSE], 2,function(x){
  ggplot(forestfire, aes(x))+ geom_freqpoly(binwidth = 5)
  })
for(i in 1:9){
  plots[[i]] <- plots[[i]] + xlab(n[i+4])
}
plot_grid(plotlist = plots)

# 지역별 화재 발생 확인 박스 플롯
plots2 <- lapply(forestfire[,c(1:2), with =FALSE], function(x){
  ggplot(forestfire, aes(factor(x), log1p(area))) + geom_boxplot() + coord_flip() 
})
for(i in 1:2){
  plots2[[i]] <- plots2[[i]] + xlab(n[i])
}
plot_grid(plotlist = plots2)

# 일,월 별 화재 발생 확인 박스 플롯
plots3 <- lapply(forestfire[,c(3,4), with =FALSE], function(x){
  ggplot(forestfire, aes(x, log1p(area))) + geom_boxplot() + coord_flip() 
})
for(i in 1:2){
  plots3[[i]] <- plots3[[i]] + xlab(n[i+2])
}
plot_grid(plotlist = plots3)


# 변수간 상관 관계랑 모두 볼 수 있음 하지만 시간이 조금 걸림
#install.packages("GGally")
library(GGally)
ggpairs(forestfire[,c(-1,-2,-3,-4)])


# 지역 별 데이터 빈도수 확인 -> 많을수록 불이 날 확률도 업
ggplot(forestfire, aes(factor(X),factor(Y))) + geom_count() + scale_size_area()

#화재를 6단계로 나누어서 계산 1이 작은 화재 6은 큰 화재
# 연속형 변수인 area를 카테고리로 잠깐 만들어서 확인
area_cat1<- cut(log1p(forestfire$area), breaks = quantile(log1p(forestfire$area), probs = c(0,seq(0.5, 1, 0.1))),
        include.lowest = TRUE, right = FALSE, labels = 1:6)
data2 <- forestfire %>% mutate(area_cat1 = area_cat1)
#시각화
data2 %>% group_by(X, Y, area_cat1) %>% summarise(n())
ggplot(data2, aes(area_cat1)) + geom_bar() + facet_grid(Y~X)

#화재를 2단계로 나누어서 계산, 0은 화재가 0 1은 0보다 큰 경우
data2 <- data2 %>% mutate(area_cat2 = ifelse(forestfire$area > 5, 1, 0))
data2 %>% group_by(X,Y, area_cat2) %>% summarise(n())
ggplot(data2, aes(factor(area_cat2))) + geom_bar() + facet_grid(Y~X)

#glm 전 계절 처리
data3 <- forestfire
data3 <- data3 %>% mutate(weather = ifelse(month %in% c("feb","jan","dec"), "winter",
                                  ifelse(month %in% c("oct","nov","sep"), "autoumn",
                                         ifelse(month %in% c("aug","jul","jun"), "summer", "spring"))))

data3 <- data3 %>% mutate(weekend = ifelse(day %in% c("mon", "tue", "wed", "thu", "fri"), "week", "weekend"))

data3 <- data3 %>% mutate(area1 = ifelse(area > 5, 1, 0))

data3$weather <- factor(data3$weather, levels = c("spring", "summer", "autoumn", "winter"))
data3$weekend <- factor(data3$weekend, levels = c("week", "weekend"))

data_model1 <- subset(data3, select = c(-month, - day, - area))
data_model2 <- data_model1
data_model2[,c(3:10)] <- scale(data_model1[, c(3:10)])

# 실험 1 scale을 하는게 좋을까? - 안한 친구 부터 확인
index <- createDataPartition(data_model1$area1, p = 0.7, list = FALSE)
train <- data_model1[index, ]; test <- data_model1[-index, ]

#glm model1 saturated model
model1 <- glm(area1 ~., data = train, family = binomial(link = "logit"))
summary(model1)
pred_model1 <- as.numeric(predict(model1, newdata = test, type = "response") > 0.5)#response면 확률 출력
result1 <- confusionMatrix(table(pred_model1, test$area1))$overall[1]

#train, test set divide
library(caret)
index <- createDataPartition(data_model2$area1, p = 0.7, list = FALSE)
train <- data_model2[index, ]; test <- data_model2[-index, ]

#glm model1 saturated model
model2 <- glm(area1 ~., data = train, family = binomial(link = "logit"))
summary(model2)
pred_model2 <- as.numeric(predict(model2, newdata = test, type = "response") > 0.5)#response면 확률 출력
result2 <- confusionMatrix(table(pred_model2, test$area1))$overall[1]

cat("sclae x", result1, "scale o", result2) # scale 쪽이 조금 더 나음

#stepwise 진행
library(caret)
index <- createDataPartition(data_model2$area1, p = 0.7, list = FALSE)
train <- data_model2[index, ]; test <- data_model2[-index, ]

model_full <- glm(area1~., data = train, family = "binomial")
model_non <- glm(area1~1, data = train, family = "binomial")

model_forward <- step(model_non, list(lower=model_non, upper=model_full), direction = "forward")
pred_forward <- as.numeric(predict(model_forward, newdata = test, type = "response") > 0.5)
result1 <- confusionMatrix(table(pred_forward, test$area1))$overall[1]

model_backward <- step(model_full, list(lower=model_non, upper=model_full), direction = "backward")
pred_backward <- as.numeric(predict(model_backward, newdata = test, type = "response") > 0.5)
result2 <- confusionMatrix(table(pred_backward, test$area1))$overall[1]

model_step <- step(model_non, list(lower=model_non, upper=model_full), direction = "both")
pred_step <- as.numeric(predict(model_step, newdata = test, type = "response") > 0.5)
result3 <- confusionMatrix(table(pred_step, test$area1))$overall[1]

cat("forward ", result1, "backward ", result2, "step ", result3)

#svm
library(e1071)
set.seed(12345)
index <- createDataPartition(data_model2$area1, p = 0.7, list = FALSE)
train <- data_model2[index, ]; test <- data_model2[-index, ]

svm.model<-svm(area1~.,data=train, probability=TRUE)
summary(svm.model)
predicted.prob<- as.numeric(predict(svm.model,newdata=test) > 0.5)
confusionMatrix(table(predicted.prob, test$area1))$overall[1] # 0.72 가장 높당

library(kernlab)

svm2.model <- ksvm(area1 ~., data = train, type = "C-svc", kernel = "polydot")
confusionMatrix(table(test$area1, predict(svm2.model, newdata = test))) # 0.70 약간 떨어짐

svm3.model <- ksvm(area1 ~., data = train, type = "C-svc", kernel = "vanilladot")
confusionMatrix(table(test$area1, predict(svm3.model, newdata = test))) # 0.70 약간 떨어짐

svm4.model <- ksvm(area1 ~., data = train, type = "C-svc", kernel = "anovadot")
confusionMatrix(table(test$area1, predict(svm4.model, newdata = test))) # 0.62 약간 떨어짐


#Decision Tree
library(rpart)
set.seed(12345)
index <- createDataPartition(data_model2$area1, p = 0.7, list = FALSE)
train <- data_model2[index, ]; test <- data_model2[-index, ]
rpartmodel1 <- rpart(factor(area1)~., data=train)
rpartmodel1

library(rpart.plot)
prp(rpartmodel1, type=2, digits=3) #rpart전용 plot #Class models: Classification rate (ncorrect/nobservations)

rpart_pred1 <- predict(rpartmodel1, newdata = subset(test, select = c(- area1)), type="class")
confusionMatrix(rpart_pred1, factor(test$area1))

#minsplit,cp 조정
set.seed(12345)
rpartmodel4 <- rpart(factor(area1)~.,data=train,minsplit=6,cp=0.005)
rpartmodel4
prp(rpartmodel4 , type=2, digits=3) #cp값을 낮추니 복잡해짐

rpart_pred4 <- predict(rpartmodel4,subset(test,select=-area1),type="class")
confusionMatrix(rpart_pred4,factor(test$area1))

rpart_pred4_train <- predict(rpartmodel4,subset(train,select=-area1),type="class")
confusionMatrix(rpart_pred4_train,factor(train$area1))
# overfit이 생긴다!

########################################## pruning ##################################################

printcp(rpartmodel4) # == rpartmodel4$cptable
plotcp(rpartmodel4)

rpartmodel4_prune <- prune(rpartmodel4,
                           cp=rpartmodel4$cptable[which.min(rpartmodel4$cptable[,"xerror"])],"CP")
prp(rpartmodel4_prune, type=2, digits=3)
rpart_pred4_prune <- predict(rpartmodel4_prune,subset(test,select=-area1),type="class") #test accuracy
confusionMatrix(rpart_pred4_prune,factor(test$area1))
#accuracy : 0.5677 tree가 간단해졌는데 acc는 올랐다.
rpart_pred4_prune_train <- predict(rpartmodel4_prune,subset(train,select=-area1),type="class") #train accuracy
confusionMatrix(rpart_pred4_prune_train, factor(train$area1))

#xgboost

set.seed(12345)
index <- createDataPartition(data_model2$area1, p = 0.7, list = FALSE)
train <- data_model2[index, ]; test <- data_model2[-index, ]

library(xgboost)
model.xg <- xgboost(data = data.matrix(train[,c(-13)]), label = train[,13], nrounds = 200, objective = "binary:logistic" )
pred <- as.numeric(predict(model.xg, data.matrix(test[,c(-13)])) > 0.5)
confusionMatrix(table(pred, test$area1)) # 0.66 높당

#Random Forest
library(randomForest)
model.rf <- randomForest(factor(area1) ~., data = train, proximity = T)
round(importance(model.rf))
pred.rf <- predict(model.rf, test[,-13])
confusionMatrix(table(pred.rf, test$area1))
