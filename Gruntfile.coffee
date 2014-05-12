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
  grunt.registerTask "test", (file) ->
    sh = require("execSync")
    file = file.substr(1, file.length) if file[0] is "/"
    sh.run "clear"
    command = "mocha test/setup_and_teardown.coffee " + file
    console.log command
    sh.run command

  grunt.registerTask 'productionPostInstall', ->
    return unless process.env.NODE_ENV == 'production'
    grunt.task.run('build')
