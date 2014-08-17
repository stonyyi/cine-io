require('coffee-script/register')
var Cine = require('./config/cine_server')
  , exec = require('child_process').exec
  , async = require('async')
  , commands = [
      "lsb_release -a"
    , "uname -r"
    , "ldd --version"
    , "ffmpeg -version"
    , "MP4Box -version"
    , "which MP4Box"
    , "ldd ./ubuntu_binaries/bin/MP4Box"
    ]
  , commandFuncs = commands.map(function(command) {
      return function(callback) {
        exec(command, function(error, stdout, stderr) {
          console.log(command, "--", "stdout:", stdout)
          console.error(command, "--", "stderr:", stderr)
          console.log("--------------------------------------")
          return callback(null)
        })
      }
    })

console.log("PATH:", process.env.PATH)
console.log("LD_LIBRARY_PATH:", process.env.LD_LIBRARY_PATH)

async.series(commandFuncs, function(err, result) {
  return console.log("DONE")
})
