module.exports = (grunt) ->

  packageJSON = grunt.file.readJSON 'package.json'

  grunt.initConfig({
    pkg: packageJSON,

    jade:
      options:
        data: packageJSON,
      dist:
        src: 'src/index.jade',
        dest: 'dist/index.html'

    sass:
      options:
        style: 'compressed',
        precision: 4
        # Source maps require SASS 3.3.0
        # sourcemap: true
      dist:
        src: 'src/acc.sass',
        dest: 'dist/acc.css'

    coffee:
      options:
        sourceMap: true
      dist:
        src: 'src/acc.coffee',
        dest: 'dist/acc.js'

    autoprefixer:
      options: ['last 2 versions']
      dist:
        src: 'dist/*.css'

    watch:
      jade:
        files: 'src/*.jade',
        tasks: 'jade'
      sass:
        files: 'src/*.sass',
        tasks: 'sass'
      coffee:
        files: 'src/*.coffee',
        tasks: 'coffee'
      autoprefixer:
        files: 'dist/*.css',
        tasks: 'autoprefixer'
      livereload:
        options:
          livereload: true
        files: 'dist/*.{html,css,js}'
  })

  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-autoprefixer'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['jade', 'sass', 'coffee', 'autoprefixer']
  grunt.registerTask 'dist', 'default'
  grunt.registerTask 'd', 'dist'
  grunt.registerTask 'w', 'watch'
