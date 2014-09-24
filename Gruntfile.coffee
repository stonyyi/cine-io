_ = require('underscore')
rendrDir = 'node_modules/rendr';
rendrHandlebarsDir = 'node_modules/rendr-handlebars';
rendrModulesDir = rendrDir + '/node_modules';

module.exports = (grunt) ->
  rendrProjects = ['admin', 'main']

  stitchConfig = {}
  _.each rendrProjects, (rendrProject)->
    compile:
      stitchConfig[rendrProject] =
        options:
          dependencies: [
            'assets/vendor/jquery.js'
            'assets/vendor/jquery.easing.js'
            'assets/vendor/jquery.scrollto.js'
            'assets/vendor/jquery.payment.js'
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
            async: '../async/lib/async.js'
          aliases: [
            from: "apps/#{rendrProject}/app/", to: 'app/'
            {from: "compiled/#{rendrProject}/components/", to: 'app/components/'}
            {from: "bower_components/react/react", to: 'react'}
            {from: "apps/shared/", to: '/'}

            {from: rendrDir + '/client', to: 'rendr/client'},
            {from: rendrDir + '/shared', to: 'rendr/shared'},
            {from: rendrHandlebarsDir, to: 'rendr-handlebars'},
            {from: rendrHandlebarsDir + '/shared', to: 'rendr-handlebars/shared'}
          ]
        files: [{
          dest: "public/compiled/#{rendrProject}/mergedAssets.js"
          src: [
            'bower_components/react/react.js'
            "apps/#{rendrProject}/app/**/*.coffee"
            "apps/shared/**/*.coffee",
            "config/cine.coffee"
            "config/providers_and_plans.coffee"
            "compiled/#{rendrProject}/components/**/*.js"
            rendrDir + '/client/**/*.js'
            rendrDir + '/shared/**/*.js'
            rendrHandlebarsDir + '/index.js'
            rendrHandlebarsDir + '/shared/*.js'
          ]
        }]

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
        files: ["apps/main/app/**/*.jsx", "apps/admin/app/**/*.jsx"]
        tasks: ["compile"]

      main:
        files: ["apps/main/app/**/*.coffee", "apps/admin/app/**/*.coffee"]
        tasks: ["rendr_stitch"]

      aglio:
        files: ["development/docs/**/*.jade", "development/docs/**/*.md"]
        tasks: ["aglio"]

    react:
      dynamic_mappings:
        files: [
          {
            expand: true,
            cwd: 'apps/main/app/components',
            src: ['**/*.jsx'],
            dest: 'compiled/main/components',
            ext: '.js'
          },
          {
            expand: true,
            cwd: 'apps/admin/app/components',
            src: ['**/*.jsx'],
            dest: 'compiled/admin/components',
            ext: '.js'
          }
        ]
    concurrent:
      dev:
        options:
          logConcurrentOutput: true
        tasks: ["watch", "nodemon:dev"]

    rendr_stitch: stitchConfig

    uglify:
      options:
        report: "min"

      production:
        files:
          "public/compiled/mergedAssets.js": ["public/compiled/mergedAssets.js"]

    aglio:
      docs:
        files:
          "server/static_documents/docs/main": ["development/docs/main.md"]
        theme: "development/docs/blueprint-docs"
        seperator: "\n"


  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-nodemon"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-concurrent"
  grunt.registerTask "compile", ["react", "rendr_stitch"]
  grunt.registerTask "build", ["compile", "sass", "concat"]
  grunt.registerTask "prepareProductionAssets", ["compile", "sass", "concat", "uglify"]
  grunt.registerTask "dev", ["build", "concurrent:dev"]
  grunt.registerTask "default", ["dev"]
  grunt.loadNpmTasks 'grunt-react'
  grunt.loadNpmTasks('grunt-rendr-stitch');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-aglio');


  grunt.registerTask "test", (file) ->
    sh = require("execSync")
    file = file.substr(1, file.length) if file[0] is "/"
    sh.run "clear"
    command = "mocha test/setup_and_teardown.coffee #{file}"
    console.log command
    sh.run command

  grunt.registerTask "development:prepare", ->
    done = @async()
    grunt.util.spawn
      cmd: "coffee"
      args: ["development/prepare.coffee"]
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
