USE RaceDayDB;

-- Table 1 Users
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    PhoneNumber NVARCHAR(20) NULL,
    ClubName NVARCHAR(100) NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Table 2 Events
CREATE TABLE Events (
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId INT NOT NULL,
    Title NVARCHAR(150) NOT NULL,
    EventType NVARCHAR(30) NOT NULL CHECK (EventType IN ('Running', 'Cycling', 'Walking', 'Multi-Sport')),
    EventDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    Location NVARCHAR(150) NOT NULL,
    Province NVARCHAR(50) NOT NULL CHECK (Province IN ('Gauteng', 'Western Cape', 'KwaZulu-Natal', 'Eastern Cape', 'Free State', 'Mpumalanga', 'Limpopo', 'North West', 'Northern Cape')),
    Description NVARCHAR(MAX) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Upcoming' CHECK (Status IN ('Upcoming', 'Ongoing', 'Completed', 'Cancelled')),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- Table 3 Routes 
CREATE TABLE Routes (
    RouteId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    RouteName NVARCHAR(100) NOT NULL,
    StartingPoint NVARCHAR(150) NOT NULL,
    FinishingPoint NVARCHAR(150) NOT NULL,
    ElevationGainMeters INT NOT NULL DEFAULT 0,
    GpxFileUrl NVARCHAR(255) NULL,
    WeatherLocationQuery NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Routes_Events FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE
);

-- Table 4 Categories
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    DistanceKm DECIMAL(5,2) NOT NULL CHECK (DistanceKm > 0),
    EntryFee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    MaxParticipants INT NOT NULL CHECK (MaxParticipants > 0),
    CutoffTime TIME NOT NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE
);

-- Table 5 EventEnrolments
CREATE TABLE EventEnrolments (
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId INT NOT NULL,
    ParticipantId INT NOT NULL,
    RaceNumber INT NOT NULL,
    EnrolmentDate DATETIME2 DEFAULT GETUTCDATE(),
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'Paid' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Refunded')),
    EmergencyContact NVARCHAR(100) NOT NULL,
    MedicalAidNumber NVARCHAR(50) NULL,
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId) REFERENCES Users(UserId),
    CONSTRAINT UQ_Category_Participant UNIQUE (CategoryId, ParticipantId),
    CONSTRAINT UQ_Category_RaceNumber UNIQUE (CategoryId, RaceNumber)
);

-- Table 6 Results
CREATE TABLE Results (
    ResultId INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId INT NOT NULL UNIQUE,
    GunTime TIME(0) NULL,
    ChipTime TIME(0) NULL,
    OverallPosition INT NULL,
    CategoryPosition INT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Finished' CHECK (Status IN ('Finished', 'DNF', 'DNS', 'Disqualified')),
    RecordedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Results_EventEnrolments FOREIGN KEY (EnrolmentId) REFERENCES EventEnrolments(EnrolmentId) ON DELETE CASCADE
);

-- DATA 1: Users
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Role, PhoneNumber, ClubName)
VALUES 
('Sipho', 'Dlamini', 'sipho.organiser@raceday.co.za', 'AQAAAAEAACcQAAAAEJ379kLp1024...', 'Organiser', '+27 82 111 2233', 'Central Gauteng Athletics'),
('Anika', 'Van Der Merwe', 'anika.events@raceday.co.za', 'AQAAAAEAACcQAAAAEM891mXz5678...', 'Organiser', '+27 83 444 5566', 'Western Province Athletics'),
('Karabo', 'Mokoena', 'karabo.runner@gmail.com', 'AQAAAAEAACcQAAAAEN332aBc9012...', 'Participant', '+27 71 555 7788', 'Soweto AC'),
('Liam', 'Naidoo', 'liam.cyclist@gmail.com', 'AQAAAAEAACcQAAAAEP443bCd3456...', 'Participant', '+27 79 222 3344', 'Durban North Runners'),
('Nomvula', 'Khumalo', 'nomvula.k@gmail.com', 'AQAAAAEAACcQAAAAEQ554cDe7890...', 'Participant', '+27 84 999 1122', 'Team Vitality');

