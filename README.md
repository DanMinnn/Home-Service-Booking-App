# Home Service Booking App 

A full-stack application that allows clients to book and manage housekeeping services. Taskers (service providers) to receive, confirm and complete bookings. Inspired by platforms like **bTaskee**.

## Tech Stack (primary)

### Frontend (Mobile - Flutter)
- Flutter + Dart, design based on Figma template
- State Management: BLoC
- Firebase Messaging (for push notifications)
- Deep Linking (for payment callback via VNPAY, verify email)
- Integration Chatbot use RAG from backend

### 🔹 Backend (Spring Boot)
- Java Spring Boot 3
- PostgreSQL (Database)
- Redis (OTP + token cache)
- JWT Authentication (access + refresh token)
- WebSocket (real-time chat between client and tasker)
- VNPAY Integration (payment gateway)
- Docker + Docker Compose (for deployment)

---

## Features

### 👥 User Roles
- **Client**: can browse services, create bookings, make payments, chat with tasker.
- **Tasker**: receives job requests, manages availability, communicates with clients.

### 📦 Functionalities
- Register/Login with role-based authentication
- Book service by date, time, location, and service type
- Assign taskers using reputation score + epsilon-greedy strategy
- Real-time chat between client and tasker
- Payment via **VNPAY** (with auto callback and payment verification)
- Notification system (push & in-app)
- Admin dashboard (for service management)

App for client:
https://github.com/user-attachments/assets/373debdb-6a6d-40f6-aa00-3e918d4d8b5b
App for tasker:
https://github.com/user-attachments/assets/86858910-24d0-4c40-9876-9cb943ec3c61



