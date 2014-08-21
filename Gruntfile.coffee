module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        expand: true
        flatten: true
        src: './src/*.coffee'
        dest: './dist'
        ext: '.js'

    clean:
      cleanup: ['./dist']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'default', ['coffee']
