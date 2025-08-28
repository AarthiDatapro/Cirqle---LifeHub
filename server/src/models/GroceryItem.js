const mongoose = require('mongoose');

const grocerySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  qty: { type: Number, default: 1 },
  checked: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('GroceryItem', grocerySchema);
