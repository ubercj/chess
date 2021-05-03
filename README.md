# Command-Line Chess

Try it out on Replit! - [https://replit.com/@ubercj/chess?v=1](https://replit.com/@ubercj/chess?v=1)

This is the final project for the Ruby module on The Odin Project's full-stack Ruby on Rails curriculum. Read more about the project [here](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby-programming/lessons/ruby-final-project).

## Setting up a game

__A quick note about the colors:__ The colors of the icons don't display properly on Replit... In some cases the black pieces appear white, and vice versa. Just remember that _black is always at the top of the board_ and _white is always at the bottom of the board_.

_Note: You will be asked at the start if you would like to load a saved game. If you play this on Replit, there won't be any saved games. So it doesn't matter what you choose - either way, a new game will be started._

Choose whether you would like to play with 2 human players (P) or 1 player against a computer (C).

_Note: For this and for all other prompts, you will need to type the characters and then press Enter to submit your input._

### Saving and quitting

Any time you are prompted for text input, you can type "Q" to forfeit the game or "S" to save your game. You will then be prompted to enter a name for your save file. 

Provided that you don't navigate away from the Replit page, you can start a new game with `ruby lib/chess.rb` and then select "Y" when asked if you would like to load a saved game.

## Making moves

Making a move is a two-step process: 

1. First, you type the coordinates (e.g. e1 for the white king). If that piece has any available moves, those spaces will be indicated with a character (* or !).
2. Second, you type the coordinates of an available space. Then, the move will be executed.

### Capturing pieces

When you are making a move and you have selected a piece to move, spaces marked with a "!" indicate opponent-controlled pieces that can be captured by your currently selected piece.

### Special maneuvers

"Special" moves like castling and en passant are supported!

When castling is available to the king piece you have selected, it will be indicated on the board with a "#".

When en passant is available to the pawn piece you have selected, it will be indicated on the board with a "%".

## Reflections

At the time I made this program, it was the most difficult project I had tackled to that point - building a command-line Chess game completely on my own without any hints. It had to allow for two players to play against one another (with bonus points for creating a Computer with a simple AI to play against). It also had to allow you to save the game at any time and load it back up again later.

This project really tested me and taught me a lot. I hit a lot of walls. I jotted down a lot of pseudocode and did a lot of "rubber ducking." In the end, I managed to include every bit of functionality I wanted, including the annoying edge cases like en passant and castling.

The most important thing I learned from this project is that if there's something I want to do and I can say it in words, then I can put it in code. It's an empowering feeling! There is plenty of room for improvement in this program - some of the methods do too many things at once, and the code could be cleaner. But at the end of the day, I'm really proud of what I was able to accomplish on my own, and this marked a huge step in my programming journey.