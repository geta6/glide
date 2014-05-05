'use strict'

jitgrunt = require 'jit-grunt'
coffeelint = require 'coffeelint'
{reporter} = require 'coffeelint-stylish'

module.exports = (grunt) ->

  jitgrunt grunt

  grunt.registerTask 'static', [ 'copy', 'stylus' ]
  grunt.registerTask 'script', [ 'coffeelint', 'coffee', 'requirejs' ]
  grunt.registerTask 'production', [ 'static', 'script' ]
  grunt.registerTask 'development', [ 'static', 'script', 'watch' ]
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

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    # static

    copy:
      release:
        files: [{
          expand: yes
          cwd: 'assets'
          src: [ '**/*', '!**/*.{coffee,styl}' ]
          dest: 'public'
          filter: 'isFile'
        }]

    stylus:
      options:
        compress: yes
      release:
        files: [{
          expand: yes
          cwd: 'assets'
          src: [ 'css/app.styl' ]
          dest: 'public'
          ext: '.css'
        }]

    # script

    coffeelint:
      options:
        arrow_spacing:
          level: 'error'
        colon_assignment_spacing:
          spacing: left: 0, right: 1
          level: 'error'
        cyclomatic_complexity:
          level: 'warn'
          value: 15
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
          cwd: 'assets'
          src: [ '**/*.coffee' ]
        }]

    coffee:
      options:
        sourceMap: yes
      release:
        files: [{
          expand: yes
          cwd: 'assets'
          src: [ '*.coffee', '**/*.coffee' ]
          dest: 'public'
          ext: '.js'
        }]

    # minifier

    requirejs:
      release:
        options:
          baseUrl: 'public/js/app'
          mainConfigFile: 'public/js/config.js'
          out: 'public/js/app.js'
          include: [ '../config' ]
          optimize: 'uglify2'
          wrap: yes
          name: '../lib/almond'
          skipModuleInsertion: no
          generateSourceMaps: yes
          preserveLicenseComments: no

    # continuous

    watch:
      options:
        livereload: yes
        interrupt: yes
      static:
        tasks: [ 'copy' ]
        files: [ 'assets/**/*', '!assets/**/*.{coffee,styl}' ]
      coffee:
        tasks: [ 'coffeelint', 'coffee', 'requirejs' ]
        files: [ 'assets/**/*.coffee' ]
      stylus:
        tasks: [ 'stylus' ]
        files: [ 'assets/**/*.styl' ]

