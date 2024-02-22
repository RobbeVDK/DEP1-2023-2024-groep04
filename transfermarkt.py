import requests
from bs4 import BeautifulSoup

url = 'https://www.transfermarkt.be/jupiler-pro-league/spieltagtabelle/wettbewerb/BE1?saison_id=2021&spieltag=1'

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0',
}

response = requests.get(url, headers=headers)
soup = BeautifulSoup(response.content, 'html.parser')

seasons = []
matches = []

for seasonObj in soup.find_all('div', class_='inline-select'):
    for season in seasonObj.find_all('option'):
        if int(season['value']) >= 2023:
            seasons.append(season['value'] if season else None)

for season in seasons:
    days = []
    url = f'https://www.transfermarkt.be/jupiler-pro-league/spieltagtabelle/wettbewerb/BE1/plus/?saison_id={season}&spieltag=1'
    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.text, 'html.parser')
    for dayObj in soup.find_all('div', class_='inline-select'):
        for day in dayObj.find_all('option'):
            if int(day['value']) <= 1000:
                days.append(day['value'] if day else None)

    for day in days:
        url = f'https://www.transfermarkt.be/jupiler-pro-league/spieltagtabelle/wettbewerb/BE1/plus/?saison_id={season}&spieltag={day}'
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')

        matches_table = soup.find('h1').find_next('table')

        last_date = None

        if matches_table.find_all('tr')[1:] is None:
            continue
        for row in matches_table.find_all('tr')[1:]:
            cols = row.find_all('td')
            if not cols:
                continue

            if cols[0].get_text(strip=True):
                last_date = cols[0].get_text(strip=True)
            else:
                last_date = last_date[:-5]

            if len(cols) >= 10:
                time = cols[1].get_text(strip=True)
                home_team = cols[4].get_text(strip=True)
                away_team = cols[9].get_text(strip=True)
                result = cols[6].get_text(strip=True)
                week_day = last_date[:2]
                #for true last_date cut off first 2 char in CSV
                if result == time:
                    result = ''
                if last_date != '' and time != '':
                    matches.append(
                        {'week_day': week_day, 'date': last_date[2:], 'time': time, 'home_team': home_team, 'away_team': away_team,
                         'result': result})


for match in matches:
    print(match)