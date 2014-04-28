module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-node-webkit-builder'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask 'default', [
    'copy', 'jade', 'stylus', 'coffeelint', 'coffee', 'uglify', 'nodewebkit'
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

    coffeelint:
      options:
        arrow_spacing:
          level: 'error'
        colon_assignment_spacing:
          spacing: left: 0, right: 1
          level: 'error'
        cyclomatic_complexity:
          level: 'warn'
        empty_constructor_needs_parens:
          level: 'error'
        indentation:
          value: 2
        max_line_length:
          value: 79
        newlines_after_classes:
          level: 'error'
        no_empty_functions:
          level: 'warn'
        no_empty_param_list:
          level: 'error'
        no_interpolation_in_single_quotes:
          level: 'warn'
        no_unnecessary_double_quotes:
          level: 'warn'
        no_unnecessary_fat_arrows:
          level: 'error'
        space_operators:
          level: 'warn'
      assets:
        files: [{
          expand: yes
          cwd: 'src'
          src: [ '*.coffee', '**/*.coffee' ]
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

    compress:
      osx:
        options:
          archive: "release/teitoku-#{pkg.version}-osx.zip"
        files: [{
          expand: yes
          cwd: 'build/releases/Teitoku/mac'
          src: [ '**' ]
          dest: 'teitoku-osx'
          filter: 'isFile'
        }]
      win:
        options:
          archive: "release/teitoku-#{pkg.version}-win32.zip"
        files: [{
          expand: yes
          cwd: 'build/releases/Teitoku/win'
          src: [ '**' ]
          dest: 'teitoku-win32'
          filter: 'isFile'
        }]
      linux32:
        options:
          archive: "release/teitoku-#{pkg.version}-linux32.zip"
        files: [{
          expand: yes
          cwd: 'build/releases/Teitoku/linux32'
          src: [ '**' ]
          dest: 'teitoku-linux32'
          filter: 'isFile'
        }]
      linux64:
        options:
          archive: "release/teitoku-#{pkg.version}-linux64.zip"
        files: [{
          expand: yes
          cwd: 'build/releases/Teitoku/linux64'
          src: [ '**' ]
          dest: 'teitoku-linux64'
          filter: 'isFile'
        }]

