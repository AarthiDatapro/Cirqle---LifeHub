const mongoose = require('mongoose');

const connectDB = async (uri) => {
  if (!uri) throw new Error('MONGODB_URI not set');
  await mongoose.connect(uri, {
    dbName: 'lifehub',
    autoIndex: true,
  });
  console.log('Connected to MongoDB');
};

module.exports = connectDB;
