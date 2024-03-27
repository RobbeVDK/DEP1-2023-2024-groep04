USE Groep4_DEP1;

-- Dimension tables
CREATE TABLE DimensionTeam (
    TeamKey INT PRIMARY KEY,
    TeamName VARCHAR(255),
    StamNumber INT
);

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT
);

CREATE TABLE DimensionTime (
    TimeKey INT PRIMARY KEY,
    Hour INT,
    Minute INT
);

CREATE TABLE DimensionStandings (
    StandingsDayKey INT PRIMARY KEY,
    DateKey INT,
    StandingsPlayday INT,
    StandingsYear INT,
    StamNumber INT,
    Ranking INT,
    Points INT,
    Wins INT,
    Ties INT,
    Losses INT,
    GoalDifference INT
    -- Verwijderd: FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey), om aan ster schema te voldoen
);


CREATE TABLE DimensionGoal (
    GoalKey INT PRIMARY KEY,
    GoalTimeRelative INT,
    ScoreAtGoal INT
    -- Verwijderd: Elke directe FOREIGN KEY, om alleen via FactTableMatch te koppelen
);

-- Fact tables
CREATE TABLE FactTableMatch (
    MatchKey INT PRIMARY KEY,
    DateKey INT,
    TimeKey INT,
    HomeTeamKey INT,
    AwayTeamKey INT,
    GoalKey INT,
    PlayerKey INT, -- Toegevoegd om de speler die gescoord heeft te identificeren
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES DimensionTime(TimeKey),
    FOREIGN KEY (HomeTeamKey) REFERENCES DimensionTeam(TeamKey),
    FOREIGN KEY (AwayTeamKey) REFERENCES DimensionTeam(TeamKey),
    -- Verwijderd: FOREIGN KEY (GoalKey) omdat meerdere goals per match mogelijk zijn; overweeg dit te beheren via een aparte relatie of tabel indien nodig
);

CREATE TABLE FactTableBet (
    BettingKey INT PRIMARY KEY,
    MatchKey INT,
    DateKey INT,
    TimeKey INT,
    OddsHome DECIMAL(5,2),
    OddsAway DECIMAL(5,2),
    OddsDraw DECIMAL(5,2),
    OddsUnderGoals DECIMAL(5,2),
    OddsOverGoals DECIMAL(5,2),
    FOREIGN KEY (MatchKey) REFERENCES FactTableMatch(MatchKey),
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES DimensionTime(TimeKey)
);
