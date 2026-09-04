IF DB_ID(N'RaceDayDB') IS NULL
    CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

-- Re-runnable cleanup for development/testing.
IF OBJECT_ID(N'dbo.Results', N'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID(N'dbo.Enrolments', N'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID(N'dbo.EventRoutes', N'U') IS NOT NULL DROP TABLE dbo.EventRoutes;
IF OBJECT_ID(N'dbo.EventWeather', N'U') IS NOT NULL DROP TABLE dbo.EventWeather;
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID(N'dbo.Events', N'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users (
    UserID          INT IDENTITY(1,1) NOT NULL,
    FullName        NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(255) NOT NULL,
    PasswordHash    NVARCHAR(255) NOT NULL,
    Role            NVARCHAR(20) NOT NULL
        CONSTRAINT CK_Users_Role CHECK (Role IN (N'Organiser', N'Participant')),
    PhoneNumber     NVARCHAR(30) NULL,
    CreatedAt       DATETIME2(0) NOT NULL
        CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
GO

CREATE TABLE dbo.Events (
    EventID         INT IDENTITY(1,1) NOT NULL,
    OrganiserID     INT NOT NULL,
    EventName       NVARCHAR(150) NOT NULL,
    EventType       NVARCHAR(20) NOT NULL
        CONSTRAINT CK_Events_EventType CHECK (EventType IN (N'Running', N'Walking', N'Cycling')),
    Description     NVARCHAR(1000) NULL,
    EventDate       DATE NOT NULL,
    StartTime       TIME(0) NOT NULL,
    Venue           NVARCHAR(200) NOT NULL,
    City            NVARCHAR(100) NOT NULL,
    Province        NVARCHAR(100) NOT NULL,
    DistanceKM      DECIMAL(6,2) NULL
        CONSTRAINT CK_Events_Distance CHECK (DistanceKM IS NULL OR DistanceKM > 0),
    Status          NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Events_Status DEFAULT N'Upcoming'
        CONSTRAINT CK_Events_Status CHECK (Status IN (N'Upcoming', N'Open', N'Closed', N'Completed', N'Cancelled')),
    CreatedAt       DATETIME2(0) NOT NULL
        CONSTRAINT DF_Events_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Events PRIMARY KEY (EventID),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID) REFERENCES dbo.Users(UserID)
);
GO

CREATE TABLE dbo.Categories (
    CategoryID      INT IDENTITY(1,1) NOT NULL,
    EventID         INT NOT NULL,
    CategoryName    NVARCHAR(100) NOT NULL,
    Gender          NVARCHAR(20) NULL
        CONSTRAINT CK_Categories_Gender CHECK (Gender IS NULL OR Gender IN (N'Male', N'Female', N'Mixed', N'Open')),
    MinAge          INT NULL
        CONSTRAINT CK_Categories_MinAge CHECK (MinAge IS NULL OR MinAge >= 0),
    MaxAge          INT NULL
        CONSTRAINT CK_Categories_MaxAge CHECK (MaxAge IS NULL OR MaxAge >= 0),
    EntryFee        DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_Categories_EntryFee DEFAULT 0
        CONSTRAINT CK_Categories_EntryFee CHECK (EntryFee >= 0),
    Capacity        INT NULL
        CONSTRAINT CK_Categories_Capacity CHECK (Capacity IS NULL OR Capacity > 0),
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID),
    CONSTRAINT UQ_Categories_Event_Category UNIQUE (EventID, CategoryID),
    CONSTRAINT UQ_Categories_Event_Name UNIQUE (EventID, CategoryName),
    CONSTRAINT CK_Categories_AgeRange CHECK (
        MaxAge IS NULL OR MinAge IS NULL OR MaxAge >= MinAge
    )
);
GO

