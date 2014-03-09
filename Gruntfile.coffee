module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-node-webkit-builder'

  grunt.registerTask 'default', [
    'copy', 'jade', 'stylus', 'coffee', 'uglify', 'nodewebkit'
  ]

  pkg = grunt.file.readJSON 'package.json'

  grunt.initConfig

    pkg: pkg

    # static

    copy:
      compile:
        files: [{
          expand: yes
          cwd: 'src'
          src: [ '**/*', '!**/*.{coffee,styl,jade}' ]
          dest: 'lib'
        }]

    jade:
      options:
        data: pkg: pkg
      compile:
        files: [{
          expand: yes
          cwd: 'src'
          src: [ '*.jade', '**/*.jade' ]
          dest: 'lib'
          ext: '.html'
        }]

    stylus:
      options:
        compress: yes
      compile:
        files: [{
          expand: yes
          cwd: 'src'
          src: [ '*.styl', '**/*.styl' ]
          dest: 'lib'
          ext: '.css'
        }]

    coffee:
      compile:
        files: [{
          expand: yes
          cwd: 'src'
          src: [ '*.coffee', '**/*.coffee' ]
          dest: 'lib'
          ext: '.js'
        }]

    uglify:
      compile:
        files: [{
          expand: yes
          cwd: 'lib'
          src: [ '*.js', '**/*.js' ]
          dest: 'lib'
        }]

    nodewebkit:
      options:
        mac: on
        win: on
        linux32: on
        linux64: on
        version: pkg.nwversion
        app_name: pkg.name
        app_version: pkg.version
        mac_icns: 'var/teitoku.icns'
        build_dir: 'build'
      src: [ 'lib/**/*' ]

