const Task = require('../models/Task');

// Updated scoring logic for reminders
function calculateMetaScore(priority, dueDate, createdAt = new Date()) {
  let score = 0;
  const now = new Date();

  // Time urgency
  if (dueDate) {
    const diffHours = (new Date(dueDate) - now) / (1000 * 60 * 60);
    if (diffHours <= 24 && diffHours >= 0) score += 50; // due within 24h
    if (diffHours < 0) score += 70; // overdue
    else if (diffHours <= 72) score += 30; // within 3 days
  }

  // Priority weighting
  if (priority === 'high') score += 30;
  if (priority === 'medium') score += 15;

  // Newness factor (optional small boost for recent tasks)
  const ageDays = (now - new Date(createdAt)) / (1000 * 60 * 60 * 24);
  score += Math.max(0, 10 - ageDays);

  return score;
}

// Create a new task
exports.createTask = async (req, res) => {
  try {
    console.log("Hi! Tasks Post")
    if (!req.body.title || !req.body.dueDate) {
      return res.status(400).json({ error: 'Title and dueDate are required' });
    }

    const metaScore = calculateMetaScore(
      req.body.priority || 'medium',
      req.body.dueDate
    );

    const task = new Task({
      id: req.body.id, // from Flutter's UUID
      title: req.body.title.trim(),
      priority: req.body.priority || 'medium',
      dueDate: req.body.dueDate,
      completed: req.body.completed || false,
      metaScore,
      user: req.user.id
    });

    await task.save();
    res.status(201).json(task);
  } catch (err) {
    console.error('Create task error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get all tasks for logged-in user
exports.getTasks = async (req, res) => {
  try {
    console.log("Hi! Tasks Get")
    const tasks = await Task.find({ user: req.user.id }).sort({ dueDate: 1 });
    res.json(tasks);
  } catch (err) {
    console.error('Get tasks error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Update a task
exports.updateTask = async (req, res) => {
  try {
    const existingTask = await Task.findOne({ id: req.params.id, user: req.user.id });
    if (!existingTask) {
      return res.status(404).json({ error: 'Task not found' });
    }

    // Update fields
    if (req.body.title !== undefined) existingTask.title = req.body.title.trim();
    if (req.body.priority !== undefined) existingTask.priority = req.body.priority;
    if (req.body.dueDate !== undefined) existingTask.dueDate = req.body.dueDate;
    if (req.body.completed !== undefined) existingTask.completed = req.body.completed;

    // Recalculate metaScore if priority or dueDate changed
    if (req.body.priority !== undefined || req.body.dueDate !== undefined) {
      existingTask.metaScore = calculateMetaScore(
        existingTask.priority,
        existingTask.dueDate,
        existingTask.createdAt
      );
    }

    await existingTask.save();
    res.json(existingTask);
  } catch (err) {
    console.error('Update task error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Delete a task
exports.deleteTask = async (req, res) => {
  try {
    const deleted = await Task.findOneAndDelete({
      id: req.params.id,
      user: req.user.id
    });

    if (!deleted) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.json({ message: 'Task deleted successfully' });
  } catch (err) {
    console.error('Delete task error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Export score function for reminders controller
exports.calculateMetaScore = calculateMetaScore;
