require './lib/board'
require './lib/space'
require './lib/piece'
require './lib/player'

describe Board do
  subject(:test_board) { described_class.new }
  
  describe "game_over?" do
    let(:test_player) { instance_double(Player, color: :black) }

    context "when a player is in checkmate" do
      it "returns :checkmate" do
        allow(test_board).to receive(:checkmate?).and_return(true)
        answer = test_board.game_over?(test_player)
        expect(answer).to eq(:checkmate)
      end
    end

    context "when there is a stalemate" do
      it "returns :stalemate" do
        allow(test_board).to receive(:checkmate?).and_return(false)
        allow(test_board).to receive(:stalemate?).and_return(true)
        answer = test_board.game_over?(test_player)
        expect(answer).to eq(:stalemate)
      end
    end

    context "when the game is not over" do
      it "returns false" do
        allow(test_board).to receive(:checkmate?).and_return(false)
        allow(test_board).to receive(:stalemate?).and_return(false)
        answer = test_board.game_over?(test_player)
        expect(answer).to be false
      end
    end
  end
  
  describe "#check?" do
    subject(:test_board) { described_class.new }
    let(:test_player) { Player.new("Chad", :white, [4, 0]) }
    context "when a black piece can take the white king next turn" do
      before do
        allow($stdout).to receive(:write)
        test_board.set_square(3, 1, Piece.new("queen", :black, "\u{265B}"))
      end

      it "returns true" do
        answer = test_board.check?(test_player)
        expect(answer).to be true
      end
    end
    
    context "when the white king cannot be taken by a black piece next turn" do
      it "returns false" do
        answer = test_board.check?(test_player)
        expect(answer).to be false
      end
    end

    context "when the white king is threatened and then moves to a safe space" do
      before do
        allow($stdout).to receive(:write)
        test_board.current_king = [3, 4]
        test_board.set_square(4, 5, Piece.new("queen", :black, "\u{265B}"))
      end

      it "returns true at first" do
        answer = test_board.check?(test_player)
        expect(answer).to be true
      end

      it "returns false when the king moves to safety" do
        test_board.current_king = [3, 3]
        answer = test_board.check?(test_player)
        expect(answer).to be false
      end
    end
  end

  describe "#checkmate?" do
    subject(:test_board) { described_class.new }
    let(:test_player) { Player.new("Juan", :black, [4, 7]) }
    context "when the black king is in check and no move can be made to escape it" do
      before do
        allow($stdout).to receive(:write)
        test_board.current_king = [4, 7]
        test_board.set_square(3, 7, nil)
        test_board.set_square(2, 7, Piece.new("rook", :white, "\u{2656}"))
      end

      it "returns true" do
        answer = test_board.checkmate?(test_player)
        expect(answer).to be true
      end
    end

    context "when the black king is in check but it is possible to escape" do
      before do
        allow($stdout).to receive(:write)
        test_board.current_king = [4, 4]
        test_board.set_square(4, 4, Piece.new("king", :black, "\u{265A}"))
        test_board.set_square(6, 2, Piece.new("bishop", :white, "\u{2657}"))
      end
      
      it "returns false" do
        answer = test_board.checkmate?(test_player)
        expect(answer).to be false
      end
    end

    context "when the black king is in check, he can't escape, but another black piece can move in the way of the attacker" do
      before do
        allow($stdout).to receive(:write)
        test_board.current_king = [4, 7]
        test_board.set_square(3, 7, nil)
        test_board.set_square(2, 7, Piece.new("rook", :white, "\u{2656}"))
        test_board.set_square(3, 6, Piece.new("rook", :black, "\u{265C}"))
      end

      it "returns false" do
        answer = test_board.checkmate?(test_player)
        expect(answer).to be false
      end
    end

    context "when the black king is not in check" do
      it "returns false" do
        allow($stdout).to receive(:write)
        answer = test_board.checkmate?(test_player)
        expect(answer).to be false
      end
    end
  end

  describe "#stalemate?" do
    context "when the black king is not in check, but any possible move will result in check" do
      empty_board = Array.new(8) { Array.new(8) { Space.new } }
      subject(:test_board) { described_class.new(empty_board) }
      let(:test_player) { Player.new("Juan", :black, [0, 3]) }

      before do
        allow($stdout).to receive(:write)
        test_board.current_king = [0, 3]
        test_board.set_square(0, 3, Piece.new("king", :black, "\u{265A}"))
        test_board.set_square(2, 4, Piece.new("queen", :white, "\u{2655}"))
        test_board.set_square(2, 2, Piece.new("rook", :white, "\u{2656}"))
      end

      it "returns true" do
        answer = test_board.stalemate?(test_player)
        expect(answer).to be true
      end
    end

    context "when the black king can't make a move and neither can other black pieces" do
      empty_board = Array.new(8) { Array.new(8) { Space.new } }
      subject(:test_board) { described_class.new(empty_board) }
      let(:test_player) { Player.new("Juan", :black, [0, 3]) }

      before do
        allow($stdout).to receive(:write)
        test_board.current_king = [0, 3]
        test_board.set_square(0, 3, Piece.new("king", :black, "\u{265A}"))
        test_board.set_square(2, 4, Piece.new("queen", :white, "\u{2655}"))
        test_board.set_square(2, 2, Piece.new("rook", :white, "\u{2656}"))
        test_board.set_square(7, 0, Piece.new("pawn", :black, "\u{265F}"))
        test_board.set_square(7, 1, Piece.new("pawn", :white, "\u{2659}"))
      end

      it "returns true" do
        answer = test_board.stalemate?(test_player)
        expect(answer).to be true
      end
    end

    context "when all available moves put the black king in check" do
      empty_board = Array.new(8) { Array.new(8) { Space.new } }
      subject(:test_board) { described_class.new(empty_board) }
      let(:test_player) { Player.new("Juan", :black, [0, 3]) }

      before do
        allow($stdout).to receive(:write)
        test_board.current_king = [0, 3]
        test_board.set_square(0, 3, Piece.new("king", :black, "\u{265A}"))
        test_board.set_square(1, 3, Piece.new("pawn", :black, "\u{265F}"))
        test_board.set_square(3, 2, Piece.new("rook", :white, "\u{2656}"))
        test_board.set_square(3, 3, Piece.new("rook", :white, "\u{2656}"))
        test_board.set_square(3, 4, Piece.new("rook", :white, "\u{2656}"))
      end

      it "returns true" do
        answer = test_board.stalemate?(test_player)
        expect(answer).to be true
      end
    end

    context "when there is a legal move available" do
      subject(:test_board) { described_class.new }
      let(:test_player) { Player.new("Juan", :black, [4, 7]) }

      it "returns false" do
        allow($stdout).to receive(:write)
        answer = test_board.stalemate?(test_player)
        expect(answer).to be false
      end
    end
  end

  describe "#select_piece" do
    context "when a player selects the wrong color piece, then a correct color piece" do
      subject(:test_board) { described_class.new }
      let(:test_player) { instance_double(Player, :color => :black) }
      before do
        allow($stdout).to receive(:write)
        white_coordinates = {x: 4, y: 1}
        black_coordinates = {x: 4, y: 6}
        allow(test_board).to receive(:get_coordinates).and_return(white_coordinates, black_coordinates)
        allow(test_board).to receive(:no_valid_moves?).and_return(false)
      end

      it "puts an error message" do
        expect(test_board).to receive(:wrong_color_error)
        test_board.select_piece(test_player)
      end

      it "receives get_moves once" do
        expect(test_board).to receive(:get_moves).once
        test_board.select_piece(test_player)
      end  
    end
  end

  describe "#select_destination" do
    subject(:test_board) { described_class.new }
    player_color = :white
    player_king = [4, 0]
    let(:test_player) { Player.new("John", :white, [4, 0]) }

    context "when a piece makes a legal move to an empty space" do
      before do
        allow($stdout).to receive(:write)
        destination = {x: 4, y: 5}
        white_pawn = Piece.new("pawn", :white, "\u{2659}")
        test_board.set_square(4, 4, white_pawn)
        test_board.set_marker(4, 5, "*")
        allow(test_board).to receive(:get_coordinates).and_return(destination)
      end

      it "changes the destination square's value to the piece object" do
        starting_space = test_board.get_square(4, 4)
        test_board.select_destination(test_player, [4, 4])
        result = test_board.get_square(4, 5).contents.name
        expect(result).to eq("pawn")
      end

      it "changes the origin square's value to nil" do
        starting_space = test_board.get_square(4, 4)
        test_board.select_destination(test_player, [4, 4])
        result = test_board.get_square(4, 4).contents
        expect(result).to be_nil
      end
    end

    context "when en passant is possible" do
      before do
        allow($stdout).to receive(:write)
        destination = {x: 5, y: 5}
        test_board.set_square(4, 4, Pawn.new("pawn", :white, "\u{2659}"))
        test_board.set_square(5, 4, Pawn.new("pawn", :black, "\u{265F}"))
        test_board.set_marker(5, 5, "@")
        allow(test_board).to receive(:get_coordinates).and_return(destination)
      end

      it "allows the pawn to move diagonally into the empty space" do
        white_pawn = test_board.get_square(4, 4).contents
        black_pawn = test_board.get_square(5, 4).contents
        black_pawn.passant_vulnerable = true
        starting_space = test_board.get_square(4, 4)
        test_board.select_destination(test_player, [4, 4])
        result = test_board.get_square(5, 5).contents
        expect(result).to eq(white_pawn)
      end

      it "deletes the passed pawn" do
        black_pawn = test_board.get_square(5, 4).contents
        black_pawn.passant_vulnerable = true
        starting_space = test_board.get_square(4, 4)
        test_board.select_destination(test_player, [4, 4])
        result = test_board.get_square(5, 4).contents
        expect(result).to be_nil
      end
    end
  end

  describe "#get_coordinates" do
    it "returns x: 3 and y: 0 when d1 is given" do
      allow(test_board).to receive(:gets).and_return("d1")
      user_input = "d1"
      result = test_board.get_coordinates
      expect(result).to eq({x: 3, y: 0})
    end
  end

  describe "#get_square" do
    context "with the starting board" do
      it "returns the white queen when given 3, 0" do
        x = 3
        y = 0
        result = test_board.get_square(x, y).contents.symbol
        expect(result).to eq("\u{2655}")
      end
    end
  end

  describe "#set_square" do
    it "changes the contents of the chosen space" do
      x = 0
      y = 7
      new_contents = "dummy"
      test_board.set_square(x, y, new_contents)
      result = test_board.get_square(x, y).contents
      expect(result).to eq("dummy")
    end
  end

  describe "#get_moves" do
    subject(:test_board) { described_class.new }
    context "when a pawn has an empty space in front of it" do
      before do
        allow($stdout).to receive(:write)
        white_pawn = Piece.new("pawn", :white, "\u{2659}")
        test_board.set_square(4, 4, white_pawn)
      end

      it "adds a marker to the space in front" do
        test_board.get_moves(4, 4)
        result = test_board.get_square(4, 5).marker
        expect(result).to eq('*')
      end
    end
    
    context "when a pawn is diagonally in front of an opposing piece" do
      before do
        allow($stdout).to receive(:write)
        white_pawn = Piece.new("pawn", :white, "\u{2659}")
        test_board.set_square(4, 5, white_pawn)
      end

      it "adds a marker where the opposing piece is" do
        test_board.get_moves(4, 5)
        result = test_board.get_square(5, 6).marker
        expect(result).to eq('!')
      end
    end

    context "when a pawn is in its starting position" do
      before do
        allow($stdout).to receive(:write)
        black_pawn = Piece.new("pawn", :black, "\u{265F}")
        test_board.set_square(2, 6, black_pawn)
      end
    
      it "adds a marker two spaces ahead" do
        test_board.get_moves(2, 6)
        result = test_board.get_square(2, 4).marker
        expect(result).to eq('*')
      end
    end

    context "when a king is chosen" do
      context "when all surrounding spaces are empty" do
        before do
          allow($stdout).to receive(:write)
          black_king = Piece.new("king", :black, "\u{265A}")
          test_board.set_square(3, 4, black_king)
        end

        it "adds a marker to all surrounding spaces" do
          test_board.get_moves(3, 4)
          result = []
          result << test_board.get_square(4, 4).marker
          result << test_board.get_square(2, 4).marker
          result << test_board.get_square(4, 5).marker
          result << test_board.get_square(4, 3).marker
          result << test_board.get_square(4, 5).marker
          result << test_board.get_square(4, 3).marker
          result << test_board.get_square(3, 5).marker
          result << test_board.get_square(3, 3).marker
          answer = result.all? { |item| item == "*" }
          expect(answer).to be true
        end
      end
    end
  end

  describe "#on_board?" do
    it "returns true when the selected coordinates are on the board" do
      x = 7
      y = 0
      result = test_board.on_board?(x, y)
      expect(result).to be true
    end

    it "returns false when the selected coordinates are not on the board" do
      x = 9
      y = 0
      result = test_board.on_board?(x, y)
      expect(result).to be false
    end
  end

  describe "#has_piece?" do
    it "returns :white if there is a white piece in the given space" do
      x = 0
      y = 0
      result = test_board.has_piece?(x, y)
      expect(result).to eq(:white)
    end

    it "returns :black if there is a black piece in the given space" do
      x = 0
      y = 7
      result = test_board.has_piece?(x, y)
      expect(result).to eq(:black)
    end

    it "returns false if the space is empty" do
      space_to_check = test_board.grid[4][0]
      x = 0
      y = 4
      result = test_board.has_piece?(x, y)
      expect(result).to be false
    end
  end
end