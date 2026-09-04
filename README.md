# RaceDay — Portfolio of Evidence Part 1

## 1. System Overview

RaceDay is a full-stack web-based event management platform designed for the South African road running, walking and cycling community.

The planned system allows event organisers to create and manage sporting events, categories, enrolments and participant results. Participants can register and log in, browse upcoming events, enter an event by selecting a category, view their enrolments, track personal performance history, and access route and weather information for race-day preparation.

Part 1 focuses on planning and database design. No API application code is included in this part.

## 2. User Roles

### Organiser
Organisers can:
- Create, edit and delete events.
- Create, edit and delete event categories.
- View all enrolments for their events.
- Capture and update participant results.
- Maintain route information.

### Participant
Participants can:
- Create an account and log in.
- Browse upcoming events.
- Select a category and enrol in an event.
- View their own enrolments.
- View their personal results/performance history.
- View event route and weather information.

Role-based access is planned at the API level for Part 2 and will be reflected consistently in the MVC application in Part 3.

## 3. Repository Structure

```text
RaceDay/
├── .github/
│   └── workflows/
│       └── part1-validation.yml
├── docs/
│   ├── RaceDay_ERD.png
│   ├── RaceDay_ERD.pdf
│   ├── RaceDay_ERD.dot
│   ├── RaceDay_API_Endpoint_Plan.md
│   └── RaceDay_Database.sql
└── README.md
```

## 4. Part 1 Documents

- **ERD:** `docs/RaceDay_ERD.png` or `docs/RaceDay_ERD.pdf`
- **API Endpoint Plan:** `docs/RaceDay_API_Endpoint_Plan.md`
- **SQL Database Script:** `docs/RaceDay_Database.sql`

The SQL schema was designed to match the ERD. The seven entities are Users, Events, Categories, Enrolments, Results, EventRoutes and EventWeather.

## 5. Database Design Summary

The database uses SQL Server.

Key relationships include:
- One Organiser can manage many Events.
- One Event has many Categories.
- One Participant can have many Enrolments.
- One Event can have many Enrolments.
- One Category can be selected by many Enrolments.
- One Enrolment has zero or one Result.
- One Event has zero or one Route.
- One Event can have many Weather forecast records.

A composite foreign key `(EventID, CategoryID)` in `Enrolments` ensures that a participant cannot enrol in a category belonging to a different event.

## 6. Running the SQL Script

1. Open SQL Server Management Studio (SSMS).
2. Connect to a local SQL Server instance.
3. Open `docs/RaceDay_Database.sql`.
4. Execute the script.
5. The script creates `RaceDayDB`, creates all tables, adds constraints and inserts sample data.
6. The final SELECT statements can be used to verify the seeded records.

> For Part 1, password hashes and weather source values are demonstration/seed values. Real authentication and live weather integration are implemented in later parts.

## 7. CI/CD

GitHub Actions validates that:
- The `docs` folder exists.
- The ERD PNG and PDF exist.
- The API endpoint plan exists.
- The SQL script exists.
- The README is present and non-empty.

### Successful CI/CD Build Screenshot

**Replace the placeholder below with a screenshot of the green GitHub Actions run before submission.**

`[INSERT SCREENSHOT OF GREEN BUILD HERE]`

## 8. Video Presentation

**Unlisted YouTube video:**  
`[PASTE YOUR UNLISTED YOUTUBE LINK HERE]`

The video should explain:
1. The RaceDay problem and system purpose.
2. The two user roles.
3. The ERD and relationship/cardinality decisions.
4. The API endpoint plan and role requirements.
5. The SQL database design and constraints.
6. A live execution of `RaceDay_Database.sql` in SSMS.
7. The successful GitHub Actions validation.

## 9. Part 1 Commit History

A minimum of 20 meaningful commits is required. Commit history should show genuine progression rather than artificial changes. A suggested progression is documented in `docs/Part1_Commit_Plan.md`.
