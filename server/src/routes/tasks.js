const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const tasksController = require('../controllers/tasksController');
const { taskValidator } = require('../utils/validators');

router.use(auth);
router.get('/', tasksController.getTasks);
router.post('/', taskValidator, tasksController.createTask);
router.put('/:id', taskValidator, tasksController.updateTask);
router.delete('/:id', tasksController.deleteTask);

module.exports = router;

