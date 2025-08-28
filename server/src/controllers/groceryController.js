const GroceryItem = require('../models/GroceryItem');
const { suggestGroceries } = require('../services/aiService');

exports.list = async (req, res, next) => {
  try {
    const items = await GroceryItem.find({ userId: req.user._id }).sort({ createdAt: -1 });
    res.json(items);
  } catch (err) { next(err); }
};

exports.create = async (req, res, next) => {
  try {
    const { name, qty = 1 } = req.body;
    if (!name || !name.trim()) return res.status(400).json({ error: 'Name required' });

    const g = await GroceryItem.create({ userId: req.user._id, name: name.trim(), qty });
    req.user.groceryHistory = req.user.groceryHistory || [];
    req.user.groceryHistory.push(name.trim());
    await req.user.save();
    res.status(201).json(g);
  } catch (err) { next(err); }
};

exports.update = async (req, res, next) => {
  try {
    const g = await GroceryItem.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      req.body,
      { new: true }
    );
    if (!g) return res.status(404).json({ error: 'Item not found' });
    res.json(g);
  } catch (err) { next(err); }
};

exports.remove = async (req, res, next) => {
  try {
    const deleted = await GroceryItem.findOneAndDelete({ _id: req.params.id, userId: req.user._id });
    if (!deleted) return res.status(404).json({ error: 'Item not found' });
    res.json({ message: 'Item deleted' });
  } catch (err) { next(err); }
};

exports.suggest = async (req, res, next) => {
  try {
    const suggestions = await suggestGroceries(req.user, { tasks: req.body.tasks || [] });
    res.json({ ok: true, suggestions });
  } catch (err) { next(err); }
};
