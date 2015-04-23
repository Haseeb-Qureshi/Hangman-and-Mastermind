require 'set'
require_relative 'computer'
require_relative 'human'

class Hangman
  def initialize(guesser, master)
    @points = 6
    @guesser, @master = guesser, master
    @master.is_master
  end

  def play
    @master.tell_length(@guesser)
    until @points == 0 || success?
      make_guess
      render_game(@guesser, @master)
    end
    puts game_over
  end

  private

  def make_guess
    guess = @guesser.guess
    if @master.valid_guess?(guess)
      if @master.evaluate_guess(guess)
        @master.tell_indices(@guesser) if @master.is_a?(Human)
      else
        @points -= 1
      end
    else
      puts "Invalid guess. Try again.\n\n" if @master.is_a?(Computer)
    end
  end

  def success?
    @master.is_a?(Computer) ? @master.success? : @guesser.success?
  end

  def render_game(guesser, master)
    if master.is_a?(Computer)
      puts "The board is #{@master.master_word}. You have #{@points} guesses left!"
    else
      puts "So far, it's guessed #{@guesser.guesser_word}.
            The computer has #{@points} point(s) left."
      sleep(0.7)
    end
  end

  def game_over
    if @guesser.success? || @master.success?
      "#{@guesser} won!"
    else
      "#{@guesser} lost. The word #{@master.display_word}."
    end
  end
end


if __FILE__ == $PROGRAM_NAME
  a = Computer.new
  b = Human.new
  Hangman.new(a,b).play
end
