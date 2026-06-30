# ✈️ TravelExplorer — Travel & Tourism Management System

A complete, professionally designed Travel & Tourism web application built with Java EE (JSP + Servlets), MySQL, and Apache Tomcat — now with a cinematic **dark/light theme system**.

---

## 🎨 Design System

**Default theme: Dark Mode** — deep navy (`#0A0E27`) background with an amber accent (`#F5A623`), built for a premium travel-brand feel. A polished **light mode** is one click away via the toggle switch in the header.

| Element | Choice |
|---|---|
| Display font | Playfair Display (headings, prices, logo) |
| Body font | Inter (body text, UI, forms) |
| Accent color | Amber `#F5A623` — warm, premium, travel-adjacent |
| Secondary accents | Electric purple `#6C63FF`, teal `#00D4AA` |
| Theme toggle | Pill switch in header, persists via `localStorage` |
| Motion | Subtle fade-up entrances, hover lifts, glow on focus |

The toggle is in the header on **every page** (including the admin dashboard) and remembers the user's choice across sessions and page loads — no flash-of-wrong-theme on reload.

---
# Screenshots

## Home Page

![Home](screenshots/home.png)

## Login Page

![Login](screenshots/login.png)

## Booking Page

![Booking](screenshots/booking.png)

## Payment Page

![Payment](screenshots/payment.png)

## Admin Dashboard

![Admin Dashboard](screenshots/admin-dashboard.png)

## 🚀 Features

### User Features
- Register & Login (password hashed with SHA-256)
- Browse travel packages with **Search & Filter** (keyword, price range)
- Book packages with traveler count and travel date
- **Online Payment** simulation (Card / UPI / Net Banking)
- **Download PDF Ticket** after booking (iText)
- View Booking History with live status
- **Submit Star Ratings & Reviews** after payment
- **Dark / Light theme toggle** — every page, persisted

### Admin Features
- Secure Admin Dashboard (admin-only access)
- **Revenue Analytics Chart** (Chart.js, last 6 months, theme-aware)
- Manage Packages (Add / Delete)
- View & Update All Bookings (status workflow)
- Manage Users list
- View all Reviews
- View Contact Messages

---

## 🛠️ Technologies

| Layer        | Technology                     |
|--------------|---------------------------------|
| Frontend     | HTML5, CSS3 (custom design system), Vanilla JS |
| Fonts        | Google Fonts — Playfair Display + Inter |
| Backend      | Java Servlets, JSP              |
| Database     | MySQL (JDBC)                    |
| Server       | Apache Tomcat 10.x               |
| PDF          | iText PDF 5.x                    |
| Charts       | Chart.js 4.x                     |
| Icons        | Font Awesome 6.x                 |

---


## 📂 Project Structure

```
tourism/
├── src/main/java/com/mycompany/tourism/
│   ├── servlets/
│   │   ├── LoginServlet.java
│   │   ├── RegisterServlet.java         ← themed success/error pages
│   │   ├── BookingServlet.java
│   │   ├── BookingHistoryServlet.java
│   │   ├── ProcessPaymentServlet.java
│   │   ├── DownloadTicketServlet.java   ← PDF generation
│   │   ├── ReviewServlet.java           ← Ratings & reviews
│   │   ├── AdminDashboardServlet.java   ← Full analytics
│   │   ├── DestinationListServlet.java  ← Search & filter
│   │   ├── AddPackageServlet.java
│   │   ├── CancelBookingServlet.java
│   │   ├── ContactServlet.java
│   │   └── ...
│   └── utils/
│       ├── DBConnection.java
│       └── PasswordUtil.java
├── src/main/webapp/
│   ├── index.html              ← Hero, featured packages, features
│   ├── login.html / register.html
│   ├── contact.html            ← Working contact form
│   ├── destinations.jsp        ← Search & filter UI
│   ├── booking.jsp             ← Booking form
│   ├── bookings.jsp            ← History + ticket + review modal
│   ├── payment.jsp             ← Payment gateway UI
│   ├── payment-success.jsp
│   ├── admin-dashboard.jsp     ← Full admin panel + charts
│   ├── css/style.css           ← Complete design system (dark/light)
│   ├── js/theme.js             ← Theme toggle logic
│   ├── images/                 ← Package + hero images
│   ├── database_setup.sql      ← Run this first
│   └── WEB-INF/web.xml
└── pom.xml
```


## 📋 Database Tables

| Table      | Purpose                            |
|------------|-------------------------------------|
| users      | User accounts & admin flag          |
| packages   | Travel packages (title, price, duration as text) |
| bookings   | User bookings with status & payment info |
| reviews    | Package ratings & comments          |
| contacts   | Contact form submissions            |

