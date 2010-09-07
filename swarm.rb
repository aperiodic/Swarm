require 'world'
require 'pattern'
require 'patternmaker'

class Swarm < Processing::App
  load_library "control_panel"
  
  # how many runs of the world to try
  @@runs_limit = 1000
  
  # how many steps to try before giving up and resetting
  @@ticks_limit = 10000
  
  
  
  def setup
    size 400, 400
    smooth
    color_mode RGB, 1.0
    frame_rate 60
    text_font(create_font("Helvetica", 16));
    
    if ARGV.size > 0
      @mode = :cli
      @pattern = ARGV[0]
    else
      @mode = :gui
      @stage = :pattern_maker
    end
    
    if @mode == :cli
      filename = "logs/#{@pattern}/#{Time.new.strftime "%Y-%m-%d-%H%M"}.log"
      unless File.exists? 'logs'
        Dir.mkdir 'logs'
      end
      unless File.exists? "logs/#{@pattern}"
        Dir.mkdir "logs/#{@pattern}"
      end
      
      @pattern = Pattern.new "data/patterns/#{@pattern}.ptn"
        
      @log = File.open filename, 'w'
    
      @runs = 0
      reset!
    else
      @pattern_maker = PatternMaker.new
      
      control_panel do |c|
        c.slider(:hertz, 1..100, 10) { frame_rate @hertz.to_i }
        c.slider(:num_drones, 10..100, 30) { 
          @num_drones = @num_drones.to_i 
        }
        c.button :new_pattern
        c.button :start!
        c.button :reset
      end
    end
  end
  
  def new_pattern
    unless @stage == :running
      return
    end
    
    @pattern_maker = PatternMaker.new
    @stage = :pattern_maker
  end
  
  # called when the "reset" button is pressed.
  # sets the @should_reset semaphore, which is checked at the end of each frame.
  # this way, we don't reset in the middle of a step and muck everything up
  def reset
    if @stage == :running
      @should_reset = true
    end
  end
  
  def start!
    if @stage == :pattern_maker
      # we do not allow the empty pattern
      if @pattern_maker.data.select{|c| !! c}.size > 0
        @pattern = Pattern.new(@pattern_maker.width, 
                               @pattern_maker.height,
                               @pattern_maker.data)
        reset!
      end
    end
  end
  
  def reset!
    if @mode == :cli
      @num_drones = new_drone_count
    end
    
    @world = World.new 20, 20
    (0 ... @num_drones).each do |n|
      @world.spawn_drone
    end
    @world.pattern = @pattern
    
    @stage = :running
  end
  
  def new_drone_count
    (rand(18) + 2) * 5
  end
  
  
  ### DRAW (AKA MAIN) ##########################################################
  
  def draw
    background 1.0
    
    if @mode == :gui
      if @stage == :running
        @world.tick
        @world.draw
        
        if @should_reset
          @should_reset = false
          reset!
        end
      else
        # if not running, display an interface for the user to create a pattern
        @pattern_maker.draw
      end
    end
    
    if @mode == :cli 
      # if we're being run from the command line, don't display anything, just
      # keep advancing the simulation until the pattern is created or we give up
      while not (@world.pattern? or @world.ticks >= @@ticks_limit)
        @world.tick
      end
      
      if @world.pattern?
        # yay, the pattern was created! log the drone count and tick number.
        @log.puts "#{@num_drones}, #{@world.ticks}"
        
        # flash a green frame
        background 0.0, 1.0, 0.0
      else
        # boo, we've run this for a while and the pattern hasn't shown up.
        # log the drone count and failure.
        @log.puts "#{@num_drones}, failure"
        
        # flash a red frame
        background 1.0, 0.0, 0.0
      end
      
      @runs += 1
      if @runs >= @@runs_limit
        @log.close
        exit
      end
      
      reset!
    end
  end
  
  
  ### EVENT HANDLERS ###########################################################
  
  def mouse_pressed
    if @stage == :pattern_maker and @pattern_maker
      @pattern_maker.mouse_pressed
    end
  end
  
  def key_pressed
    if @stage == :pattern_maker and @pattern_maker
      # 65535 means the key is coded, so we should send the key code
      if key == 65535
        @pattern_maker.key_pressed key_code
      else 
        @pattern_maker.key_pressed key
      end
    end
  end
end

Swarm.new :title => "Swarm" 
