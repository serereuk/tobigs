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





