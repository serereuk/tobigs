import pandas as pd
import os
import numpy as np
os.chdir("/Users/Wook-Young/Downloads/NaiveBayes")
train = pd.read_csv("train.csv")

from sklearn.naive_bayes import GaussianNB
from sklearn.model_selection import KFold
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import train_test_split

train2 = train.loc[:,["Survived", "Pclass", "Age", "Fare"]]
train2["family"] = np.sum(train.loc[:,["SibSp", "Parch"]], axis = 1)
train2[["Embarked"]] = train[["Embarked"]].apply(lambda x: pd.factorize(x)[0])
train2[["Sex"]] = train[["Sex"]].apply(lambda x: pd.factorize(x)[0])

temp = train2.describe()

train2.isnull().sum() # 결측치 존재

train3 = train2.dropna(how = "any") # 결측치 모두 제거시 실험용
X = train3.loc[:, ["Pclass", "Sex", "Age", "Fare", "Embarked", "family"]]
y = train3.loc[:, ["Survived"]]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.33, random_state = 42)
nb = GaussianNB()
nb.fit(X_train, y_train.values.reshape(len(y_train),))
pred = nb.predict(X_test)
scores = nb.score(X_test, y_test)
