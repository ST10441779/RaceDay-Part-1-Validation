# RaceDay REST API Endpoint Plan

**Version:** Part 1  
**Base route:** `/api`  
**Roles:** `Organiser`, `Participant`  
**Public endpoints** are marked `None`; authenticated endpoints are marked `Any`; role-specific endpoints enforce the role at API level in Part 2.

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | `/api/auth/register` | Creates a new participant account. | None | `fullName, email, password, phoneNumber` | **201 Created** – user created; **400 Bad Request** – validation failure; **409 Conflict** – email already exists |
| POST | `/api/auth/login` | Authenticates a user and returns an access token. | None | `email, password` | **200 OK** – token and user details; **400 Bad Request** – invalid body; **401 Unauthorized** – invalid credentials |
| GET | `/api/users/me` | Returns the authenticated user's profile. | Any | None | **200 OK** – profile; **401 Unauthorized** |
| PUT | `/api/users/me` | Updates the authenticated user's profile. | Any | `fullName, phoneNumber` | **200 OK** – updated profile; **400 Bad Request**; **401 Unauthorized** |
| GET | `/api/events` | Lists upcoming events, with optional filters such as type, city and date. | None | None / query parameters | **200 OK** – event list |
| GET | `/api/events/{id}` | Returns one event with its categories and available race information. | None | None | **200 OK** – event; **404 Not Found** |
| POST | `/api/events` | Creates a new road running, walking or cycling event. | Organiser | `eventName, eventType, description, eventDate, startTime, venue, city, province, distanceKM, status` | **201 Created** – event; **400 Bad Request**; **401 Unauthorized**; **403 Forbidden** |
| PUT | `/api/events/{id}` | Updates an event owned/managed by the organiser. | Organiser | Event fields to update | **200 OK** – updated event; **400 Bad Request**; **403 Forbidden**; **404 Not Found** |
| DELETE | `/api/events/{id}` | Deletes an event and its dependent planning data when allowed. | Organiser | None | **204 No Content**; **403 Forbidden**; **404 Not Found**; **409 Conflict** – event has completed/locked records |
| GET | `/api/events/{eventId}/categories` | Lists categories for an event. | None | None | **200 OK** – category list; **404 Not Found** – event |
| POST | `/api/events/{eventId}/categories` | Adds a category to an event. | Organiser | `categoryName, gender, minAge, maxAge, entryFee, capacity` | **201 Created**; **400 Bad Request**; **403 Forbidden**; **404 Not Found**; **409 Conflict** |
| GET | `/api/categories/{id}` | Returns details for a category. | None | None | **200 OK**; **404 Not Found** |
| PUT | `/api/categories/{id}` | Updates an event category. | Organiser | Category fields | **200 OK**; **400 Bad Request**; **403 Forbidden**; **404 Not Found** |
| DELETE | `/api/categories/{id}` | Deletes a category if it has no enrolments. | Organiser | None | **204 No Content**; **403 Forbidden**; **404 Not Found**; **409 Conflict** |
| POST | `/api/events/{eventId}/enrolments` | Enrols the logged-in participant in an event category. | Participant | `categoryId` | **201 Created** – enrolment; **400 Bad Request**; **401 Unauthorized**; **404 Not Found**; **409 Conflict** – already enrolled/full |
| GET | `/api/enrolments/me` | Lists the authenticated participant's event enrolments. | Participant | None | **200 OK** – enrolment list; **401 Unauthorized** |
| GET | `/api/enrolments/{id}` | Returns an enrolment belonging to the authenticated participant. | Participant | None | **200 OK**; **401 Unauthorized**; **403 Forbidden**; **404 Not Found** |
| DELETE | `/api/enrolments/{id}` | Cancels the authenticated participant's enrolment when cancellation is allowed. | Participant | None | **204 No Content**; **401 Unauthorized**; **403 Forbidden**; **404 Not Found**; **409 Conflict** |
| GET | `/api/events/{eventId}/enrolments` | Allows an organiser to view all participants enrolled in an event. | Organiser | None | **200 OK**; **403 Forbidden**; **404 Not Found** |
| POST | `/api/enrolments/{enrolmentId}/results` | Captures an official participant result for an enrolment. | Organiser | `finishTime, positionOverall, status, notes` | **201 Created**; **400 Bad Request**; **403 Forbidden**; **404 Not Found**; **409 Conflict** – result already exists |
| PUT | `/api/results/{id}` | Corrects or updates an official result. | Organiser | `finishTime, positionOverall, status, notes` | **200 OK**; **400 Bad Request**; **403 Forbidden**; **404 Not Found** |
| GET | `/api/results/me` | Returns the authenticated participant's personal performance history. | Participant | None | **200 OK** – results history; **401 Unauthorized** |
| GET | `/api/results/{id}` | Returns one result for an authenticated participant or authorised organiser. | Any | None | **200 OK**; **401 Unauthorized**; **403 Forbidden**; **404 Not Found** |
| GET | `/api/events/{eventId}/results` | Returns results for all participants in an event. | Organiser | None | **200 OK**; **403 Forbidden**; **404 Not Found** |
| GET | `/api/events/{eventId}/route` | Returns the route/map information for an event. | None | None | **200 OK**; **404 Not Found** |
| PUT | `/api/events/{eventId}/route` | Creates or updates route information for an event. | Organiser | `routeName, distanceKM, routeDescription, mapURL, startLocation, finishLocation` | **200 OK**; **400 Bad Request**; **403 Forbidden**; **404 Not Found** |
| GET | `/api/events/{eventId}/weather` | Returns stored/current weather information associated with an event. | None | None | **200 OK**; **404 Not Found** |
