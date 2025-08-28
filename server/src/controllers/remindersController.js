const Task = require('../models/Task');
const { sendEmail } = require('../services/emailService');
const { calculateMetaScore } = require('./tasksController');

// List smart reminders based on metaScore
exports.listSuggestions = async (req, res, next) => {
  try {
    // Updated to match your Task schema's user field
    let tasks = await Task.find({ user: req.user.id, completed: false });
    if (!tasks.length) return res.json({ ok: true, suggestions: [] });

    // Recalculate score dynamically
    tasks = tasks.map(t => {
      const score = calculateMetaScore(t.priority, t.dueDate, t.createdAt);
      return { ...t.toObject(), score };
    }).sort((a, b) => b.score - a.score);

    // Pick top 10 urgent/important tasks
    const suggestions = tasks.filter(t => t.score >= 40).slice(0, 10);

    res.json({ ok: true, suggestions });
  } catch (err) {
    console.error('List suggestions error:', err);
    next(err);
  }
};

// Send email reminders using metaScore
exports.sendEmailReminders = async (req, res, next) => {
  try {
    if (!process.env.SMTP_USER) {
      return res.status(400).json({ error: 'SMTP not configured' });
    }

    const tasks = await Task.find({ user: req.user.id, completed: false });
    if (!tasks.length) return res.status(400).json({ error: 'No tasks to send' });

    const sorted = tasks
      .map(t => ({
        ...t.toObject(),
        score: calculateMetaScore(t.priority, t.dueDate, t.createdAt)
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, 5);

    const listText = sorted
      .map((t, i) => {
        return `${i + 1}. ${t.title}${t.dueDate ? ` (due ${new Date(t.dueDate).toLocaleString()})` : ''}`;
      })
      .join('\n');

    await sendEmail({
      to: req.user.email,
      subject: 'Your Smart Reminders',
      text: `Hello ${req.user.name},\n\nHere are your top tasks:\n\n${listText}\n\n— LifeHub`
    });

    res.json({ ok: true, sentTo: req.user.email });
  } catch (err) {
    console.error('Send email reminders error:', err);
    next(err);
  }
};
