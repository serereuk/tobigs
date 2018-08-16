from bs4 import BeautifulSoup
from selenium import webdriver
import os, time

class crawler():
    def __init__(self):
        self.path = str(os.getcwd()) + str("/chromedriver-2")

        self.result = []

    def twitter(self, keyword, startdate, finishdate):
        driver = webdriver.Chrome(self.path)
        time.sleep(1)
        try:
            page = "https://twitter.com/search?q="+str(keyword)+"%20since%3A"+str(
                startdate)+"%20until%3A"+str(finishdate)+"&src=typd"
            driver.get(page)
            pages = driver.page_source
            bs = BeautifulSoup(pages, "html.parser")
            height = driver.execute_script("return document.body.scrollHeight")
            time.sleep(2)

            while True:
                tweets = bs.find_all("p", {"class": "TweetTextSize"})
                for a in tweets:
                    self.result.append(a.text)
                newheight = driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
                time.sleep(1)
                if height != newheight:
                    pages = driver.page_source
                    bs = BeautifulSoup(pages, "html.parser")
                    height = driver.execute_script("return document.body.scrollHeight")
                    tweets = bs.find_all("p", {"class": "TweetTextSize"})
                    for a in tweets:
                        self.result.append(a.text)
                else:
                    print("끝")
                    break
                height = newheight

        except Exception as err:
            print(err)

        return self.result


# 문제점 결측치 처리에 관심을 가지다가 텍스트 문맥에서 빈칸을 채우면 어떤 성능을 보일까 갑자기 궁금해짐
# 해결책 Bi-lstm 모델에 GAN 모델을 합쳐서 빈칸을 생성하고 판별할 예정
# 모델 결과물: 텝스 빈칸 문제 해결용도 가능할듯, 문장을 써놓고 적절한 단어가 떠오르지 않을때 추천하는 시스템도 괜찮을듯
# 코드 설명:
    #트위터 친구들은 구어체를 잘 사용하는 친구들이다. 나중에 챗봇이랑 연결하면 좋겠다는 생각이 갑자기 들어서 트위터로 선정
    #문학 작품은 저작권 때문에 약간 눈물을 흘려야할 수 가 있기에 저작권 끝난 문학작품을 크롤링해도 좋을듯
    #코드 원리는 자기가 원하는 키워드랑 시작날짜랑 끝날짜를 설정하면 그 기간 내에 키워드와 관련된 모든 트윗내용을 크롤링해옴
    #csv는 나중에 올리겠습니당



