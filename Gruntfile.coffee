module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    sass:
      options:
        includePaths: ["bower_components/foundation/scss"]

      dist:
        options:
          outputStyle: "compressed"

        files:
          "public/css/app.css": "scss/app.scss"

    watch:
      grunt:
        files: ["Gruntfile.js"]

      sass:
        files: "scss/**/*.scss"
        tasks: ["sass"]

  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.registerTask "build", ["sass"]
  grunt.registerTask "default", [
    "build"
    "watch"
  ]
  grunt.registerTask "test", (fileWithLeadingSlashFromSublime) ->
    command = undefined
    file = undefined
    sh = undefined
    sh = require("execSync")
    if fileWithLeadingSlashFromSublime[0] is "/"
      file = fileWithLeadingSlashFromSublime.substr(1, fileWithLeadingSlashFromSublime.length)
    else
      file = fileWithLeadingSlashFromSublime
    sh.run "clear"
    command = "mocha test/setup_and_teardown.coffee " + file
    console.log command
    sh.run command

  return
