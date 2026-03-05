# 🏡 Homely – Real Estate SaaS Platform

Homely is a **real estate SaaS platform** developed as a **final-year project** at the Higher School of Technology Meknes.
It allows users to browse and list properties, communicate via chat, boost listings, and enables administrators to monitor and manage the platform.

---

## 👥 Team & Roles

This project is developed by **3 students**, each responsible for a major part of the system:

| Member                | Responsibility                           |
| ----------------------| ---------------------------------------- |
| Bennani Bader         | Backend – Spring Boot & PostgreSQL       |
| El Amraoui Mohammed   | Mobile App – Flutter (Clients & Sellers) |
| Bichou Farouk         | Admin Dashboard – React                  |

All parts communicate through a **central REST API**.

---

## 🧱 Global Architecture

The application follows a **3-tier architecture**:

```
[ Flutter Mobile App ]        [ React Admin Dashboard ]
          |                               |
          |        REST API (JSON)        |
          +----------> Spring Boot <-----+
                           |
                       PostgreSQL
```

### Architecture Explanation

* **Flutter**: Mobile application for clients and sellers
* **React**: Web dashboard for administrators
* **Spring Boot**: Backend REST API (business logic & security)
* **PostgreSQL**: Relational database
* **JWT Authentication**: Secures all API communication

---

## 📂 Project Structure

The repository is organized as follows:

```
homely/
 ├── backend/        # Spring Boot application -  Bennani Bader
 ├── mobile/         # Flutter mobile app - El Amraoui Mohammed 
 ├── modelization    # Application modelization    
 ├── web/            # React admin dashboard - Bichou Farouk       
 └── README.md
```

Each part is developed **independently** but follows the same API contract.

---

## ⚙️ Technologies Used

### Backend

* Java 25
* Spring Boot
* Spring Security (JWT)
* Spring Data JPA
* PostgreSQL

### Mobile App

* Flutter
* Dart
* REST API (HTTP)
* Secure Storage (JWT)

### Admin Dashboard

* React
* Axios
* REST API
* JWT Authentication

---

## 🔐 Authentication & Security

We use **JWT (JSON Web Token)** authentication.

### Authentication Flow:

1. User logs in (Flutter or React)
2. Backend returns a JWT
3. Token is stored on the client
4. Token is sent in every request:

```
Authorization: Bearer <JWT_TOKEN>
```

### User Roles:

* **CLIENT**: Browse & search properties, chat with sellers , request property visits, send feedbacks
* **SELLER**: List properties, upload media, boost listings
* **ADMIN**: Monitor platform, manage users, review reports

Access is controlled on the backend using **Spring Security & roles**.

---

## 🔗 API Communication

* All communication is done via **REST APIs**
* Data format: **JSON**
* Flutter and React **never access the database directly**
* Only Spring Boot interacts with PostgreSQL

Example endpoint:

```
GET /api/properties
POST /api/properties
GET /api/admin/reports
```

---

## 🗃️ Database

* Database: **PostgreSQL**
* ORM: **JPA / Hibernate**
* Entities include:

  * User
  * Property(apartment,house,villa,studio,land,commercial)
  * Media
  * Conversation
  * Message
  * Report
  * BoostPurchase
  * Notification
  * AuditLog
  * PropertyView
  * Feedback
  * Profile

The database schema is based on a **UML Class Diagram** designed for this project.

---

## 🔀 GitHub Workflow (VERY IMPORTANT)

To avoid conflicts and confusion, we follow these rules:

### Main Branches

* `main` → stable version
* `develop` → integration branch

### Feature Branches

Each feature must have its own branch:

```
feature/auth-backend
feature/property-api
feature/flutter-chat
feature/react-admin-dashboard
```

### Workflow Steps

1. Pull latest changes from `develop`
2. Create a feature branch
3. Work only on your assigned part
4. Commit regularly with clear messages
5. Push your branch
6. Open a Pull Request to `develop`
7. Review & merge

Example:

```bash
git checkout develop
git pull origin develop
git checkout -b feature-property-api
git commit -m "Add property CRUD"
git push origin feature-property-api
```

---

## 📢 Team Rules

* Do **not** push directly to `main`
* Always pull before starting work
* Respect assigned responsibilities
* Communicate changes with the team
* Keep commits small and clear

---

## 🎓 Academic Context

This project demonstrates:

* Software architecture design
* RESTful API development
* Mobile & web frontend integration
* Database modeling
* Security with JWT
* Team collaboration using GitHub

---

## 🚀 Future Improvements

* Real payment gateway integration
* Advanced search (PostGIS)
* Push notifications
* Analytics dashboard enhancements

---

### ✅ This README should be followed by **all team members**