CREATE TABLE dbo.Enrolments (
    EnrolmentID        INT IDENTITY(1,1) NOT NULL,
    ParticipantID      INT NOT NULL,
    EventID            INT NOT NULL,
    CategoryID         INT NOT NULL,
    EnrolmentDate      DATETIME2(0) NOT NULL
        CONSTRAINT DF_Enrolments_EnrolmentDate DEFAULT SYSUTCDATETIME(),
    EnrolmentStatus    NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Enrolments_Status DEFAULT N'Confirmed'
        CONSTRAINT CK_Enrolments_Status CHECK (EnrolmentStatus IN (N'Pending', N'Confirmed', N'Cancelled')),
    RaceNumber         INT NULL
        CONSTRAINT CK_Enrolments_RaceNumber CHECK (RaceNumber IS NULL OR RaceNumber > 0),
    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentID),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID),
    CONSTRAINT FK_Enrolments_EventCategory FOREIGN KEY (EventID, CategoryID)
        REFERENCES dbo.Categories(EventID, CategoryID),
    CONSTRAINT UQ_Enrolments_Participant_Event UNIQUE (ParticipantID, EventID)
);
GO

CREATE TABLE dbo.Results (
    ResultID        INT IDENTITY(1,1) NOT NULL,
    EnrolmentID     INT NOT NULL,
    FinishTime      TIME(0) NULL,
    PositionOverall INT NULL
        CONSTRAINT CK_Results_Position CHECK (PositionOverall IS NULL OR PositionOverall > 0),
    Status           NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Results_Status DEFAULT N'Finished'
        CONSTRAINT CK_Results_Status CHECK (Status IN (N'Finished', N'DNF', N'DNS', N'DSQ')),
    RecordedAt      DATETIME2(0) NOT NULL
        CONSTRAINT DF_Results_RecordedAt DEFAULT SYSUTCDATETIME(),
    Notes           NVARCHAR(500) NULL,
    CONSTRAINT PK_Results PRIMARY KEY (ResultID),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES dbo.Enrolments(EnrolmentID),
    CONSTRAINT UQ_Results_Enrolment UNIQUE (EnrolmentID)
);
GO

CREATE TABLE dbo.EventRoutes (
    RouteID         INT IDENTITY(1,1) NOT NULL,
    EventID         INT NOT NULL,
    RouteName       NVARCHAR(150) NOT NULL,
    DistanceKM      DECIMAL(6,2) NOT NULL
        CONSTRAINT CK_EventRoutes_Distance CHECK (DistanceKM > 0),
    RouteDescription NVARCHAR(1000) NULL,
    MapURL          NVARCHAR(500) NULL,
    StartLocation   NVARCHAR(200) NULL,
    FinishLocation  NVARCHAR(200) NULL,
    CONSTRAINT PK_EventRoutes PRIMARY KEY (RouteID),
    CONSTRAINT FK_EventRoutes_Event FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID),
    CONSTRAINT UQ_EventRoutes_Event UNIQUE (EventID)
);
GO

CREATE TABLE dbo.EventWeather (
    WeatherID       INT IDENTITY(1,1) NOT NULL,
    EventID         INT NOT NULL,
    ForecastDate    DATE NOT NULL,
    TemperatureC    DECIMAL(5,2) NULL,
    Conditions      NVARCHAR(100) NULL,
    WindSpeedKmh    DECIMAL(6,2) NULL,
    RainChancePct   DECIMAL(5,2) NULL
        CONSTRAINT CK_EventWeather_RainChance CHECK (RainChancePct IS NULL OR (RainChancePct BETWEEN 0 AND 100)),
    SourceName      NVARCHAR(100) NULL,
    RetrievedAt     DATETIME2(0) NOT NULL
        CONSTRAINT DF_EventWeather_RetrievedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_EventWeather PRIMARY KEY (WeatherID),
    CONSTRAINT FK_EventWeather_Event FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID),
    CONSTRAINT UQ_EventWeather_Event_Date UNIQUE (EventID, ForecastDate)
);
GO

