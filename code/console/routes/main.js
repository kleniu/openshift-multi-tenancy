var express = require('express');
var router = express.Router();

// check env
var comm = require('../commons/commons.js');

/* GET users listing. */
router.get('/', function(req, res, next) {
  if (req.session.logged === true) {
    res.render('main', { title: comm.appname, 
                         themecolor: '-' + comm.appcolor,
                         email: req.session.email });
  } else {
    res.redirect('/');
  }
});

module.exports = router;
