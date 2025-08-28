const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const remindersController = require('../controllers/remindersController');

router.use(auth);
router.get('/', remindersController.listSuggestions);
router.post('/send', remindersController.sendEmailReminders);

module.exports = router;
