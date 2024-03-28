USE Groep4_DEP1;

-- Dimension tables
CREATE TABLE DimensionTeam (
    TeamKey INT PRIMARY KEY,
    TeamName VARCHAR(255),
	ShortName VARCHAR(255),
    StamNumber INT,
);

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Season INT,
    Playday INT,
	Year INT,
	Month INT,
	Day INT,
	DayOfWeek VARCHAR(255),
	IsWeekend BIT,
	IsHoliday BIT,
);

CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,
    Hour INT,
    Minute INT
);

CREATE TABLE DimensionStandings (
    StandingsDayKey INT PRIMARY KEY,
    DateKey INT,
    Ranking INT,
	TeamKey INT,
    Points INT,
    Wins INT,
    Ties INT,
    Losses INT,
    GoalDifference INT,
	FOREIGN KEY (TeamKey) REFERENCES DimensionTeam(TeamKey),
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey)
);



-- Fact tables
CREATE TABLE FactTableMatch (
    MatchKey INT PRIMARY KEY,
    DateKey INT,
	HomeTeamScore INT,
	AwayTeamScore INT,
	StartUur INT,
	EindUur INT,
    HomeTeamKey INT,
    AwayTeamKey INT,
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (StartUur) REFERENCES DimTime(TimeKey),
	FOREIGN KEY (EindUur) REFERENCES DimTime(TimeKey),
    FOREIGN KEY (HomeTeamKey) REFERENCES DimensionTeam(TeamKey),
    FOREIGN KEY (AwayTeamKey) REFERENCES DimensionTeam(TeamKey)
);

CREATE TABLE DimensionGoal (
    GoalKey INT PRIMARY KEY,
	MatchKey INT,
    GoalTimeRelative INT,
	NewScoreHome INT,
	NewScoreAway INT,
    GoalTeam INT,
	FOREIGN KEY (GoalTeam) REFERENCES DimensionTeam(TeamKey),
    FOREIGN KEY (MatchKey) REFERENCES FactTableMatch(MatchKey)
);

CREATE TABLE FactTableBet (
    BettingKey INT PRIMARY KEY,
    MatchKey INT,
    DateKeyMatch INT,
    TimeKeyMatch INT,
	DateKeyScrape INT,
	TimeKeyScrape INT,
	HomeTeamScore INT,
	AwayTeamScore INT,
	Under_Over_X INT,
    OddsHome DECIMAL(5,2),
    OddsAway DECIMAL(5,2),
    OddsDraw DECIMAL(5,2),
    OddsUnderGoals DECIMAL(5,2),
    OddsOverGoals DECIMAL(5,2),
    FOREIGN KEY (MatchKey) REFERENCES FactTableMatch(MatchKey),
    FOREIGN KEY (DateKeyMatch) REFERENCES DimDate(DateKey),
    FOREIGN KEY (TimeKeyMatch) REFERENCES DimTime(TimeKey)
);