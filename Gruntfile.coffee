_ = require('underscore')
rendrDir = 'node_modules/rendr';
rendrHandlebarsDir = 'node_modules/rendr-handlebars';
rendrModulesDir = rendrDir + '/node_modules';

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
          "public/compiled/app.css": "assets/stylesheets/app.scss"

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
        files: "assets/stylesheets/**/*.scss"
        tasks: ["sass"]
      main:
        files: ["apps/main/app/**/*.jsx", "apps/main/app/**/*.coffee"]
        tasks: ["compile"]


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
    },

    rendr_stitch:
      compile:
        options:
          dependencies: [
            'assets/vendor/jquery.js'
            'assets/vendor/jquery.easing.js'
            'assets/vendor/jquery.scrollto.js'
          ],
          npmDependencies:
            underscore: '../rendr/node_modules/underscore/underscore.js'
            backbone: '../rendr/node_modules/backbone/backbone.js'
            handlebars: '../rendr-handlebars/node_modules/handlebars/dist/handlebars.runtime.js'
            async: '../rendr/node_modules/async/lib/async.js'
          aliases: [
            {from: "apps/main/app/", to: 'app/'}
            {from: "compiled/components/", to: 'app/components/'}
            {from: "bower_components/react/react", to: 'React'}

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


  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-nodemon"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-concurrent"
  grunt.registerTask "compile", ["react", "handlebars", "rendr_stitch"]
  grunt.registerTask "build", ["compile", "sass"]
  grunt.registerTask "dev", ["build", "concurrent:dev"]
  grunt.registerTask "default", ["dev"]
  grunt.loadNpmTasks 'grunt-react'
  grunt.loadNpmTasks('grunt-contrib-handlebars');
  grunt.loadNpmTasks('grunt-rendr-stitch');

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
