require "ucc/version"
require "optparse"

module Ucc
  WINDOWS = !!((`uname` rescue "") =~ /^$|windows/)
  CURRENT_EXECUTABLE = File.basename($0)

  class Runner
    attr_reader :source_files
    
    def initialize(compiler)
      @compiler = compiler
      raise "Compiler must be specified" unless @compiler
      parse_options
      work
    end
    
    # Variables
    # =========
    
    def optparse
      @optparse ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{CURRENT_EXECUTABLE} [options] file..."
        
        options[:runopts] = nil
        opts.on( '-r', '--runopts "STRING"', 'Pass STRING as the command line arguments to the app' ) do |s|
          options[:runopts] = s
        end
        
        options[:memcheck] = false
        opts.on( '-V', '--valgrind', 'Run the app in valgrind' ) do
          options[:memcheck] = true
        end
        
        opts.on( '-v', '--version', 'Show app version' ) do
          puts "#{__FILE__} #{VERSION}"
          exit
        end
        
        opts.on( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end
    end
    
    def options
      @options ||= {}
    end
    
    def app_filename
      return @app_filename if @app_filename
      @app_filename = source_files[0].sub(/\.\w+$/, '')
      @app_filename += ".exe" if WINDOWS
    end
    
    # Main logic
    # ==========
    
    def parse_options
      optparse.parse!
      
      # Here we have already parsed ARGV
      @source_files = ARGV
      if @source_files.empty?
        #puts optparse
        puts "#{CURRENT_EXECUTABLE}: no input files"
        exit(1)
      end
    end
    
    def work
      exit unless system(%Q[#{@compiler} -Wall -o "#{app_filename}" #{source_files.map{ |f| '"'+f+'"' }.join(" ")}])
      
      exec_params = app_filename
      exec_params = "./#{exec_params}" unless WINDOWS
      exec_params = "#{exec_params} #{options[:runopts]}" if options[:runopts]
      exec_params = "valgrind #{exec_params}" if options[:memcheck]
      puts "=== Compiled successfully, executing... === "
      exec exec_params
    end
  
  end
end
