# LifeHub Backend

Requirements:
- Node 18+
- Docker (optional) & Docker Compose (optional)

Quick start (local):
1. copy .env.example to .env and fill values
2. npm install
3. npm run dev

Docker:
- docker-compose up --build

APIs:
- POST /api/auth/register
- POST /api/auth/login
- GET/POST/PUT/DELETE /api/tasks
- GET/POST/PUT/DELETE /api/calendar
- GET/POST /api/grocery
- GET/POST /api/reminders

JWT required for protected routes (Authorization: Bearer <token>)
