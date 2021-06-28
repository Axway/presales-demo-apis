#!/usr/bin/env node

var argv = require('minimist')(process.argv.slice(2))

var file = argv._[0]
if (!file) {
  process.exit(1)
}

var e=require('find-config')(file)
if(e) {
  console.log(e)
} else {
  console.log("/dev/null")
}
