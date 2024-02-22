import re

import csv

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
ranking_data = []
goals_data = []

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
        rankings_table = soup.find('table', class_='items')

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
                match_id_tag = soup.find('a', href=re.compile(r'/spielbericht/index/spielbericht/'))
                if match_id_tag and match_id_tag['href']:
                    match_id = re.search(r'/spielbericht/index/spielbericht/(\d+)', match_id_tag['href'])
                    if match_id:
                        extracted_id = match_id.group(1)
                # for true last_date cut off first 2 char in CSV
                if result == time:
                    result = ''
                if last_date != '' and time != '':
                    idx_home = home_team.find(')')
                    idx_away = away_team.rfind('(')
                    matches.append(
                        {'date': last_date[2:], 'time': time, 'home_team': home_team[idx_home + 1:],
                         'result_home_team': result[:-2], 'result_away_team': result[2:],
                         'away_team': away_team[:idx_away],
                         'season': season,
                         'day': day,
                         'match_id': extracted_id})

        for row in rankings_table.find_all('tr')[1:]:
            cols = row.find_all('td')

            rank = cols[0].get_text(strip=True).split()[0]
            club_name = cols[2].get_text(strip=True)
            played = cols[3].get_text(strip=True)
            wins = cols[4].get_text(strip=True)
            draws = cols[5].get_text(strip=True)
            losses = cols[6].get_text(strip=True)
            goals = cols[7].get_text(strip=True)
            goal_difference = cols[8].get_text(strip=True)
            points = cols[9].get_text(strip=True)

            ranking_data.append({
                'Rank': rank,
                'Club': club_name,
                'Played': played,
                'Wins': wins,
                'Draws': draws,
                'Losses': losses,
                'Goals': goals,
                'Goal Difference': goal_difference,
                'Points': points,
                'Season': season,
                'Day': day
            })

        url = f'https://www.transfermarkt.be/jupiler-pro-league/spieltag/wettbewerb/BE1/plus/?saison_id={season}&spieltag={day}'
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')

        div = soup.find('div', class_='large-8 columns')

        date = ''
        time = ''
        home_team = ''
        away_team = ''
        result = ''
        goal_team = ''
        goal_time = ''
        for table in div.find_all('table', style='border-top: 0 !important;'):
            for row in table.find_all('tr'):
                if 'class' in row.attrs and 'table-grosse-schrift' in row['class']:
                    home_team = row.find('td', class_='spieltagsansicht-vereinsname').get_text(strip=True)
                    away_team = row.find_all('td', class_='spieltagsansicht-vereinsname')[-1].get_text(strip=True)
                elif 'class' in row.attrs and 'zentriert no-border' in row['class']:
                    td_text = row.get_text(strip=True, separator=' ').replace('uur', '').strip()
                    date, time = td_text.split(' - ')
                elif 'class' in row.attrs and 'no-border spieltagsansicht-aktionen' in row['class']:
                    goal_team = row.find('td', class_='rechts no-border-rechts spieltagsansicht').get_text(strip=True)
                    if goal_team is not None:
                        goal_time = row.find('td', class_='zentriert no-border-links').get_text(strip=True)
                    else:
                        goal_team = row.find('td', class_='links no-border-links spieltagsansicht').get_text(strip=True)
                        goal_time = row.find('td', class_='zentriert no-border-rechts').get_text(strip=True)
                    result = row.find('td', class_='zentriert hauptlink').get_text(strip=True)
                goals_data.append({
                    'date': date,
                    'time': time,
                    'home_team': home_team,
                    'away_team': away_team,
                    'goal_team': goal_team,
                    'goal_time': goal_time,
                    'result_home_team': result[:-2],
                    'result_away_team': result[2:],
                    'Season': season,
                    'Day': day
                })

csv_file = "csv/match_results.csv"
with open(csv_file, 'w', newline='', encoding='utf-8') as file:
    writer = csv.DictWriter(file, fieldnames=['date', 'time', 'home_team', 'result_home_team', 'result_away_team',
                                              'away_team', 'season', 'day', 'match_id'])
    writer.writeheader()
    for match in matches:
        writer.writerow(match)

print(f"Data written to {csv_file}")

csv_file = "csv/standings.csv"
with open(csv_file, 'w', newline='', encoding='utf-8') as file:
    writer = csv.DictWriter(file, fieldnames=['Rank', 'Club', 'Played', 'Wins', 'Draws',
                                              'Losses', 'Goals', 'Goal Difference', 'Points', 'Season', 'Day'])
    writer.writeheader()
    for ranking in ranking_data:
        writer.writerow(ranking)

print(f"Data written to {csv_file}")