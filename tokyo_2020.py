# Scrape Tokyo 2020 medal athletics medals table

# import libraries
from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd

url = 'https://olympics.com/tokyo-2020/olympic-games/en/results/athletics/medal-standings.htm'

#Initialize storage
data_tab = []
driver = webdriver.Chrome()
page_source = driver.get(url)
html_source = driver.page_source
soup = BeautifulSoup(html_source, "html.parser")
table_tag=soup.select("table")[0]
tab_data=[[item.text for item in row_data.select("tr,td")]
          for row_data in table_tag.select("tr")]
tab_data = tab_data[1:]

data_tab = []
for i in tab_data:
    j = [x.strip() for x in i]
    data_tab.append(j)
tokyo_2020 = pd.DataFrame(data_tab, columns = ["rank", "team", "Gold", "Silver", "Bronze", "total", "Rank_total", "Country"])
tokyo_2020 = tokyo_2020.drop(['rank', 'Gold', "Silver", "Bronze", "Rank_total", "Country"], axis = 1)
tokyo_2020['year'] = 2020
tokyo_2020["total"] = tokyo_2020["total"].astype(str).astype(int)
