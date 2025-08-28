const { body } = require('express-validator');

exports.registerValidator = [
  body('name').isLength({ min: 2 }).withMessage('Name too short'),
  body('email').isEmail().withMessage('Invalid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be >= 6 chars'),
];

exports.loginValidator = [
  body('email').isEmail().withMessage('Invalid email'),
  body('password').exists().withMessage('Password required'),
];

exports.taskValidator = [
  body('title').isLength({ min: 1 }).withMessage('Title required'),
  body('priority').optional().isIn(['low','medium','high']),
];
