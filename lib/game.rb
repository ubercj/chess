require "yaml"

class Game
  attr_accessor :board, :current_player, :other_player
  def initialize(board = Board.new)
    @board = board
    @current_player = Player.new('Player 1')
    @other_player = Player.new('Player 2')
    start_game
  end

  def start_game
    if load_prompt
      load
    elsif computer_prompt
      get_player(@current_player)
      @other_player = Computer.new
      assign_players
      play
    else
      get_player(@current_player)
      get_player(@other_player)
      assign_players
      play
    end
  end

  def computer_prompt
    puts "Type P to play with 2 human players."
    puts "Or type C to play against the Computer."
    user_input = ""
    until user_input.match(/^[pc]$/)
      user_input = gets.chomp.downcase
    end
    return true if user_input == "c"
    false
  end

  def get_player(player)
    puts "#{player.name}: Type your name and press enter."
    player.name = gets.chomp
  end

  def assign_players
    puts "Setting up the board\n.\n.\n."
    @current_player, @other_player = [@current_player, @other_player].shuffle
    @current_player.color, @current_player.king_position = :white, [4, 0]
    @other_player.color, @other_player.king_position = :black, [4, 7]
    puts "#{@current_player.name} controls white.\n#{@other_player.name} controls black.\n#{@current_player.name} moves first."
  end

  def play
    option = catch (:quit_game) do
      loop do
        @board.current_king = @current_player.king_position
        @board.reset_pawn_vulnerability(@current_player)
        @board.display_board
        
        puts "#{@current_player.name} is in check!" if @board.check?(@current_player)
        gamestate = @board.game_over?(@current_player)
        if gamestate
          game_over_message(gamestate)
          break
        else
          move
        end
        @board.clear_markers
        switch_players
      end
    end
    end_game(option)
  end

  def move
    choose_again = true
    until choose_again == false
      starting_coordinates = @board.select_piece(@current_player)
      choose_again = @board.select_destination(@current_player, starting_coordinates)
    end
  end

  def switch_players
    @current_player, @other_player = @other_player, @current_player
  end

  def game_over_message(gamestate)
    if :checkmate
      puts "Checkmate! #{@other_player.name} wins!"
    elsif :stalemate
      puts "Stalemate! It's a draw!"
    end
  end

  def end_game(option)
    save if option == :save
    quit if option == :quit
  end

  def save
    @board.clear_markers
    puts "Enter a name for your saved file:"
    filename = gets.chomp
    saved_game = YAML.dump(self)
    Dir.mkdir("../saved_games") unless Dir.exists?("../saved_games")
    File.open("../saved_games/#{filename}.txt", "w") { |file| file.write saved_game }
    puts "Game saved. Goodbye!"
  end

  def load
    if  Dir.exists?("../saved_games") == false || Dir.empty?("../saved_games")
      puts "There are no saved games available.\nA new game will be started instead."
    else
      puts "Here are the saved game files:"
      files = show_saved_games
      puts "Please type a number to load that file:"
      num = get_file_num(files.length)
      saved_game = File.open("../saved_games/#{files[num]}", "r")
      loaded_game = YAML.load(saved_game)
      loaded_game.play
    end
  end

  def load_prompt
    puts "Would you like to load a saved game?"
    puts "Type Y for yes, N for No"
    user_input = ""
    until user_input.match(/^[yn]$/)
      user_input = gets.chomp.downcase
    end
    return true if user_input == "y"
    false
  end

  def get_file_num(length)
    input = ""
    until input.match(/^\d+$/) && input.to_i.between?(1, length)
      input = gets.chomp
    end
    input.to_i - 1
  end

  def show_saved_games
    files = Dir.glob("*.txt", base: "../saved_games")
    files.each_with_index do |file, index|
      puts "#{index + 1}. #{file}"
    end
    files
  end

  def quit
    puts "If you quit, you will forfeit the game. Are you sure?"
    puts "Type Y for Yes, N for No"
    user_input = ""
    until user_input.match(/^[yn]$/)
      user_input = gets.chomp.downcase
    end
    if user_input == "y"
      puts "You have forfeited. #{@other_player.name} wins!"
      return true
    else
      play
    end
  end
end