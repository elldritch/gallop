module.exports = (grunt) ->
  grunt.initConfig {
    coffee:
      compile:
        files:
          'dist/daemon.js': 'src/*.coffee'
  }

  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'default', ['coffee']