-- DATA 2: Events
INSERT INTO Events (OrganiserId, Title, EventType, EventDate, StartTime, Location, Province, Description, Status)
VALUES 
(1, 'Soweto Marathon 2026', 'Running', '2026-11-01', '05:30:00', 'FNB Stadium, Nasrec', 'Gauteng', 'The Peoples Race passing through iconic historical heritage sites across Soweto.', 'Upcoming'),
(2, 'Cape Town Cycle Tour 2027', 'Cycling', '2027-03-14', '06:00:00', 'Grand Parade, Cape Town', 'Western Cape', 'The worlds largest timed cycle race along the scenic Cape Peninsula.', 'Upcoming'),
(1, 'Durban Promenade Summer 10K', 'Running', '2026-12-06', '06:30:00', 'Suncoast Casino, Durban', 'KwaZulu-Natal', 'Fast and flat seaside road race along the Golden Mile.', 'Upcoming');

-- DATA 3: Routes
INSERT INTO Routes (EventId, RouteName, StartingPoint, FinishingPoint, ElevationGainMeters, WeatherLocationQuery)
VALUES 
(1, 'Soweto Standard Loop', 'FNB Stadium Gate M', 'FNB Stadium Main Field', 420, 'Nasrec, Johannesburg'),
(2, 'Cape Peninsula Classic', 'Grand Parade', 'Green Point Precinct', 1240, 'Cape Town, Western Cape'),
(3, 'Golden Mile Coastal Strip', 'Suncoast Amphitheatre', 'uShaka Marine World Promenade', 45, 'Durban, KwaZulu-Natal');

-- DATA 4: Categories per Event
INSERT INTO Categories (EventId, CategoryName, DistanceKm, EntryFee, MaxParticipants, CutoffTime)
VALUES 
-- Soweto Marathon Categories
(1, 'Full Marathon', 42.20, 380.00, 10000, '06:00:00'),
(1, 'Half Marathon', 21.10, 270.00, 12000, '03:30:00'),
(1, '10km Peace Run', 10.00, 180.00, 8000, '02:00:00'),
-- Cape Town Cycle Tour Categories
(2, 'Classic 109km', 109.00, 650.00, 30000, '07:00:00'),
(2, 'Short 42km', 42.00, 420.00, 5000, '04:00:00'),
-- Durban Promenade Categories
(3, 'Open 10km Run', 10.00, 150.00, 3000, '02:00:00');

-- DATA 5: Event Enrolments
INSERT INTO EventEnrolments (CategoryId, ParticipantId, RaceNumber, PaymentStatus, EmergencyContact, MedicalAidNumber)
VALUES 
(1, 3, 1042, 'Paid', 'Themba Mokoena (+27 82 333 4444)', 'Discovery Classic 90281234'),
(2, 4, 5501, 'Paid', 'Priya Naidoo (+27 83 777 8899)', 'Momentum Health 10928374'),
(3, 5, 8812, 'Paid', 'Bongani Khumalo (+27 72 111 3322)', 'Bonitas Primary 55492811'),
(4, 3, 3021, 'Paid', 'Themba Mokoena (+27 82 333 4444)', 'Discovery Classic 90281234'),
(6, 4, 1004, 'Paid', 'Priya Naidoo (+27 83 777 8899)', 'Momentum Health 10928374');

-- DATA 6: Results
INSERT INTO Results (EnrolmentId, GunTime, ChipTime, OverallPosition, CategoryPosition, Status)
VALUES 
(1, '03:42:15', '03:41:50', 421, 88, 'Finished'),
(2, '01:38:20', '01:38:05', 114, 23, 'Finished'),
(3, '00:49:10', '00:48:55', 78, 12, 'Finished');

SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Routes;
SELECT * FROM Categories;
SELECT * FROM EventEnrolments;
SELECT * FROM Results;