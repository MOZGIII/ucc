require "ucc/version"
require "optparse"

module Ucc
  # Are we on windows?
  WINDOWS = !!((`uname` rescue "") =~ /^$|windows/)
  
  # What executable was used to run ucc?
  CURRENT_EXECUTABLE = File.basename($0)

  class Runner
    attr_reader :source_files
    
    # Here we pass the compiler (to be able to choose between gcc or g++)
    def initialize(compiler)
      @compiler = compiler
      raise "Compiler must be specified" unless @compiler
      parse_options
      work
    end
    
    # Variables
    # =========
    
    # Defines options for ucc
    def optparse
      @optparse ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{CURRENT_EXECUTABLE} [options] file..."
        
        options[:runopts] = nil
        opts.on( '-r', '--runopts "STRING"', 'Pass STRING as the command line argument to the compiled app' ) do |s|
          options[:runopts] = s
        end
        
        options[:compileopts] = nil
        opts.on( '-c', '--compileopts "STRING"', 'Pass STRING as the command line argument to the compiler' ) do |s|
          options[:compileopts] = s
        end
        
        options[:memcheck] = false
        opts.on( '-V', '--valgrind', 'Run the app in valgrind' ) do
          options[:memcheck] = true
        end
                
        options[:verbose] = false
        opts.on( '--verbose', 'Enable debug messages' ) do
          options[:verbose] = true
        end
        
        opts.on_tail( '-v', '--version', 'Show app version' ) do
          puts "#{CURRENT_EXECUTABLE} #{VERSION}"
          exit
        end
        
        opts.on_tail( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end
    end
    
    # Options array accessor
    def options
      @options ||= {}
    end
    
    # Filename to use when executing compiled app
    def app_filename
      return @app_filename if @app_filename
      @app_filename = source_files[0].sub(/\.\w+$/, '')
      @app_filename += ".exe" if WINDOWS
      @app_filename
    end
    
    # Main logic
    # ==========
    
    # Does option parsing using optparse
    def parse_options
      begin
        optparse.parse!
      rescue OptionParser::InvalidOption=> e
        puts "#{CURRENT_EXECUTABLE}: #{e}"
        exit(1)
      end      
      
      # Here we have already parsed ARGV
      @source_files = ARGV
      if @source_files.empty?
        puts "#{CURRENT_EXECUTABLE}: no input files"
        exit(1)
      end
    end
    
    # Everything special goes here
    def work
      compilation_params = %Q[#{@compiler} -Wall #{options[:compileopts]} -o "#{app_filename}" #{source_files.map{ |f| enquote(f) }.join(" ")}]
      trace compilation_params
      exit unless system compilation_params
      
      exec_params = enquote(app_filename)
      exec_params = "./#{exec_params}" unless WINDOWS
      exec_params = "#{exec_params} #{options[:runopts]}" if options[:runopts]
      exec_params = "valgrind #{exec_params}" if options[:memcheck]
      trace exec_params
      puts "=== Compiled successfully, executing... === "
      exec exec_params
    end
    
    # Prints text if verbose mode is on
    def trace(text)
      puts "[ucc] Debug: #{text}" if options[:verbose]
    end
    
    # Enquotes param if needed, also pre-escapes quotes that already are inside the param
    def enquote(param)
      param = param.gsub(/(["'])/, '\\\\\\1')
      param = %Q["#{param}"] if param =~ /\s/
      param
    end
  end
end
