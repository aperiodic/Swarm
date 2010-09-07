require 'utils'

class PatternMaker
  include Utils
  
  attr_reader :width, :height, :data
  
  @@key_codes = {
    38 => :up,
    40 => :down,
    37 => :left,
    39 => :right,
  }
    
  def initialize
    @width = 3
    @height = 3
    
    calculate_dimensions
  end
  
  def calculate_dimensions
    @data = Array.new(@width*@height)
    
    aw = $app.width 
    ah = $app.height - 100
    
    @block_size = min(aw / @width, ah / @height).to_i
    
    @margin_x = (aw - @block_size * @width) / 2 
    @margin_y = (ah - @block_size * @height) / 2
  end
  
  def draw
    
    # draw instructions
    $app.fill 0
    $app.no_stroke
    $app.text "Click on cells to toggle their state.", 5, 20
    $app.text "Use arrow keys to change pattern size.", 5, 40
    $app.text "Press 'start' to begin!", 5, 60
    
    # draw the pattern
    $app.push_matrix
    $app.translate @margin_x, @margin_y + 100
    
    $app.stroke 0
    $app.stroke_weight 1
    
    (0 ... @width).each do |x|
      (0 ... @height).each do |y|
        if @data[y * @width + x]
          $app.fill(0.1, 0.5)
        else
          $app.no_fill
        end
        
        $app.rect x*@block_size, y*@block_size, @block_size, @block_size
      end
    end
    $app.pop_matrix
  end
  
  def mouse_pressed
    ptn_x = ($app.mouse_x - @margin_x) / @block_size
    ptn_y = ($app.mouse_y - @margin_y - 100) / @block_size
    ptn_index = ptn_y * @width + ptn_x
    @data[ptn_index] = (not @data[ptn_index])
  end
  
  def key_pressed(key)
    key = @@key_codes[key] || key
    if key == :left and @width > 1
      @width -= 1
    elsif key == :right
      @width += 1
    elsif key == :down and @height > 1
      @height -= 1
    elsif key == :up
      @height += 1
    end
    calculate_dimensions
  end
  
end
