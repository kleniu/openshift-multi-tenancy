var express = require('express');
var router = express.Router();
// new modules
// const { check, validationResult } = require('express-validator');

// check env
var comm = require('../commons/commons.js');


// get users
var users = require('../data/users.json');



/* GET home page. */
router.get('/', function (req, res, next) {

  if (typeof req.session.logged === 'undefined') {
    req.session.logged = false;
    req.session.email  = "";
    res.render('index', { title: comm.appname, themecolor: '-' + comm.appcolor });
  } else if (req.session.logged === true) {
    res.redirect('/main');
  } else {
    res.render('index', { title: comm.appname, themecolor: '-' + comm.appcolor });
  } 

});



router.post('/login', (req, res, next) => {
  console.log('DEBUG session=', req.session, ' body =', req.body);
  var retval = {};

  if ( req.body.password == users[req.body.email]) {
    //console.log('POST /login - password match', req.body.password, users[req.body.email])
    req.session.logged = true;
    req.session.email = req.body.email;
    retval.status = "OK";
    retval.desc   = "Login successful"
  }
  else {
    //console.log('POST /login - password dop not match', req.body.password, users[req.body.email])
    req.session.logged = false;
    req.session.email  = "";
    retval.status = "ERR";
    retval.desc   = "Wrong username or password"
  }
  res.json(retval);
});


router.get('/logout', function (req, res, next) {
  req.session.logged = false;
  req.session.email = "";
  res.redirect('/');
});

module.exports = router;
