require_relative './SetupBoard'

class Board
  include SetupBoard
  attr_accessor :grid, :current_king
  def initialize(grid = starting_board)
    @grid = grid
    @current_king = [4, 0]
  end

  def game_over?(player)
    return :checkmate if checkmate?(player)
    return :stalemate if stalemate?(player)
    false
  end

  def check?(player)
    clear_markers
    player.color == :white ? enemy_color = :black : enemy_color = :white
    attackers = get_pieces(enemy_color)
    show_danger_zone(attackers)
    return true if has_marker?(@current_king[0], @current_king[1])
    false
  end
  
  def checkmate?(player)
    return false unless check?(player)
    return false if possible_moves?(player)
    true
  end
  
  def stalemate?(player)
    return false if check?(player)
    return false if possible_moves?(player)
    true
  end
  
  def select_piece(player)
    clear_markers

    if player.is_a?(Computer)
      starting_coordinates = computer_piece_select(player)
    else
      puts "Type the coordinates of a #{player.color} piece and press enter:"
      starting_coordinates = get_coordinates
      until valid_selection?(starting_coordinates[:x], starting_coordinates[:y], player.color)
        starting_coordinates = get_coordinates
      end
    end
    
    
    x = starting_coordinates[:x]
    y = starting_coordinates[:y]

    if get_square(x, y).contents.is_a?(King)
      chance_to_castle = can_castle?(player, x, y)
      clear_markers
      if chance_to_castle == :both
        set_marker(x + 2, y, "%")
        set_marker(x - 2, y, "%")
      elsif chance_to_castle == :left
        set_marker(x - 2, y, "%")
      elsif chance_to_castle == :right
        set_marker(x + 2, y, "%")
      end
      get_moves(x, y)  
    end

    [x, y]
  end

  def computer_piece_select(player)
    pieces = get_pieces(player.color)
    until no_valid_moves? == false
      piece = pieces.sample
      x = piece[0]
      y = piece[1]
      get_moves(x, y)
    end

    { x: x, y: y }
  end
  

  def computer_destination_select(player)
    moves = available_moves
    move = moves.sample
    { x: move[0], y: move[1] }
  end

  def make_vulnerable(coordinates, y)
    space = get_square(coordinates[0], coordinates[1])
    if space.contents.color == :white && coordinates[1] == (y - 2)
      space.contents.passant_vulnerable = true
    elsif space.contents.color == :black && coordinates[1] == (y + 2)
      space.contents.passant_vulnerable = true
    end
  end

  def select_destination(player, starting_coordinates)
    starting_space = get_square(starting_coordinates[0], starting_coordinates[1])
    
    if player.is_a?(Computer)
      destination_coordinates = computer_destination_select(player)
    else
      display_markers
      puts "Type the coordinates of the available square\nwhere you would like to move and press enter:"
      destination_coordinates = get_coordinates
      until valid_destination?(destination_coordinates[:x], destination_coordinates[:y])
        destination_coordinates = get_coordinates
      end
    end
    
    x = destination_coordinates[:x]
    y = destination_coordinates[:y]
    destination_space = get_square(x, y)
    
    # store positions to temp
    destination_temp = destination_space.contents
    starting_temp = starting_space.contents
    
    # execute move
    @current_king = [x, y] if starting_space.contents.name == "king"
    make_vulnerable(starting_coordinates, y) if starting_space.contents.is_a?(Pawn)
    move_piece(starting_space, destination_space)

    if has_marker?(x, y) == :passant
      player.color == :white ? passed_pawn = get_square(x, y - 1) : passed_pawn = get_square(x, y + 1)
      passed_pawn_temp = passed_pawn.contents
      passed_pawn.contents = nil
    elsif has_marker?(x, y) == :castle
      if x == 6
        do_castle_right(player, starting_space, destination_space)
      else
        do_castle_left(player, starting_space, destination_space)
      end
    end
    
    # if #check? put things back to the way they were
    if check?(player)
      revert_board(destination_space, starting_space, destination_temp, starting_temp)
      @current_king = player.king_position
      starting_space.contents.passant_vulnerable = false if starting_space.contents.is_a?(Pawn)
      passed_pawn.contents = passed_pawn_temp if passed_pawn
      display_board unless player.is_a?(Computer)
      check_status_error unless player.is_a?(Computer)
      return true
    else
      print_computer_move(starting_coordinates, destination_coordinates) if player.is_a?(Computer)
      player.king_position = @current_king
      destination_space.contents.has_moved = true if destination_space.contents.is_a?(Rook)
      destination_space.contents.has_moved = true if destination_space.contents.is_a?(King)
      promote_pawn(x, y) if can_promote?(x, y)
      return false
    end
  end

  def print_computer_move(starting_coordinates, destination_coordinates)
    piece_name = get_square(destination_coordinates[:x], destination_coordinates[:y]).contents.name
    starting_space = convert_array_to_move(starting_coordinates)
    destination_space = convert_hash_to_move(destination_coordinates)
    puts "Computer moves #{piece_name} from #{starting_space} to #{destination_space}."
  end

  def convert_array_to_move(coordinates)
    x = letter_row[coordinates[0]]
    y = (coordinates[1] + 1).to_s
    x + y
  end

  def convert_hash_to_move(coordinates)
    x = letter_row[coordinates[:x]]
    y = (coordinates[:y] + 1).to_s
    x + y
  end

  def do_castle_right(player, starting_space, destination_space)
    player.color == :white ? y = 0 : y = 7
    rook_start = get_square(7, y)
    rook_destination = get_square(5, y)
    move_piece(rook_start, rook_destination)
  end

  def do_castle_left(player, starting_space, destination_space)
    player.color == :white ? y = 0 : y = 7
    rook_start = get_square(0, y)
    rook_destination = get_square(3, y)
    move_piece(rook_start, rook_destination)
  end

  def reset_pawn_vulnerability(player)
    player_pawns = get_pawns(player.color)
    player_pawns.each do |pawn|
      pawn_space = get_square(pawn[0], pawn[1])
      pawn_space.contents.passant_vulnerable = false
    end
  end

  def get_pawns(color)
    x = 0
    pawns = []
    until x > 7
      y = 0
      until y > 7
        pawns << [x, y] if has_piece?(x, y) == color && get_square(x, y).contents.is_a?(Pawn)
        y += 1
      end
      x += 1
    end
    pawns
  end

  def passing_pawn?(x, y)
    left_space = get_square(x - 1, y)
    right_space = get_square(x + 1, y)
    return true if has_piece?(x - 1, y) && left_space.contents.is_a?(Pawn) && left_space.contents.passant_vulnerable == true ||
    has_piece?(x + 1, y) && right_space.contents.is_a?(Pawn) && right_space.contents.passant_vulnerable == true
    false
  end

  def can_passant?(x, y)
    chosen_pawn = get_square(x, y)
    if chosen_pawn.contents.color == :white
      return false unless y == 4
    else
      return false unless y == 3
    end
    return true if passing_pawn?(x, y)
    false
  end

  def can_promote?(x, y)
    space = get_square(x, y)
    return false unless space.contents.is_a?(Pawn)
    return true if space.contents.color == :white && y == 7
    return true if space.contents.color == :black && y == 0
    false
  end

  def promote_pawn(x, y)
    puts "You can promote your pawn! Choose an option for promotion:"
    puts "(q) for queen, (r) for rook\n(b) for bishop, (k) for knight or\n(x) if you would not like to promote your pawn"
    user_input = ""
    until user_input.match(/^[qrbkx]$/)
      user_input = gets.chomp
    end
    replace_pawn(user_input, x, y)
  end

  def replace_pawn(letter, x, y)
    pawn = get_square(x, y).contents
    case letter
    when "q"
      pawn.color == :white ? set_square(x, y, WhitePieces::WHITE_QUEEN) : set_square(x, y, BlackPieces::BLACK_QUEEN)
    when "r"
      pawn.color == :white ? set_square(x, y, WhitePieces::WHITE_ROOK) : set_square(x, y, BlackPieces::BLACK_ROOK)
      get_square(x, y).contents.has_moved = true
    when "b"
      pawn.color == :white ? set_square(x, y, WhitePieces::WHITE_BISHOP) : set_square(x, y, BlackPieces::BLACK_BISHOP)
    when "k"
      pawn.color == :white ? set_square(x, y, WhitePieces::WHITE_KNIGHT) : set_square(x, y, BlackPieces::BLACK_KNIGHT)
    when "x"
    end
  end

  def move_piece(starting_space, destination_space)
    destination_space.contents = starting_space.contents
    starting_space.contents = nil
  end

  def revert_board(destination_space, starting_space, destination_temp, starting_temp)
    destination_space.contents = destination_temp
    starting_space.contents = starting_temp
  end
  
  def valid_destination?(x, y)
    if has_marker?(x, y)
      true
    else
      marker_error
      false
    end
  end
  
  def get_coordinates
    user_input = ""
    until user_input.match(/^[a-h][1-8]$/) || user_input.match(/^[qs]$/)
      user_input = gets.chomp
    end
    throw(:quit_game, :save) if user_input == "s"
    throw(:quit_game, :quit) if user_input == "q"
    { x: get_x(user_input), y: get_y(user_input) }
  end
  
  def get_square(x, y)
    grid[(7 - y)][x]
  end
  
  def set_square(x, y, new_contents)
    get_square(x, y).contents = new_contents
  end
  
  def get_moves(x, y)
    name = get_square(x, y).contents.name
    moves = {}
    case name
    when "king"
      moves = place_king_markers(x, y)
    when "queen"
      moves = place_queen_markers(x, y)
    when "rook"
      moves = place_rook_markers(x, y)
    when "bishop"
      moves = place_bishop_markers(x, y)
    when "knight"
      moves = place_knight_markers(x, y)
    when "pawn"
      moves = place_pawn_markers(x, y)
    end
    show_moves(moves)
  end

  def show_moves(moves)
    moves[:moveable].each { |coordinates| set_marker(coordinates[0], coordinates[1], '*') }
    moves[:capture].each { |coordinates| set_marker(coordinates[0], coordinates[1], '!') }
    moves[:passant].each { |coordinates| set_marker(coordinates[0], coordinates[1], '@') } if moves.has_key?(:passant)
  end
  
  def set_marker(x, y, marker)
    get_square(x, y).marker = marker
  end
  
  def on_board?(x, y)
    return true if x.between?(0, 7) && y.between?(0, 7)
    false
  end
  
  def has_piece?(x, y)
    return false unless on_board?(x, y)
    space = get_square(x, y)
    if space.contents.is_a?(Piece)
      return :white if space.contents.color == :white
      return :black if space.contents.color == :black
    else
      false
    end
  end
  
  def has_marker?(x, y)
    space = get_square(x, y)
    return false if space.marker.nil?
    return :passant if space.marker == "@"
    return :castle if space.marker == "%"
    true
  end
  
  def display_board
    counter = 8
    grid.each do |row|
      print "#{counter} "
      counter -= 1
      puts row.map { |space| space.contents.nil? ? "-" : space.contents.symbol }.join(" | ")
    end
    puts "  #{letter_row.join("   ")}"
  end
  
  def get_grid_markers
    output = []
    grid_markers = grid.each do |row|
      output << row.map { |space| space.marker }
    end
    output
    # Should I just flatten the array here?
  end
  
  def display_markers
    counter = 8
    grid.each do |row|
      print "#{counter} "
      counter -= 1
      row_arr = row.map do |space|
        if space.marker.nil?
          if space.contents.nil?
            "-"
          else
            space.contents.symbol
          end
        else
          space.marker
        end
      end
      puts row_arr.join(" | ")
    end
    puts "  #{letter_row.join("   ")}"
  end
  
  def clear_markers
    grid.each do |row|
      row.each { |space| space.marker = nil }
    end
  end
  
  def can_castle?(player, x, y)
    king = get_square(x, y).contents
    return false if king.has_moved == true
    return false if check?(player)
    left_chance = castle_left?(player, x, y)
    right_chance = castle_right?(player, x, y)
    if left_chance && right_chance
      return :both
    else
      return :left if left_chance
      return :right if right_chance
    end
    false
  end

  def show_danger_castle(player, x, y)
    player.color == :white ? enemy_color = :black : enemy_color = :white
    attackers = get_pieces(enemy_color)
    show_danger_zone(attackers)
  end
  
  def castle_right?(player, x, y)
    if player.color == :white
      return false unless rook_hasnt_moved?(7, 0)
      return false unless get_square(5, 0).contents.nil? && get_square(6, 0).contents.nil?
      danger_spaces = show_danger_castle(player, x, y)
      return false if has_marker?(5, 0) || has_marker?(6, 0)
    else
      return false unless rook_hasnt_moved?(7, 7)
      return false unless get_square(5, 7).contents.nil? && get_square(6, 7).contents.nil?
      danger_spaces = show_danger_castle(player, x, y)
      return false if has_marker?(5, 7) || has_marker?(6, 7)
    end
    true
  end
  
  def castle_left?(player, x, y)
    if player.color == :white
      return false unless rook_hasnt_moved?(0, 0)
      return false unless get_square(1, 0).contents.nil? && get_square(2, 0).contents.nil? && get_square(3, 0).contents.nil?
      danger_spaces = show_danger_castle(player, x, y)
      return false if has_marker?(2, 0) || has_marker?(3, 0)
    else
      return false unless rook_hasnt_moved?(0, 7)
      return false unless get_square(1, 7).contents.nil? && get_square(2, 7).contents.nil? && get_square(3, 7).contents.nil?
      danger_spaces = show_danger_castle(player, x, y)
      return false if has_marker?(2, 7) || has_marker?(3, 7)
    end
    true
  end
  
  def rook_hasnt_moved?(x, y)
    space = get_square(x, y)
    return false unless has_piece?(x, y) && space.contents.is_a?(Rook)
    return false if space.contents.has_moved == true
    true
  end

  private
  
  def show_danger_zone(attackers)
    attackers.each do |coordinates|
      if get_square(coordinates[0], coordinates[1]).contents.name == "pawn"
        place_pawn_captures(coordinates[0], coordinates[1])
      else
        get_moves(coordinates[0], coordinates[1])
      end
    end
  end

  def get_pieces(color)
    x = 0
    attackers = []
    until x > 7
      y = 0
      until y > 7
        attackers << [x, y] if has_piece?(x, y) == color
        y += 1
      end
      x += 1
    end
    attackers
  end
  
  def possible_moves?(player)
    saviors = find_saviors(player)
    return true if save_king?(saviors, player)
    false
  end

  def find_saviors(player)
    saviors = get_pieces(player.color)
    saviors
  end

  def savior_attempts?(savior_options, savior_space, player)
    available_moves.each do |move|
      destination = get_square(move[0], move[1])
      savior_temp = savior_space.contents
      destination_temp = destination.contents
      @current_king = move if savior_space.contents.name == "king"
      move_piece(savior_space, destination)

      if check?(player) == false
        revert_board(savior_space, destination, savior_temp, destination_temp)
        @current_king = player.king_position
        return true
      else
        revert_board(savior_space, destination, savior_temp, destination_temp)
        @current_king = player.king_position
      end
    end
    false
  end

  def save_king?(saviors, player)
    saviors.each do |savior|
      clear_markers
      savior_space = get_square(savior[0], savior[1])
      get_moves(savior[0], savior[1])
      savior_options = available_moves
      return true if savior_attempts?(savior_options, savior_space, player) 
    end
    false
  end

  def place_king_markers(x, y)
    moveable_spaces = []
    capture_spaces = []
    chosen_king = get_square(x, y)
    
    moveable_spaces << [x + 1, y] unless on_board?(x + 1, y) == false
    moveable_spaces << [x - 1, y] unless on_board?(x - 1, y) == false
    moveable_spaces << [x, y + 1] unless on_board?(x, y + 1) == false
    moveable_spaces << [x, y - 1] unless on_board?(x, y - 1) == false
    moveable_spaces << [x + 1, y + 1] unless on_board?(x + 1, y + 1) == false
    moveable_spaces << [x + 1, y - 1] unless on_board?(x + 1, y - 1) == false
    moveable_spaces << [x - 1, y + 1] unless on_board?(x - 1, y + 1) == false
    moveable_spaces << [x - 1, y - 1] unless on_board?(x - 1, y - 1) == false
    
    space_to_delete = []
    moveable_spaces.each do |position|
      if has_piece?(position[0], position[1]) == chosen_king.contents.color
        space_to_delete << position
      elsif has_piece?(position[0], position[1])
        capture_spaces << position
        space_to_delete << position
      end
    end
    space_to_delete.each { |position| moveable_spaces.delete(position) }

    { moveable: moveable_spaces, capture: capture_spaces }
  end

  def place_queen_markers(x, y)
    moveable_spaces = place_rook_markers(x, y)[:moveable] + place_bishop_markers(x, y)[:moveable]
    capture_spaces = place_rook_markers(x, y)[:capture] + place_bishop_markers(x, y)[:capture]

    { moveable: moveable_spaces, capture: capture_spaces }
  end

  def place_rook_markers(x, y)
    moveable_spaces = []
    capture_spaces = []

    x_counter = x - 1
    until on_board?(x_counter, y) == false || has_piece?(x_counter, y) == get_square(x, y).contents.color
      if has_piece?(x_counter, y)
        capture_spaces << [x_counter, y]
        break
      else
        moveable_spaces << [x_counter, y]
        x_counter -= 1
      end
    end

    x_counter = x + 1
    until on_board?(x_counter, y) == false || has_piece?(x_counter, y) == get_square(x, y).contents.color
      if has_piece?(x_counter, y)
        capture_spaces << [x_counter, y]
        break
      else
        moveable_spaces << [x_counter, y]
        x_counter += 1
      end
    end

    y_counter = y - 1
    until on_board?(x, y_counter) == false || has_piece?(x, y_counter) == get_square(x, y).contents.color
      if has_piece?(x, y_counter)
        capture_spaces << [x, y_counter]
        break
      else
        moveable_spaces << [x, y_counter]
        y_counter -= 1
      end
    end

    y_counter = y + 1
    until on_board?(x, y_counter) == false || has_piece?(x, y_counter) == get_square(x, y).contents.color
      if has_piece?(x, y_counter)
        capture_spaces << [x, y_counter]
        break
      else
        moveable_spaces << [x, y_counter]
        y_counter += 1
      end
    end

    { moveable: moveable_spaces, capture: capture_spaces }
  end

  def place_bishop_markers(x, y)
    moveable_spaces = []
    capture_spaces = []

    x_counter = x + 1
    y_counter = y + 1
    until on_board?(x_counter, y_counter) == false || has_piece?(x_counter, y_counter) == get_square(x, y).contents.color
      if has_piece?(x_counter, y_counter)
        capture_spaces << [x_counter, y_counter]
        break
      else
        moveable_spaces << [x_counter, y_counter]
        x_counter += 1
        y_counter += 1
      end
    end

    x_counter = x + 1
    y_counter = y - 1
    until on_board?(x_counter, y_counter) == false || has_piece?(x_counter, y_counter) == get_square(x, y).contents.color
      if has_piece?(x_counter, y_counter)
        capture_spaces << [x_counter, y_counter]
        break
      else
        moveable_spaces << [x_counter, y_counter]
        x_counter += 1
        y_counter -= 1
      end
    end

    x_counter = x - 1
    y_counter = y + 1
    until on_board?(x_counter, y_counter) == false || has_piece?(x_counter, y_counter) == get_square(x, y).contents.color
      if has_piece?(x_counter, y_counter)
        capture_spaces << [x_counter, y_counter]
        break
      else
        moveable_spaces << [x_counter, y_counter]
        x_counter -= 1
        y_counter += 1
      end
    end

    x_counter = x - 1
    y_counter = y - 1
    until on_board?(x_counter, y_counter) == false || has_piece?(x_counter, y_counter) == get_square(x, y).contents.color
      if has_piece?(x_counter, y_counter)
        capture_spaces << [x_counter, y_counter]
        break
      else
        moveable_spaces << [x_counter, y_counter]
        x_counter -= 1
        y_counter -= 1
      end
    end

    { moveable: moveable_spaces, capture: capture_spaces }
  end

  def place_knight_markers(x, y)
    moveable_spaces = []
    capture_spaces = []

    moveable_spaces << [x + 1, y + 2] unless on_board?(x + 1, y + 2) == false
    moveable_spaces << [x + 1, y - 2] unless on_board?(x + 1, y - 2) == false
    moveable_spaces << [x + 2, y + 1] unless on_board?(x + 2, y + 1) == false
    moveable_spaces << [x + 2, y - 1] unless on_board?(x + 2, y - 1) == false
    moveable_spaces << [x - 1, y + 2] unless on_board?(x - 1, y + 2) == false
    moveable_spaces << [x - 1, y - 2] unless on_board?(x - 1, y - 2) == false
    moveable_spaces << [x - 2, y + 1] unless on_board?(x - 2, y + 1) == false
    moveable_spaces << [x - 2, y - 1] unless on_board?(x - 2, y - 1) == false

    space_to_delete = []
    moveable_spaces.each do |position|
      if has_piece?(position[0], position[1]) == get_square(x, y).contents.color
        space_to_delete << position
      elsif has_piece?(position[0], position[1])
        capture_spaces << position
        space_to_delete << position
      end
    end
    space_to_delete.each { |position| moveable_spaces.delete(position) }

    { moveable: moveable_spaces, capture: capture_spaces }
  end

  def place_pawn_markers(x, y)
    moveable_spaces = []
    capture_spaces = []
    passant_spaces = []

    if can_passant?(x, y)
      if get_square(x, y).contents.color == :white
        passant_spaces << [x + 1, y + 1] if on_board?(x + 1, y + 1) && get_square(x + 1, y).contents.is_a?(Pawn)
        passant_spaces << [x - 1, y + 1] if on_board?(x - 1, y + 1) && get_square(x - 1, y).contents.is_a?(Pawn)
      else
        passant_spaces << [x + 1, y - 1] if on_board?(x + 1, y - 1) && get_square(x + 1, y).contents.is_a?(Pawn)
        passant_spaces << [x - 1, y - 1] if on_board?(x - 1, y - 1) && get_square(x - 1, y).contents.is_a?(Pawn)
      end
    end


    if get_square(x, y).contents.color == :white
      moveable_spaces << [x, y + 2] if y == 1 && has_piece?(x, y + 1) == false && has_piece?(x, y + 2) == false
      moveable_spaces << [x, y + 1] if on_board?(x, y + 1) && has_piece?(x, y + 1) == false
      capture_spaces << [x + 1, y + 1] if on_board?(x + 1, y + 1) && has_piece?(x + 1, y + 1) == :black
      capture_spaces << [x - 1, y + 1] if on_board?(x - 1, y + 1) && has_piece?(x - 1, y + 1) == :black
    else
      moveable_spaces << [x, y - 2] if y == 6 && has_piece?(x, y - 1) == false && has_piece?(x, y - 2) == false
      moveable_spaces << [x, y - 1] if on_board?(x, y - 1) && has_piece?(x, y - 1) == false
      capture_spaces << [x + 1, y - 1] if on_board?(x + 1, y - 1) && has_piece?(x + 1, y - 1) == :white
      capture_spaces << [x - 1, y - 1] if on_board?(x - 1, y - 1) && has_piece?(x - 1, y - 1) == :white
    end

    { moveable: moveable_spaces, capture: capture_spaces, passant: passant_spaces }
  end

  def place_pawn_captures(x, y)
    capture_spaces = []

    if get_square(x, y).contents.color == :white
      capture_spaces << [x + 1, y + 1] if on_board?(x + 1, y + 1) && has_piece?(x + 1, y + 1) != :white
      capture_spaces << [x - 1, y + 1] if on_board?(x - 1, y + 1) && has_piece?(x - 1, y + 1) != :white
    else
      capture_spaces << [x + 1, y - 1] if on_board?(x + 1, y - 1) && has_piece?(x + 1, y - 1) != :black
      capture_spaces << [x - 1, y - 1] if on_board?(x - 1, y - 1) && has_piece?(x - 1, y - 1) != :black
    end

    capture_spaces.each { |coordinates| set_marker(coordinates[0], coordinates[1], '!') }
  end

  def valid_selection?(x, y, color)
    if correct_color?(x, y, color)
      get_moves(x, y)
      if no_valid_moves?
        no_moves_error
      else
        return true
      end
    elsif has_piece?(x, y)
      wrong_color_error 
    else
      empty_error
    end
    false
  end

  def available_moves
    x = 0
    moves = []
    until x > 7
      y = 0
      until y > 7
        moves << [x, y] if has_marker?(x, y)
        y += 1
      end
      x += 1
    end
    moves
  end

  def no_valid_moves?
    return true if get_grid_markers.flatten.all? { |space| space.nil? }
    false
  end

  def correct_color?(x, y, color)
    has_piece?(x, y) == color
  end
  
  def get_x(input)
    letter_row.index(input[0])
  end
  
  def get_y(input)
    input[1].to_i - 1
  end


  def check_status_error
    puts "You can't end your turn in check! Select another move."
  end

  def check_escape_error
    puts "You're in check! You must make a move to get out of check."
  end

  def self_check_error
    puts "You can't make a move that will put you in check!"
  end

  def wrong_color_error
    puts "That's not your piece! Choose again."
  end

  def empty_error
    puts "There's nothing in that space! Choose again."
  end

  def no_moves_error
    puts "That piece has no available moves. Choose again."
  end

  def marker_error
    puts "You can't move to that space. Choose another one."
  end

  def starting_board
    [black_side, black_pawns] + blank_rows + [white_pawns, white_side]
  end
end