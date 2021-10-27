var express = require('express');
var router = express.Router();

var runShellCmd = require("../commons/runshellcmd.js")

// check env
var comm = require('../commons/commons.js');

/* ping pong game. */
router.get('/ping', (req, res, next) => {
  var retval = {
    status: 0,
    data: ['pong']
  }
  res.send(retval);
});

router.get('/getinstalledapps', (req, res, next) => {
  var retval = {
    status: 0,
    desc: '',
    data: []
  }
  runShellCmd.getInstalledApps()
    .then((result) => {
      retval = result;
      res.send(retval);
    })
    .catch((e) => {
      console.log('DEBUG error in getInstalledApps', e);
      retval.result = -1;
      retval.data.push(e);
      res.send(retval);
    });
});

router.get('/gettenants', (req, res, next) => {
  var retval = {
    status: 0,
    data: []
  }
  runShellCmd.getTenants()
    .then((result) => {
      retval = result;
      res.send(retval);
    })
    .catch((e) => {
      console.log('DEBUG error in getTenants', e);
      retval.result = -1;
      retval.data.push(e);
      res.send(retval);
    });
});

router.post('/getinstalllog', (req, res, next) => {
  var retval = {
    status: 0,
    desc: '',
    data: []
  }
  runShellCmd.getInstallLog(req.body.appname, req.body.appver)
    .then((result) => {
      retval = result; 
      res.send(retval);
    })
    .catch((e) => {
      console.log('DEBUG error in getInstalledApps', e);
      retval.result = -1;
      retval.data.push(e);
      res.send(retval);
    });
});

router.post('/gettenantlog', (req, res, next) => {
  var retval = {
    status: 0,
    data: []
  }
  //console.log('DEBUG GET api/getinstalledapps');
  runShellCmd.getTenantLog(req.body.appname, req.body.appver, req.body.tenantname)
    .then((result) => {
      retval = result; 
      res.send(retval);
    })
    .catch((e) => {
      console.log('DEBUG error in getInstallLog', e);
      retval.result = -1;
      retval.data.push(e);
      res.send(retval);
    });
});

router.post('/installapp', (req, res, next) => {
  var retval = {
    status: 0,
    desc: '',
    data: [],
  }
  //console.log('DEBUG POST api/installapp data=',retval.input);
  runShellCmd.runInstall(req.body.appname, req.body.appver, req.body.gitrepo)
  .then((result) => {
    console.log('DEBUG POST api/installapp finished with result =', result);
    retval = result; 
    res.send(retval);
  })
  .catch((e) => {
    console.log('DEBUG error in POST api/installapp', e);
    retval.result = -1;
    retval.data.push(e);
    res.send(retval);
  });
});

router.post('/createtenant', (req, res, next) => {
  var retval = {
    status: 0,
    desc: "",
    data: [],
  }
  // req.body/envvars example -> "APPNAME=\"tenant 1 app fo selling shoes\"\nAPPCOLOR=\"red\""
  console.log("DEBUG POST api/createtenant : req.body =", req.body);
  // 
  var tenantname = req.body.tenantname.toLowerCase();
  console.log("DEBUG lowercase tenantname =", tenantname);

  var varenv = [];
  for(const envLine of req.body.envvars.split('\n') ) {
		// console.log("DEBUG envLine = ", envLine);
    var varenventry = envLine.split('=');
    // console.log("DEBUG varenventry = ", varenventry);
    varenv.push( { varName : varenventry[0], varValue: varenventry[1] });
	}

  runShellCmd.runCreateTenant(req.body.appname, req.body.appver, tenantname, varenv)
  .then((result) => {
    retval = result;
    res.send(retval);
  })
  .catch((e) => {
    console.log('DEBUG error in runCreateTenant', e);
    retval.result = -1;
    retval.data.push(e);
    res.send(retval);
  });
});

router.post('/uninstallapp', (req, res, next) => {
  var retval = {
    status: 0,
    desc: '',
    data: [],
  }
  //console.log('DEBUG POST api/uninstallapp data=',retval.input);
  runShellCmd.runUninstall(req.body.appname, req.body.appver, req.body.gitrepo)
  .then((result) => {
    retval = result; 
    res.send(retval);
  })
  .catch((e) => {
    console.log('DEBUG error in uninstallapp', e);
    retval.result = -1;
    retval.data.push(e);
    res.send(retval);
  });
});

router.post('/deletetenant', (req, res, next) => {
  var retval = {
    status: 0,
    desc: "",
    data: [],
  }
  
  console.log('DEBUG POST api/deletetenant res.body=',req.body);
  runShellCmd.runDeleteTenant(req.body.appname, req.body.appver, req.body.tenantname)
  .then((result) => {
    retval = result;
    res.send(retval);
  })
  .catch((e) => {
    console.log('DEBUG error in runDeleteTenant', e);
    retval.result = -1;
    retval.data.push(e);
    res.send(retval);
  });
});

module.exports = router;
