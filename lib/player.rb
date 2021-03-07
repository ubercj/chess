class Player
  attr_accessor :name, :color, :king_position
  def initialize(name = nil, color = nil, king_position = nil)
    @name = name
    @color = color
    @king_position = king_position
  end
end

class Computer < Player
  attr_accessor :name, :color, :king_position
  def initialize(name = "Computer", color = nil, king_position = nil)
    @name = name
    @color = color
    @king_position = king_position
  end
end