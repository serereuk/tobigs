######### ?м???��!
rm(list=ls())
### setwd
setwd("~/Downloads/KNN LDA/data")

### packages
if(!require(caret)) install.packages("caret"); library(caret)
if(!require(e1071)) install.packages("e1071"); library(e1071)
if(!require(dplyr)) install.packages("dplyr"); library(dplyr)
if(!require(data.table)) install.packages("data.table"); library(data.table)
if(!require(class)) install.packages("class"); library(class)

#### load data
pro.train <- fread('protrain.txt', encoding = "UTF-8")
pro.train <- as.data.frame(pro.train)
click.train <- fread('clitrain.txt')
click.train <- as.data.frame(click.train)
pro.test <- fread('protest.txt')
pro.test <- as.data.frame(pro.test)
click.test <- fread('clitest.txt')
click.test <- as.data.frame(click.test)
pro.train %>% head
str(pro.train)


#### data preproc
### dplyr package : https://wsyang.com/2014/02/introduction-to-dplyr/
### train data ?????߰? 1. DT
a <-click.train %>% group_by(id) %>% summarise(DT = sum(st_t)) # or aggregate
pro.train <- inner_join(pro.train,a) # or merge
pro.train %>% head

a <-click.test %>% group_by(id) %>% summarise(DT = sum(st_t)) # or aggregate
pro.test <- inner_join(pro.test,a) # or merge

### ?????߰? 2. ~
pro.train <- inner_join(pro.train, click.train %>% group_by(id) %>% summarise(PV = sum(st_c)))
pro.test <- inner_join(pro.test, click.test %>% group_by(id) %>% summarise(PV = sum(st_c)))

pro.train %>% head
### ?????߰? 3. ~
pro.train <- inner_join(pro.train, click.train %>% group_by(id, cate) %>% summarise() %>% group_by(id) %>% summarise(cov = n()/22))
pro.test <- inner_join(pro.test, click.test %>% group_by(id, cate) %>% summarise() %>% group_by(id) %>% summarise(cov = n()/22))
pro.train %>% head
### ?????߰? 4. ~
pro.train <- inner_join(pro.train, click.train %>% group_by(id) %>% summarise(Day = n()))
pro.test <- inner_join(pro.test, click.test %>% group_by(id) %>% summarise(Day = n()))
pro.train %>% head

#### data partition
pro.train <- pro.train[,c(2, 5,6,7,8)]
pro.train$gen <- factor(pro.train$gen, levels = c("????", "????")) 
pro.test <- pro.test[, c(4,5,6,7)]
#### modeling

######### ?м???�� ?ȿ? ?????ִ? ????, Vote classifier
### function ???ڰ??? ????(a,b,c,d,...)?? ??��?? ?߰??ص??˴ϴ?!
### ???? ???̵?????�� ??��???? ?ٲټŵ? ?˴ϴ?.
###  a : ?ӻ????? ?????? ????
###  b,c,d ... : method
### 1. ??��?? ��???? 3???? ???? ?켱!
### 2. ???ư??? ?Ϲ?ȭ ?? ?Ķ????? ����?? ?غ??ô?!
voteClassifier <- function() {
  # ?н? ?κ?, caret??Ű?? ?Լ??? ???ּ???!
  cv <- trainControl(method = "cv", number = 5, verbose = T)
  repCv <- trainControl(method = "repeatedcv", number = 5,repeats = 3, verbose = T)
  library(kknn)
  train.kknn <- kknn(gen ~., pro.train, pro.test, k = 5, scale = F)
  
  train.lda <- train(gen~.,pro.train, method = "lda", trControl = repCv)
  predict.lda <- predict(train.lda,pro.test)
  
  ######### logistic
  train.glm <- train(gen~., pro.train, method = "glm", trControl =cv)
  predict.glm <- predict(train.glm, pro.test)
  
  # ???? ?κ?
  
  # predict count ?κ?
  overall <- cbind(train.kknn$fitted.values, predict.lda, predict.glm)
  pred <- as.numeric(unlist(lapply(lapply(apply(overall, 1, table), which.max), names)))
        # ??�� ?????? ??ȯ
  return(pred)
}
predict.ensemble <- voteClassifier()
confusionMatrix(predict.ensemble, test.set)

#### ??�� ?????? ��??
pred.test <- predict.ensemble
pred.test <- as.data.frame(pred.test)
names(pred.test) <- "gen"
write.csv(pred.test,'??????.csv',row.names =F)
###