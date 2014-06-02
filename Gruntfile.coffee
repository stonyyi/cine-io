_ = require('underscore')
rendrDir = 'node_modules/rendr';
rendrHandlebarsDir = 'node_modules/rendr-handlebars';
rendrModulesDir = rendrDir + '/node_modules';

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    sass:
      options:
        includePaths: [
          "bower_components/foundation/scss"
        ]

      dist:
        options:
          outputStyle: "compressed"

        files:
          "tmp/cine-compiled-app.css": "assets/stylesheets/app.scss"

    concat:
      dist:
        # prism-tomorrow seems not to exhibit the chrome 'disappearing
        # element' but, but prism-twilight does <sigh>
        src: ["bower_components/prism/themes/prism-tomorrow.css", "tmp/cine-compiled-app.css"]
        dest: "public/compiled/app.css"

    nodemon:
      dev:
        script: "server.coffee"
        options:
          watch: ["apps/**/*.coffee", "config/**/*.coffee", "server/**/*.coffee"]
          delay: 1000

    watch:
      grunt:
        files: ["Gruntfile.coffee"]

      sass:
        files: ["assets/stylesheets/**/*.scss"]
        tasks: ["sass", "concat"]

      react:
        files: ["apps/main/app/**/*.jsx"]
        tasks: ["compile"]

      main:
        files: ["apps/main/app/**/*.coffee"]
        tasks: ["rendr_stitch"]

      jssdk:
        files: ["sdk/javascript/**/*.coffee", "sdk/javascript/**/*.js"]
        tasks: ["browserify:jssdk"]

    react:
      dynamic_mappings:
        files: [
          {
            expand: true,
            cwd: 'apps/main/app/components',
            src: ['**/*.jsx'],
            dest: 'compiled/components',
            ext: '.js'
          }
        ]
    concurrent:
      dev:
        options:
          logConcurrentOutput: true
        tasks: ["watch", "nodemon:dev"]

    handlebars: {
      compile: {
        options: {
          namespace: false,
          commonjs: true,
          processName: (filename)->
            return filename.replace('app/templates/', '').replace('.hbs', '');
        },
        src: "app/templates/**/*.hbs",
        dest: "app/templates/compiledTemplates.js",
        filter: (filepath)->
          filename = path.basename(filepath);
          return filename.slice(0, 2) isnt '__';
      }
    }

    rendr_stitch:
      compile:
        options:
          dependencies: [
            'assets/vendor/jquery.js'
            'assets/vendor/jquery.easing.js'
            'assets/vendor/jquery.scrollto.js'
            'bower_components/modernizr/modernizr.js'
            'bower_components/fastclick/lib/fastclick.js'
            'bower_components/foundation/js/foundation.js'
            'bower_components/prism/prism.js'
          ],
          npmDependencies:
            underscore: '../rendr/node_modules/underscore/underscore.js'
            backbone: '../rendr/node_modules/backbone/backbone.js'
            qs: "../qs/index.js"
            handlebars: '../rendr-handlebars/node_modules/handlebars/dist/handlebars.runtime.js'
            async: '../rendr/node_modules/async/lib/async.js'
          aliases: [
            {from: "apps/main/app/", to: 'app/'}
            {from: "compiled/components/", to: 'app/components/'}
            {from: "bower_components/react/react", to: 'react'}

            {from: rendrDir + '/client', to: 'rendr/client'},
            {from: rendrDir + '/shared', to: 'rendr/shared'},
            {from: rendrHandlebarsDir, to: 'rendr-handlebars'},
            {from: rendrHandlebarsDir + '/shared', to: 'rendr-handlebars/shared'}
          ]
        files: [{
          dest: 'public/compiled/mergedAssets.js'
          src: [
            'bower_components/react/react.js'
            'apps/main/app/**/*.coffee'
            "config/cine.coffee"
            "compiled/components/**/*.js"
            rendrDir + '/client/**/*.js'
            rendrDir + '/shared/**/*.js'
            rendrHandlebarsDir + '/index.js'
            rendrHandlebarsDir + '/shared/*.js'
          ]
        }]

    browserify:
      jssdk:
        files:
          'public/compiled/cineio-dev.js': ['sdk/javascript/main.coffee']
        options:
          browserifyOptions:
            extensions: ['.coffee', '.js']
          transform: ['coffeeify']

    uglify:
      options:
        report: "min"

      production:
        files:
          "public/compiled/cineio.js": ["public/compiled/cineio-dev.js"]
          "public/compiled/mergedAssets.js": ["public/compiled/mergedAssets.js"]


  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-nodemon"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-concurrent"
  grunt.registerTask "compile", ["react", "handlebars", "rendr_stitch", "browserify"]
  grunt.registerTask "build", ["compile", "sass", "concat"]
  grunt.registerTask "prepareProductionAssets", ["compile", "sass", "concat", "uglify"]
  grunt.registerTask "dev", ["build", "concurrent:dev"]
  grunt.registerTask "default", ["dev"]
  grunt.loadNpmTasks 'grunt-react'
  grunt.loadNpmTasks('grunt-contrib-handlebars');
  grunt.loadNpmTasks('grunt-rendr-stitch');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask "test", (file) ->
    sh = require("execSync")
    file = file.substr(1, file.length) if file[0] is "/"
    sh.run "clear"
    command = "mocha test/setup_and_teardown.coffee #{file}"
    console.log command
    sh.run command

  grunt.registerTask "seed", ->
    done = @async()
    grunt.util.spawn
      cmd: "coffee"
      args: ["development/seed.coffee"]
      opts:
        stdio: "inherit"
    , (err, result)->
      done()

  grunt.registerTask 'routes', ->
    require('./config/environment')
    app = Cine.require('app').app
    allRoutes = {}
    _.each app.routes, (routes, method)->
      allRoutes[method] = []
      _.each routes, (route)->
        allRoutes[method].push(route.path)
    _.each allRoutes, (routes, method)->
      console.log("\n======= #{method} =======\n")
      _.each routes.sort(), (route)-> console.log(route)

  grunt.registerTask 'productionPostInstall', ->
    return unless process.env.NODE_ENV == 'production'
    grunt.task.run('prepareProductionAssets')
