const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
  id: { type: String, required: true }, // Flutter's UUID
  title: { type: String, required: true },
  priority: { type: String, enum: ['low', 'medium', 'high'], default: 'low' },
  dueDate: { type: Date },
  metaScore: { type: Number, default: 0 } ,
  completed: { type: Boolean, default: false },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true });

module.exports = mongoose.model('Task', taskSchema);
