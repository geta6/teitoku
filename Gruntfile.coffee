coffeelint = require 'coffeelint'
{reporter} = require 'coffeelint-stylish'

module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-node-webkit-builder'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerMultiTask 'coffeelint', 'CoffeeLint', ->
    count = e: 0, w: 0
    options = @options()
    (files = @filesSrc).forEach (file) ->
      grunt.verbose.writeln "Linting #{file}..."
      errors = coffeelint.lint (grunt.file.read file), options, !!/\.(litcoffee|coffee\.md)$/i.test file
      unless errors.length
        return grunt.verbose.ok()
      reporter file, errors
      errors.forEach (err) ->
        switch err.level
          when 'error' then count.e++
          when 'warn'  then count.w++
          else return
        message = "#{file}:#{err.lineNumber} #{err.message} (#{err.rule})"
        grunt.event.emit "coffeelint:#{err.level}", err.level, message
        grunt.event.emit 'coffeelint:any', err.level, message
    return no if count.e and !options.force
    if !count.w and !count.e
      grunt.log.ok "#{files.length} file#{if 1 < files.length then 's'} lint free."

  grunt.registerTask 'default', [
    'clean', 'copy', 'jade', 'stylus', 'coffeelint', 'coffee', 'uglify', 'nodewebkit'
  ]

  pkg = grunt.file.readJSON 'package.json'

  grunt.initConfig

    pkg: pkg

    # static

    clean:
      compile:
        src: [ 'lib' ]

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
          value: 15
          level: 'warn'
        empty_constructor_needs_parens:
          level: 'error'
        indentation:
          level: 'error'
          value: 2
        max_line_length:
          level: 'error'
          value: 79
        newlines_after_classes:
          level: 'error'
        no_empty_functions:
          level: 'warn'
        no_empty_param_list:
          level: 'error'
        no_interpolation_in_single_quotes:
          level: 'warn'
        no_stand_alone_at:
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

