# LifeHub - Unified Daily Life Assistant

A beautiful and modern Flutter app for managing tasks, groceries, calendar events, and reminders with a stunning green-themed UI.

## Features

- ✨ **Stunning Modern UI** - Beautiful animations and visual effects
- 📱 **Cross-platform** - Works on web, iOS, and Android
- 🎯 **Task Management** - Create, edit, and organize tasks with priorities
- 🛒 **Grocery Lists** - Manage shopping lists with categories
- 📅 **Calendar Integration** - View and manage events
- 🔔 **Reminders** - Set and track important reminders
- 🔐 **Authentication** - Secure login and registration
- 🌐 **Real-time Sync** - Backend API with Node.js and MongoDB

## Screenshots

The app features a modern, clean design with:

- Smooth animations and transitions
- Beautiful card-based layouts
- Intuitive navigation
- Consistent green theme throughout
- Responsive design for all screen sizes

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Node.js (v16 or higher)
- MongoDB (local or cloud)
- Git

### Backend Setup

1. **Navigate to the server directory:**

   ```bash
   cd server
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Create environment file:**

   ```bash
   cp .env.example .env
   ```

   Update the `.env` file with your MongoDB connection string:

   ```
   MONGODB_URI=mongodb://localhost:27017/lifehub
   PORT=4000
   JWT_SECRET=your-secret-key
   ```

4. **Start the server:**

   ```bash
   npm run dev
   ```

   The server will start on `http://localhost:4000`

### Frontend Setup

1. **Navigate to the frontend directory:**

   ```bash
   cd frontend
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run on Web:**

   ```bash
   flutter run -d chrome
   ```

4. **Run on Mobile:**

   **For Android:**

   ```bash
   flutter run -d android
   ```

   **For iOS:**

   ```bash
   flutter run -d ios
   ```

## Mobile Development Setup

### Network Configuration

To run the app on mobile devices, you need to configure the API endpoints:

1. **Find your computer's IP address:**

   - On Windows: `ipconfig`
   - On Mac/Linux: `ifconfig` or `ip addr`

2. **Update the API configuration:**

   Edit `frontend/lib/config/api_config.dart` and update the `mobileDevBaseUrl` with your computer's IP:

   ```dart
   static const String mobileDevBaseUrl = 'http://YOUR_IP_ADDRESS:4000/api';
   ```

3. **Run with mobile configuration:**
   ```bash
   flutter run --dart-define=ENVIRONMENT=mobile
   ```

### Troubleshooting Mobile Connection

If you're getting connection errors on mobile:

1. **Check firewall settings** - Ensure port 4000 is open
2. **Verify network** - Make sure mobile device and computer are on the same network
3. **Test connection** - Try accessing `http://YOUR_IP:4000` from mobile browser
4. **Update IP address** - If your IP changes, update the configuration

### Alternative: Use ngrok for Development

1. **Install ngrok:**

   ```bash
   npm install -g ngrok
   ```

2. **Create tunnel:**

   ```bash
   ngrok http 4000
   ```

3. **Use the ngrok URL** in your API configuration:
   ```dart
   static const String mobileDevBaseUrl = 'https://your-ngrok-url.ngrok.io/api';
   ```

## Project Structure

```
cirqle/
├── frontend/                 # Flutter app
│   ├── lib/
│   │   ├── config/          # Configuration files
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   ├── screens/         # UI screens
│   │   ├── services/        # API services
│   │   └── widgets/         # Reusable widgets
│   └── assets/              # Images, fonts, etc.
└── server/                  # Node.js backend
    ├── src/
    │   ├── controllers/     # Route controllers
    │   ├── models/          # Database models
    │   ├── routes/          # API routes
    │   └── middleware/      # Custom middleware
    └── package.json
```

## API Endpoints

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `GET /api/tasks` - Get user tasks
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `GET /api/grocery` - Get grocery items
- `POST /api/grocery` - Add grocery item
- `GET /api/calendar` - Get calendar events

## Technologies Used

### Frontend

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **HTTP** - API communication
- **Shared Preferences** - Local storage

### Backend

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM
- **JWT** - Authentication
- **bcrypt** - Password hashing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Ensure all dependencies are installed
3. Verify network connectivity
4. Check server logs for errors

For additional help, please open an issue on GitHub.
