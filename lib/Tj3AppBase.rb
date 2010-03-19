#!/usr/bin/env ruby -w
# encoding: UTF-8
#
# = Tj3AppBase.rb -- The TaskJuggler III Project Management Software
#
# Copyright (c) 2006, 2007, 2008, 2009, 2010 by Chris Schlaeger <cs@kde.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#

require 'rubygems'
require 'optparse'
require 'Tj3Config'
require 'RuntimeConfig'
require 'TjTime'
require 'TextFormatter'

class TaskJuggler

  class Tj3AppBase

    def initialize
      # Indent and width of options. The deriving class may has to change
      # this.
      @optsSummaryWidth = 22
      @optsSummaryIndent = 5
      # Show some progress information by default
      @silent = false
      @configFile = nil
    end

    def processArguments(argv)
      @opts = OptionParser.new
      @opts.summary_width = @optsSummaryWidth
      @opts.summary_indent = ' ' * @optsSummaryIndent

      @opts.banner = "#{AppConfig.softwareName} v#{AppConfig.version} - " +
                     "#{AppConfig.packageInfo}\n\n" +
                     "Copyright (c) #{AppConfig.copyright.join(', ')}" +
                     " by #{AppConfig.authors.join(', ')}\n\n" +
                     "#{AppConfig.license}\n" +
                     "For more info about #{AppConfig.softwareName} see " +
                     "#{AppConfig.contact}\n\n" +
                     "Usage: #{AppConfig.appName} [options]\n\n"
      @opts.separator ""
      @opts.on('-c', '--config <FILE>', String,
               format('Use the specified YAML configuration file')) do |arg|
         @configFile = arg
      end
      @opts.on('--silent',
               format("Don't show program and progress information")) do
        @silent = true
      end

      yield

      @opts.on_tail('-h', '--help', format('Show this message')) do
        puts @opts.to_s
        exit 0
      end
      @opts.on_tail('--version', format('Show version info')) do
        puts "#{AppConfig.softwareName} v#{AppConfig.version} - " +
          "#{AppConfig.packageInfo}"
        exit 0
      end

      begin
        files = @opts.parse(argv)
      rescue OptionParser::ParseError => msg
        puts @opts.to_s + "\n"
        $stderr.puts msg
        exit 0
      end

      files
    end

    def main
      # Install signal handler to exit gracefully on CTRL-C.
      Kernel.trap('INT') do
        puts "\nAborting on user request!"
        exit 1
      end

      processArguments(ARGV)

      unless @silent
        puts "#{AppConfig.softwareName} v#{AppConfig.version} - " +
             "#{AppConfig.packageInfo}\n\n" +
             "Copyright (c) #{AppConfig.copyright.join(', ')}" +
             " by #{AppConfig.authors.join(', ')}\n\n" +
             "#{AppConfig.license}\n"
      end

      @rc = RuntimeConfig.new(AppConfig.packageName, @configFile)
    end

    private

    def format(str)
      indent = @optsSummaryWidth + @optsSummaryIndent + 1
      TextFormatter.new(79, indent).format(str)[indent..-1]
    end

  end

end

