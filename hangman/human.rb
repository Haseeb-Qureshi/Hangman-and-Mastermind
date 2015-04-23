require_relative 'player'

class Human < Player
  def initialize
  end

  def display_word
    "will forever remain a secret"
  end

  def guess
    puts "Guess a letter."
    gets.chomp[0]
  end

  def valid_guess?(guess)
    true
  end

  def evaluate_guess(guess)
    check_guess(guess)
  end

  def success?
  end

  def tell_indices(computer)
    computer.update(which_indices)
  end

  def tell_length(computer)
    computer.word_length_is(@word_length)
  end

  def to_s
    "Human"
  end

  private

  def choose_word
    puts "Choose a word. Don't tell me what it is! Just tell me how long it is."
    @word_length = Integer(gets)
  end

  def check_guess(guess)
    puts "Is the letter _#{guess}_ in your word? Y/N?"
    answer = gets.chomp
    if answer_valid?(answer)
      y_n_mapper(answer)
    else
      puts "That's an invalid response. Please enter Y or N.\n"
      check_guess(guess)
    end
  end

  def answer_valid?(answer)
    case answer.downcase
      when "y" then true
      when "n" then true
      else false
    end
  end

  def y_n_mapper(char)
    char == 'y' ? true : false
  end

  def which_indices
    puts "Which indices did the computer hit? Enter each number with a space."
    puts "Like so: \"1 3 5\" (we're not zero-indexing, don't worry.)"
    indices = gets.chomp.split.map(&:to_i)
  end

end
