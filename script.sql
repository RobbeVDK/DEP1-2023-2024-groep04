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
    Season INT,
    Playday INT,
);

CREATE TABLE DimensionTime (
    TimeKey INT PRIMARY KEY,
    Hour INT,
    Minute INT
);

CREATE TABLE DimensionStandings (
    StandingsDayKey INT PRIMARY KEY,
    DateKey INT,
    StamNumber INT,
    Ranking INT,
    Points INT,
    Wins INT,
    Ties INT,
    Losses INT,
    GoalDifference INT,
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey)
);



-- Fact tables
CREATE TABLE FactTableMatch (
    MatchKey INT PRIMARY KEY,
    DateKey INT,
    TimeKey INT,
    HomeTeamKey INT,
    AwayTeamKey INT,
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES DimensionTime(TimeKey),
    FOREIGN KEY (HomeTeamKey) REFERENCES DimensionTeam(TeamKey),
    FOREIGN KEY (AwayTeamKey) REFERENCES DimensionTeam(TeamKey)
);

CREATE TABLE DimensionGoal (
    GoalKey INT PRIMARY KEY,
    MatchKey INT,
    GoalTimeRelative INT,
    IsHomeTeamGoal BIT,
    FOREIGN KEY (MatchKey) REFERENCES FactTableMatch(MatchKey)
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