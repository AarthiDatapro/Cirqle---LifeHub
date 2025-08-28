const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const groceryController = require('../controllers/groceryController');

router.use(auth);

router.get('/', groceryController.list);
router.post('/', groceryController.create);
router.post('/suggestions', groceryController.suggest);
router.put('/:id', groceryController.update);   // NEW
router.delete('/:id', groceryController.remove); // NEW

module.exports = router;
