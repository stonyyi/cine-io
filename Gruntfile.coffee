_ = require('underscore')
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
          watch: ["api/**/*.coffee", "config/**/*.coffee", "middleware/**/*.coffee", "models/**/*.coffee", "server/**/*.coffee"]
          delay: 1000

    watch:
      grunt:
        files: ["Gruntfile.coffee"]

      sass:
        files: "scss/**/*.scss"
        tasks: ["sass"]

      jsx:
        files: "views/src/**/*.coffee"
        tasks: ["react", "browserify"]

    concurrent:
      dev:
        options:
          logConcurrentOutput: true
        tasks: ["watch", "nodemon:dev"]
    react:
      dynamic_mappings:
        files: [
          {
            expand: true,
            cwd: 'views/src',
            src: ['**/*.coffee'],
            dest: 'views/build',
            ext: '.js'
          }
        ]

    browserify:
      dist:
        options:
          transform:  [ require('grunt-react').browserify ]
        files:
          'public/compiled/app.js': ['views/build/**/*.js']
      # app:
      #   dest:       'public/compiled/app.js'

  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-nodemon"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-concurrent"
  grunt.registerTask "build", ["sass"]
  grunt.registerTask "wtf", ["react", "browserify"]
  grunt.registerTask "dev", ["build", "concurrent:dev"]
  grunt.registerTask "default", ["dev"]
  grunt.loadNpmTasks 'grunt-react'
  grunt.loadNpmTasks 'grunt-browserify'

  grunt.registerTask "test", (file) ->
    sh = require("execSync")
    file = file.substr(1, file.length) if file[0] is "/"
    sh.run "clear"
    command = "mocha test/setup_and_teardown.coffee #{file}"
    console.log command
    sh.run command

  grunt.registerTask 'routes', ->
    require('./config/environment')
    app = Cine.require('app').app
    allRoutes = {
      get: []
      post: []
      put: []
      delete: []
    }
    _.each app._router.stack, (route)->
      return unless route.route
      route = route.route
      _.each route.methods, (methodIsUsed, method)->
        return unless methodIsUsed
        allRoutes[method].push(route.path)
    _.each allRoutes, (routes, method)->
      console.log("\n======= #{method} =======\n") if routes.length > 1
      _.each routes.sort(), (route)-> console.log(route)

  grunt.registerTask 'productionPostInstall', ->
    return unless process.env.NODE_ENV == 'production'
    grunt.task.run('build')
