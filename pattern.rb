
class Pattern
  
  attr_reader :width, :height
  
  # there are two ways to create a new pattern. 
  # 1. load it from a .ptn file. this file is a plain text file, where each
  #    line is a line of the pattern, each character being a cell.
  #    a '#' character indicates the cell should be filled, anything else, empty
  #    
  # 2. pass the data in directly. three arguments should be passed: the first
  #    two are  the width and height of the pattern, and the last an array
  #    of size width*height, whose contents are coerced to a boolean values
  def initialize(*args)
    if args.size == 1
      load_data(args[0])
    elsif args.size == 3
      @width, @height = args[0], args[1]
      @data = args[2]
      if @data.size != @width * @height
        raise <<-EOM.gsub(/^ */,'')
          Dimensions and array do not agree!
          width: #{@width}, height: #{@height}, array size: #{@data.size}
        EOM
      end
    else
      raise "Unsupported number of args: #{args.size}"
    end
  end
  
  def filled?(x, y)
    !! @data[y*width + x]
  end
  
  # returns an array of the coordinates of all filled positions in this pattern.
  # the coordinates are themselves arrays of length 2, the first member being 
  # the x coordinate value, and the second, y.
  def positions
    pos = []
    @data.each_with_index do |filled, i|
      if filled
        pos.push([i % @width, i/@width])
      end
    end
    pos
  end
  
  # prints out a text representation of this pattern, which is also a valid
  # .ptn file!
  def inspect
    (0...@height).each do |n|
      puts @data[(n*@width ... (n+1)*@width)].map{|c| c ? "#" : " "}.join
    end
    self
  end
  
  private
  
  def load_data(file)
    lines = []
    # load all the lines into an array
    File.open(file, 'r') do |pattern|
      pattern.lines.each do |line|
        lines.push line.sub /( |\n)*$/, ''
      end
    end
    
    # ignore all blank lines
    lines = lines.select{|l| l.size > 0}
    
    @height = lines.size
    @width = lines.map{|l| l.size}.sort.reverse.first
    @data = Array.new @width*@height
    
    lines.each_with_index do |line, y|
      if line.size < @width
        line = line + " " * (@width - line.size)
      end
      line.split("").each_with_index do |char, x|
        @data[y * @width + x] = char == '#'
      end
    end
  end
  
end
