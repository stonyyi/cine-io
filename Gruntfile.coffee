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

    nodemon:
      dev:
        script: "server.coffee"
        options:
          watch: ["**/*.coffee", "**/*.js"]
          delay: 1000

    watch:
      grunt:
        files: ["Gruntfile.coffee"]

      sass:
        files: "scss/**/*.scss"
        tasks: ["sass"]

    concurrent:
      dev:
        options:
          logConcurrentOutput: true
        tasks: ["watch", "nodemon:dev"]

  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-nodemon"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-concurrent"
  grunt.registerTask "build", ["sass"]
  grunt.registerTask "dev", ["build", "concurrent:dev"]
  grunt.registerTask "default", ["dev"]
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