-- Seed users. PasswordHash values are placeholders for Part 1 planning data.
INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, PhoneNumber)
VALUES
(N'Naledi Mokoena', N'organiser@raceday.co.za', N'PART1_HASH_ORGANISER', N'Organiser', N'0825550101'),
(N'Liam Jacobs', N'liam.jacobs@example.com', N'PART1_HASH_LIAM', N'Participant', N'0825550102'),
(N'Zanele Dlamini', N'zanele.dlamini@example.com', N'PART1_HASH_ZANELE', N'Participant', N'0825550103'),
(N'Michael Naidoo', N'michael.naidoo@example.com', N'PART1_HASH_MICHAEL', N'Participant', N'0825550104');
GO

INSERT INTO dbo.Events
    (OrganiserID, EventName, EventType, Description, EventDate, StartTime, Venue, City, Province, DistanceKM, Status)
VALUES
(1, N'Cape Peninsula Road Challenge', N'Running',
 N'A community road running event supporting local charities.',
 '2026-10-18', '07:00', N'Green Point Athletics Track', N'Cape Town', N'Western Cape', 21.10, N'Open'),
(1, N'Johannesburg Family Cycle Ride', N'Cycling',
 N'A family-friendly cycling event for recreational riders.',
 '2026-11-08', '06:30', N'Zoo Lake', N'Johannesburg', N'Gauteng', 20.00, N'Upcoming');
GO

INSERT INTO dbo.Categories
    (EventID, CategoryName, Gender, MinAge, MaxAge, EntryFee, Capacity)
VALUES
(1, N'Half Marathon Open', N'Open', 18, NULL, 250.00, 5000),
(1, N'Half Marathon Junior', N'Open', 16, 17, 150.00, 500),
(2, N'20KM Open Cycle', N'Mixed', 16, NULL, 180.00, 1500),
(2, N'20KM Family Cycle', N'Mixed', 10, NULL, 120.00, 1000);
GO

INSERT INTO dbo.Enrolments
    (ParticipantID, EventID, CategoryID, EnrolmentStatus, RaceNumber)
VALUES
(2, 1, 1, N'Confirmed', 101),
(3, 1, 1, N'Confirmed', 102),
(4, 2, 3, N'Confirmed', 201);
GO

INSERT INTO dbo.Results
    (EnrolmentID, FinishTime, PositionOverall, Status, Notes)
VALUES
(1, '01:48:32', 37, N'Finished', N'Official chip time'),
(2, '02:04:17', 81, N'Finished', N'Official chip time');
GO

INSERT INTO dbo.EventRoutes
    (EventID, RouteName, DistanceKM, RouteDescription, MapURL, StartLocation, FinishLocation)
VALUES
(1, N'Peninsula Half Marathon Route', 21.10,
 N'Road route through selected Cape Town suburbs with marked water points.',
 N'https://example.com/raceday/routes/cape-peninsula-half',
 N'Green Point Athletics Track', N'Green Point Athletics Track'),
(2, N'Zoo Lake Family Cycle Route', 20.00,
 N'Closed-road recreational cycling loop with marshal points.',
 N'https://example.com/raceday/routes/zoo-lake-cycle',
 N'Zoo Lake', N'Zoo Lake');
GO

INSERT INTO dbo.EventWeather
    (EventID, ForecastDate, TemperatureC, Conditions, WindSpeedKmh, RainChancePct, SourceName)
VALUES
(1, '2026-10-18', 17.50, N'Partly cloudy', 18.00, 20.00, N'Weather API placeholder'),
(2, '2026-11-08', 19.00, N'Sunny', 12.00, 10.00, N'Weather API placeholder');
GO

-- Verification queries for the Part 1 demonstration.
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Events;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Enrolments;
SELECT * FROM dbo.Results;
SELECT * FROM dbo.EventRoutes;
SELECT * FROM dbo.EventWeather;
GO
