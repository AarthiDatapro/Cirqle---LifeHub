const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const calendarController = require('../controllers/calendarController');

router.use(auth);
router.get('/', calendarController.list);
router.post('/', calendarController.create);
router.put('/:id', calendarController.update);
router.delete('/:id', calendarController.remove);

module.exports = router;
