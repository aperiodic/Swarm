require 'drone'
require 'pattern'

class World
  
  @@grid_size = 20
  
  attr_accessor :pattern
  attr_reader :ticks, :width, :height
  def pattern?; @pattern_created; end
  
  def initialize(width, height)
    @width, @height = width, height
    @drones = []
    @grid = Array.new @width*@height
    @ticks = 0
    @pattern_created = false
  end
  
  # creates a new drone at a random location
  # @return [Drone] the new drone
  def spawn_drone
    drone = Drone.new self
    @grid[drone.y * @width + drone.x] = drone
    @drones.push drone
    drone
  end
  
  # a simple predicate to determine if the given grid cell is filled
  def filled?(x, y)
    !! get(x, y)
  end
  
  # grabs the drone at grid cell x, y, modulo the width/height
  # @return [Drone] the drone at that grid cell, or nil if the cell is empty.
  def get(x, y)
    x = x % @width
    y = y % @height
    @grid[y * @width + x]
  end
  
  # @return [Array] an array of empty grid cell coords, where the coords are a
  #                 two-member array, the first being x, and the second y.
  def open_positions
    pos = []
    @grid.each_with_index do |cell, i|
      unless cell
        pos.push({:x => i % @width, :y => i/@width})
      end
    end
    pos
  end
  
  # advance the world's state
  def tick
    # have each drone make their move
    @drones.each do |drone|
      drone.step
    end
    
    # while two or more drones share the same cell...
    while conflicts = conflicting_drones 
      conflicts.each do |conflict|
        # ... move every drone in each overoccupied cell back to its old cell
        conflict.each do |drone|
          drone.x = drone.old_x
          drone.y = drone.old_y
        end
      end
    end
    
    # update the grid with the new drone locations
    @grid = Array.new(@width*@height)
    @drones.each do |drone|
      @grid[drone.y * @width + drone.x] = drone
      if drone.in_pattern?
        @pattern_created = true
      end
    end
    
    @ticks += 1
  end
  
  def draw
    @grid.each_with_index do |drone, i|
      x = i % @width * @@grid_size
      y = i / @width * @@grid_size
      
      $app.stroke 0.1
      $app.stroke_weight 1
      if drone
        if drone.in_pattern?
          # gold if the drone is part of an instance of the pattern...
          $app.fill(0.95, 0.85, 0.1, 0.75)
        else
          # ... grey if it's not
          $app.fill(0.1, 0.5)
        end
      else
        $app.no_fill
      end
      
      $app.rect x, y, @@grid_size, @@grid_size
    end
    
  end
  
  
  private
  
  # @return [Array] a list of lists of drones which share the same grid cell
  def conflicting_drones
    conflicts = []
    
    @drones.each do |drone|
      # filter the list of drones to get all those in the same cell as this one
      d_conflicts = @drones.select{|d| d.x == drone.x and d.y == drone.y}
      
      # the drone itself will be in this list (since we didn't take it out 
      # before filtering), so there's only a conflict if the list size is > 1
      if d_conflicts.size > 1
        conflicts.push d_conflicts
      end
    end
    
    # make sure we return nil if there are no conflicts, instead of the empty
    # array (which evaluates to true in a boolean context)
    if conflicts.size > 0
      return conflicts
    else
      return nil
    end
  end
  
  
end
