const fs = require('fs');
const crypto = require("crypto")

var boot_time =  Math.round((Date.now()/1000)-(fs.readFileSync("/proc/uptime").toString().split(" ")[0].split(".")[0])).toString(32).toUpperCase();
var vm_id;

exports.handler = function(event, context, callback) {
    var version = 'v1';
    var memory = context.memoryLimitInMB
    var timeout = JSON.stringify(context.getRemainingTimeInMillis()/1000);
    fibonacci(35);
    var statusCode = "200";
    if (vm_id === undefined){
        vm_id= crypto.randomBytes(16).toString("base64");
        statusCode="201"
    }
    var body = {version, vm_id, boot_time, memory, timeout};
    callback(null,{statusCode, body})
};

function fibonacci(n) {
    if (n < 1) {
        throw new Error('fibonacci: First argument must be a number greater than zero.');
    }

    if (n === 1 || n === 2) {
        return 1;
    } else {
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
}

