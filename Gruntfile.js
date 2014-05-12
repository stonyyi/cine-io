module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    sass: {
      options: {
        includePaths: ['bower_components/foundation/scss']
      },
      dist: {
        options: {
          outputStyle: 'compressed'
        },
        files: {
          'public/css/app.css': 'scss/app.scss'
        }
      }
    },

    watch: {
      grunt: { files: ['Gruntfile.js'] },

      sass: {
        files: 'scss/**/*.scss',
        tasks: ['sass']
      }
    }
  });

  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('build', ['sass']);
  grunt.registerTask('default', ['build','watch']);

  grunt.registerTask("test", function(fileWithLeadingSlashFromSublime) {
    var command, file, sh;
    sh = require('execSync');
    if (fileWithLeadingSlashFromSublime[0] === '/')
      file = fileWithLeadingSlashFromSublime.substr(1, fileWithLeadingSlashFromSublime.length);
    else
      file = fileWithLeadingSlashFromSublime
    sh.run('clear');
    command = "mocha test/setup_and_teardown.coffee " + file;
    console.log(command);
    return sh.run(command);
  });

}
