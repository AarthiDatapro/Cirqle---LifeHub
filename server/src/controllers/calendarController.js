const Event = require('../models/Event');
const { validationResult } = require('express-validator');

exports.list = async (req, res, next) => {
  try {
    const events = await Event.find({ userId: req.user._id }).sort({ start: 1 });
    res.json({ ok: true, events });
  } catch (err) { next(err); }
};

exports.create = async (req, res, next) => {
  try {
    // Ensure authentication middleware worked
    if (!req.user || !req.user._id) {
      return res.status(401).json({ ok: false, error: 'Unauthorized' });
    }

    const { title, start, end, description } = req.body;

    // Basic validation
    if (!title || !start || !end) {
      return res.status(400).json({ ok: false, error: 'Title, start, and end are required' });
    }

    const payload = {
      title,
      start: new Date(start),
      end: new Date(end),
      description: description || '',
      userId: req.user._id
    };

    const event = await Event.create(payload);

    res.status(201).json({ ok: true, event });
  } catch (err) {
    next(err);
  }
};


exports.update = async (req, res, next) => {
  try {
    const evt = await Event.findOne({ _id: req.params.id, userId: req.user._id });
    if (!evt) return res.status(404).json({ error: 'Event not found' });
    Object.assign(evt, req.body);
    await evt.save();
    res.json({ ok: true, event: evt });
  } catch (err) { next(err); }
};

exports.remove = async (req, res, next) => {
  try {
    await Event.deleteOne({ _id: req.params.id, userId: req.user._id });
    res.json({ ok: true });
  } catch (err) { next(err); }
};
