require 'pattern'

class Array
  def random
    self[rand(self.size)]
  end
end

class Drone
  
  @@dirs = [:left, :right, :up, :down, :none]
  @@deltas = {
    :left   => {:x => -1, :y =>  0},
    :right  => {:x =>  1, :y =>  0},
    :up     => {:x =>  0, :y => -1},
    :down   => {:x =>  0, :y =>  1},
    :none   => {:x =>  0, :y =>  0}
  }
  
  
  attr_accessor :x, :y, :old_x, :old_y, :pattern, :world
  def in_pattern?; @in_pattern; end
  
  def initialize(world)
    @world = world
    pos = @world.open_positions.random
    @x = pos[:x]
    @y = pos[:y]
    @old_x = pos[:x]
    @old_y = pos[:y]
    
    @steps_matched = 0
    @wait_limit = new_wait_limit
    
    @in_pattern = false
  end
  
  
  def step
    @old_x = @x
    @old_y = @y
    
    ptn = @world.pattern
    a_local_match = false
    
    # go through all the positions in the pattern which should be filled
    ptn.positions.each do |px, py|
      local_match = true
      global_match = true
      
      # see how many other position patterns are filled
      ptn.positions.each do |nx, ny|
        # test for a drone in the expected location...
        unless @world.filled?(@x + nx-px, @y + ny-py)
          # no drone there! definitely not a global match
          global_match = false
          
          # if the location is an immediate neighbor, no local match either
          unless (px - nx).abs > 1 or (py - ny).abs > 1
            local_match = false
          end
        end
      end
      
      if global_match
        @in_pattern = true
      end
      
      if local_match
        a_local_match = true
      end
    end
    
    # if we're in pattern, don't move
    if @in_pattern
      return
    end
    
    # if our local area matches, don't move unless we've been here a while
    if a_local_match and @steps_matched < @wait_limit
      @steps_matched += 1
      return
    end
    
    @wait_limit = new_wait_limit
    @steps_matched = 0
    
    # otherwise, take a random walk
    dir = @@dirs.random
    @x = (@x + @@deltas[dir][:x]) % @world.width
    @y = (@y + @@deltas[dir][:y]) % @world.height
  end
  
  def neighbors
    ns = []
    (@x-1 .. @x+1).each do |x|
      (@y-1  .. @y+1).each do |y|
        if @world.filled? x, y
          ns.push @world.get x, y
        end
      end
    end
    
    ns
  end
  
  def neighbor_matches
    return neighbors.select{|n| n.partial_match}.size > 0
  end
  
  def new_wait_limit
    rand(20) + 80
  end
  
end
