# Scrape Tokyo 2020 medal athletics medals table

# import libraries
from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
pd.set_option('display.max_columns', None)

url = 'https://olympics.com/tokyo-2020/olympic-games/en/results/all-sports/athletes.htm'

chrome_options = Options()
chrome_options.add_argument("--headless")
driver = webdriver.Chrome(options=chrome_options)
data_tab = []

# Open url
driver.get(url)

# Accept coockie popup
accept_button = WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, "//*[@id='onetrust-accept-btn-handler']")))
accept_button.click()

# Scrape first page of the site
html_source = driver.page_source
soup = BeautifulSoup(html_source, "html.parser")
table_tag = soup.select("table")[0]
tab_data = [[item.text for item in row_data.select("tr,td")]
            for row_data in table_tag.select("tr")]

for i in tab_data:
    if len(i) != 0:
        j = [x.strip() for x in i]
        data_tab.append(j)

# Scrape subsequent pages
while True:
    try:
        py_b = WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, "//*[@id='entries-table_next']/a")))
        py_b.click()
        html_source = driver.page_source
        soup = BeautifulSoup(html_source, "html.parser")
        table_tag = soup.select("table")[0]
        tab_data = [[item.text for item in row_data.select("tr,td")]
                    for row_data in table_tag.select("tr")]
        for i in tab_data:
            if len(i) != 0:
                j = [x.strip() for x in i]
                data_tab.append(j)
    except: break
 
tokyo_2020 = pd.DataFrame(data_tab, columns = ["name", "team", "sport"])
tokyo_2020['year'] = int(2020)
driver.quit()

#tokyo_2020.to_csv('tokyo_2020.csv')

