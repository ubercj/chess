class Piece
  attr_reader :name, :color, :symbol
  def initialize(name, color, symbol)
    @name = name
    @color = color
    @symbol = symbol
  end
end

class Pawn < Piece
  attr_accessor :passant_vulnerable
  def initialize(name, color, symbol)
    super
    @passant_vulnerable = false
  end
end

class King < Piece
  attr_accessor :has_moved
  def initialize(name, color, symbol)
    super
    @has_moved = false
  end
end

class Rook < Piece
  attr_accessor :has_moved
  def initialize(name, color, symbol)
    super
    @has_moved = false
  end
end