require_relative "./space"
require_relative "./piece"

module SetupBoard
  module BlackPieces
    BLACK_KING = King.new("king", :black, "\u{265A}")
    BLACK_QUEEN = Piece.new("queen", :black, "\u{265B}")
    BLACK_ROOK = Rook.new("rook", :black, "\u{265C}")
    BLACK_BISHOP = Piece.new("bishop", :black, "\u{265D}")
    BLACK_KNIGHT = Piece.new("knight", :black, "\u{265E}")
    BLACK_PAWN = Pawn.new("pawn", :black, "\u{265F}")
  end
  
  module WhitePieces
    WHITE_KING = King.new("king", :white, "\u{2654}")
    WHITE_QUEEN = Piece.new("queen", :white, "\u{2655}")
    WHITE_ROOK = Rook.new("rook", :white, "\u{2656}")
    WHITE_BISHOP = Piece.new("bishop", :white, "\u{2657}")
    WHITE_KNIGHT = Piece.new("knight", :white, "\u{2658}")
    WHITE_PAWN = Pawn.new("pawn", :white, "\u{2659}")
  end

  def black_side
    [ 
      Space.new( BlackPieces::BLACK_ROOK ),
      Space.new( BlackPieces::BLACK_KNIGHT ),
      Space.new( BlackPieces::BLACK_BISHOP ),
      Space.new( BlackPieces::BLACK_QUEEN ),
      Space.new( BlackPieces::BLACK_KING ),
      Space.new( BlackPieces::BLACK_BISHOP ),
      Space.new( BlackPieces::BLACK_KNIGHT ),
      Space.new( BlackPieces::BLACK_ROOK ),
    ]
  end

  def black_pawns
    Array.new(8) { Space.new( BlackPieces::BLACK_PAWN ) }
  end

  def white_side
    [ 
      Space.new( WhitePieces::WHITE_ROOK ),
      Space.new( WhitePieces::WHITE_KNIGHT ),
      Space.new( WhitePieces::WHITE_BISHOP ),
      Space.new( WhitePieces::WHITE_QUEEN ),
      Space.new( WhitePieces::WHITE_KING ),
      Space.new( WhitePieces::WHITE_BISHOP ),
      Space.new( WhitePieces::WHITE_KNIGHT ),
      Space.new( WhitePieces::WHITE_ROOK ),
    ]
  end

  def white_pawns
    Array.new(8) { Space.new( WhitePieces::WHITE_PAWN ) }
  end

  def blank_rows
    Array.new(4) { Array.new(8) { Space.new } }
  end

  def letter_row
    ["a", "b", "c", "d", "e", "f", "g", "h"]
  end
end