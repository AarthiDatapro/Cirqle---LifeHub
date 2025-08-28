const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const authRoutes = require('./routes/auth');
const taskRoutes = require('./routes/tasks');
const calendarRoutes = require('./routes/calendar');
const groceryRoutes = require('./routes/grocery');
const remindersRoutes = require('./routes/reminders');
const errorHandler = require('./middleware/errorHandler');

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 300 });
app.use(limiter);

app.get('/', (req, res) => res.json({ ok: true, service: 'LifeHub API' }));

app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/calendar', calendarRoutes);
app.use('/api/grocery', groceryRoutes);
app.use('/api/reminders', remindersRoutes);

app.use(errorHandler);

module.exports = app;
