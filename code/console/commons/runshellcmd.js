const util = require('util');
const exec = util.promisify(require('child_process').exec);
var comm = require('../commons/commons.js');

function _runCmd(command) {
	let resolv = {
		code: -1,
		cmd: command ,
		stdout: '',
		stderr: ''
	};

	return new Promise((Resolve, reject) => {
		if (command != '') {
			exec(resolv.cmd)
				.then((msg) => {
					resolv.code = 0;
					resolv.stdout = msg.stdout;
					resolv.stderr = msg.stderr;
					Resolve(resolv);
				})
				.catch((e) => {
					resolv.code = e.code;
					resolv.stdout = e.stdout;
					resolv.stderr = e.stderr;
					Resolve(resolv);
				});
		}
		else {
			reject("Provide the command to execute.");
		}
	});
}

function getInstalledApps() {
	let resolv = {
		status : 0,
		desc   : '',
		data   : []
	};

	return new Promise( (Resolve, reject) => {
		let command = 'commons/getInstalledApps.sh ' + comm.appsdir;
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/exeCreateTenant.sh msg=', msg);
			resolv.status = 0;
			try {
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = {};
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

function getInstallLog( appname, appver ) {
	let resolv = {
		status : 0,
		desc   : '',
		data   : []
	};

	return new Promise( (Resolve, reject) => {
		let command = 'commons/getInstallLog.sh ' + comm.appsdir + ' ' + appname + ' ' + appver
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/exeCreateTenant.sh msg=', msg);
			resolv.status = 0;
			try {
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = {};
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

function runInstall( appname, appver, appgitrepo) {
	let resolv = {
		status : 0,
		desc   : '',
		data   : []
	};

	return new Promise( (Resolve, reject) => {
		let command = 'commons/exeInstallScript.sh ' + comm.appsdir + ' ' + appname + ' ' + appver + ' ' + appgitrepo + ' ' + comm.ocptoken + ' ' + comm.ocpserver
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/exeCreateTenant.sh msg=', msg);
			resolv.status = 0;
			try {
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = {};
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

function runUninstall( appname, appver ) {
	let resolv = {
		status : 0,
		desc   : '',
		data   : []
	};

	return new Promise( (Resolve, reject) => {
		let command = 'commons/exeUninstallScript.sh ' + comm.appsdir + ' ' + appname + ' ' + appver + ' ' + comm.ocptoken + ' ' + comm.ocpserver;
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/exeCreateTenant.sh msg=', msg);
			resolv.status = 0;
			try {
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = {};
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

function runCreateTenant( appname, appver, tenantname, varsArray ) {
	let resolv = {
			status : 0,
			desc   : '',
			data   : {}
	};

	var vars = '';
	for(const varEntry of varsArray) {
		vars = vars + varEntry.varName + '=' + varEntry.varValue + '\n';
	}
	const buff = Buffer.from(vars, 'utf-8');
	const base64 = buff.toString('base64');

	return new Promise( (Resolve, reject) => {
		let command = 'commons/exeCreateTenant.sh ' + comm.appsdir + ' ' + appname + ' ' + appver + ' ' + tenantname + ' ' + comm.ocptoken + ' ' + comm.ocpserver + ' ' + base64;
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/exeCreateTenant.sh msg=', msg);
			resolv.status = 0;
			try {
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = {};
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

function runDeleteTenant( appname, appver, tenantname ) {
	let resolv = {
			status : 0,
			desc   : '',
			data   : {}
	};

	return new Promise( (Resolve, reject) => {
		let command = 'commons/exeDeleteTenant.sh ' + comm.appsdir + ' ' + appname + ' ' + appver + ' ' + tenantname + ' ' + comm.ocptoken + ' ' + comm.ocpserver;
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/exeDeleteTenant.sh msg=', msg);
			resolv.status = 0;
			try {
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = {};
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

function getTenants() {
	let resolv = {
			status : 0,
			desc   : '',
			data   : []
	};

	return new Promise( (Resolve, reject) => {
		let command = 'commons/getTenants.sh ' + comm.appsdir + ' ' + comm.ocptoken + ' ' + comm.ocpserver + ' ' + comm.ocpingress;
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/getTenants.sh msg=', msg);
			resolv.status = 0;
			try {
				console.log("DEBUG getTenants - msg.stdout =", msg.stdout);
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = [];
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

function getTenantLog( appname, appver, tenantname ) {
	let resolv = {
			status : 0,
			desc   : '',
			data   : {}
	};

	return new Promise( (Resolve, reject) => {
		let command = 'commons/getTenantLog.sh ' + comm.appsdir + ' ' + appname + ' ' + appver + ' ' + tenantname + ' ' + comm.ocptoken + ' ' + comm.ocpserver;
		_runCmd( command )
		.then( (msg) => {
			//console.log('DEBUG commons/getTenants.sh msg=', msg);
			resolv.status = 0;
			try {
				var parsedVal = JSON.parse(msg.stdout);
				//console.log('DEBUG parsedVal', parsedVal);
				resolv.status = parsedVal.status;
				resolv.desc   = parsedVal.desc;
				resolv.data   = parsedVal.data;
			}
			catch (e) {
				resolv.status = -1;
				resolv.desc = 'Error in parsing string : ' + msg.stdout;
				resolv.data = {};
			};
			//console.log('DEBUG resolv=', resolv);
			Resolve(resolv);
		})
		.catch( (e) => {
			resolv = e;
			Resolve(resolv);
		} ); 
	} );
}

module.exports = {
	runInstall: runInstall,
	runUninstall: runUninstall,
	getInstalledApps: getInstalledApps,
	getInstallLog: getInstallLog,
	runCreateTenant: runCreateTenant,
	runDeleteTenant: runDeleteTenant,
	getTenants: getTenants,
	getTenantLog: getTenantLog
};

/*
runCreateTenant( 'test-app', 'v1', 'tenant1', 
	[ 
		{ varName:"APPCOLOR", varValue:"red" }, 
		{ varName:"APPNAME",  varValue:"Tenant 1 application." }
	])
.then( (msg) => {
	console.log('DEBUG runCreateTenant returns : ', msg);
});

getTenants( )
.then( (msg) => {
	console.log('DEBUG getTenants returns : ', msg);
});

getTenantLog( 'test-app', 'v1', 'tenant1')
.then( (msg) => {
	console.log('DEBUG getTenantLog returns : ', msg);
});

runDeleteTenant( 'test-app', 'v1', 'tenant1')
.then( (msg) => {
	console.log('DEBUG runDeleteTenant returns : ', msg);
});

getInstallLog('test-app', 'v1')
	.then((msg) => {
		console.log('msg', msg);
	})
	.catch((e) => {
		console.error(e);
	});

getInstalledApps()
	.then((msg) => {
		console.log('msg', msg);
	})
	.catch((e) => {
		console.error(e);
	});

runUninstall('test-app', 'v1')
	.then((msg) => {
		console.log('msg', msg);
	})
	.catch((e) => {
		console.error(e);
	});

runInstall('test-app', 'v1', 'git@github.com:kleniu/demo-webapp.git')
	.then((msg) => {
		console.log('msg', msg);
	})
	.catch((e) => {
		console.error(e);
	});
*/
