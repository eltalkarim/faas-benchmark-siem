const fs = require('fs');
const crypto = require("crypto")

var boot_time =  Math.round((Date.now()/1000)-(fs.readFileSync("/proc/uptime").toString().split(" ")[0].split(".")[0])).toString(32).toUpperCase();
var vm_id;
var version = 'v1';


function main() {
    return new Promise(function(resolve, reject) {
        fibonacci(35);
        var memory = JSON.stringify(parseInt(fs.readFileSync("/sys/fs/cgroup/memory/memory.limit_in_bytes").toString().slice(0, -1))/1000000);
        let now = new Date().getTime();
        let deadline = parseInt(process.env.__OW_DEADLINE,10);
        let timeout =JSON.stringify((deadline-now)/1000);
        var statusCode = '200';
        if (vm_id === undefined) {
            vm_id = crypto.randomBytes(16).toString("base64");
            statusCode = '201'
        }
        var body = {version, vm_id, boot_time, memory, timeout};
        resolve({statusCode, body});

    })
}

exports.handler = main

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

