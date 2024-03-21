-- Gebruik de database
USE Groep4_DEP1;

-- Creëer de DimensionTeam tabel
CREATE TABLE DimensionTeam (
    teamId INT PRIMARY KEY,
    TeamName VARCHAR(255),
    StamNumber INT
);
-- Creëer de DimDate tabel
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT
);

-- Creëer de FactTableMatch tabel met een verwijzing naar de DimDate tabel
CREATE TABLE FactTableMatch (
    MatchId INT PRIMARY KEY,
    DateKey INT,
    HomeTeam INT,
    AwayTeam INT,
    HomeTeamScore INT,
    AwayTeamScore INT,
    Result VARCHAR(1),
    GoalsScored INT,
    Playday INT,
    SeasonYear INT,
    StartingHour TIME,
    EndingHour TIME,
    FOREIGN KEY (HomeTeam) REFERENCES DimensionTeam(teamId),
    FOREIGN KEY (AwayTeam) REFERENCES DimensionTeam(teamId),
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey)
);

-- Creëer de FactTableBet tabel met een verwijzing naar de DimDate tabel
CREATE TABLE FactTableBet (
    BettingId INT PRIMARY KEY,
    DateKey INT,
    HomeTeam INT,
    AwayTeam INT,
    MatchId INT,
    OddsHome DECIMAL(5,2),
    OddsAway DECIMAL(5,2),
    OddsDraw DECIMAL(5,2),
    OddsUnderGoals DECIMAL(5,2),
    OddsOverGoals DECIMAL(5,2),
    FOREIGN KEY (HomeTeam) REFERENCES DimensionTeam(teamId),
    FOREIGN KEY (AwayTeam) REFERENCES DimensionTeam(teamId),
    FOREIGN KEY (MatchId) REFERENCES FactTableMatch(MatchId),
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey)
);

-- Creëer de DimensionStandings tabel
CREATE TABLE DimensionStandings (
    StandingsDayId INT PRIMARY KEY,
    StandingsPlayday INT,
    StandingsYear INT,
    ClubID INT,
    Ranking INT,
    Points INT,
    Wins INT,
    Ties INT,
    Losses INT,
    GoalDifference INT,
    FOREIGN KEY (ClubID) REFERENCES DimensionTeam(teamId)
);

-- Creëer de DimensionGoal tabel
CREATE TABLE DimensionGoal (
    GoalId INT PRIMARY KEY,
    MatchId INT,
    GoalTimeRelative INT,
    TeamScored INT,
    HomeScore INT,
    AwayScore INT,
    AbsoluteTime TIME,
    FOREIGN KEY (MatchId) REFERENCES FactTableMatch(MatchId),
    FOREIGN KEY (TeamScored) REFERENCES DimensionTeam(teamId)
);

