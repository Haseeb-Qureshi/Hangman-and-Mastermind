#move public knowledge to game class, like rendering and winning
#remove unused attrs

require 'Set'

class Hangman
  def initialize(guesser, master)
    @points = 6
    @guesser, @master = guesser, master
    @master.is_master
  end

  def play
    @master.tell_length(@guesser)
    until @points == 0 || @master.success?
      make_guess
      render_game(@guesser, @master)
    end
    puts game_over
  end

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

  def render_game(guesser, master)
    if master.is_a?(Computer)
      puts "The board is #{@master.master_word}. You have #{@points} guesses left!"
    else
      puts "So far, it's guessed #{@guesser.guesser_word}.
            The computer has #{@points} point(s) left."
    end
  end

  def game_over
    if @master.success?
      "#{@guesser} won!"
    else
      "#{@guesser} lost. The word was #{@master.word}."
    end
  end

end

class Human
  attr_reader :word

  def initialize
    @word = "a secret"
  end

  def is_master
    choose_word
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

  def render
  end

  def success?
  end

  def tell_indices(computer)
    computer.update(which_indices)
  end

  def tell_length(computer)
    computer.word_to_guess_length_is(@word_length)
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
    puts "Is the letter ___#{guess}___ in your word? Y/N?"
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

class Computer
  attr_reader :word, :guessed_indices, :guessed_letters, :guess_array,
              :last_guess, :potential_guesses

  def initialize
    @last_guess, @potential_guesses = nil, []
    @guessed_letters = Set.new
  end

  def is_master
    choose_word
    @guessed_indices = []
  end

  def tell_length(guesser)
    puts "The word is #{word.length} letters long."
  end

  def valid_guess?(guess)
    !@guessed_letters.include?(guess) && guess.downcase[/[A-Za-z]/]
  end

  def evaluate_guess(guess)
    @guessed_letters << guess
    check_guess(guess)
  end

  def guesser_word
    render_word = ""
    @word.chars.each_with_index do |char, idx|
      if @guessed_indices.include? idx
        render_word << char
      else
        render_word << '_'
      end
    end
    render_word
  end

  def master_word
    render_word = ""
    @guess_array.each_with_index do |char, idx|
      char ? render_word << char : render_word << '_'
    end
    render_word
  end

  def success?
    @guessed_indices.length == @word.length
  end

  def to_s
    "Computer"
  end


  # when guesser


  def word_to_guess_length_is(length)
    @guess_array = Array.new(length)
    read_dictionary
  end

  def guess
    narrow_down
    pick_guess
  end

  def update(indices)
    indices.each { |index| @guess_array[index-1] = @last_guess }
  end

  private

  def read_dictionary
    File.open("dictionary.txt").readlines.each do |line|
      @potential_guesses << line.chomp if line.chomp.length == @guess_array.length
    end
  end

  def narrow_down
    @potential_guesses.each_with_index do |word, i|
      @guess_array.each_with_index do |letter, j|
        if letter && word[j] != letter
          @potential_guesses[i] = nil
        end
      end
    end
    @potential_guesses.compact!
  end

  def pick_guess
    char_count = Hash.new(0)
    @potential_guesses.each do |word|
      word.chars.each do |char|
        char_count[char] += 1 unless @guessed_letters.include?(char)
      end
    end
    max_letter = char_count.max_by{ |k,v| v }.first
    @guessed_letters << max_letter
    @last_guess = max_letter
  end

  def choose_word
    @word = File.readlines("dictionary.txt").sample.chomp
  end

  def check_guess(guess)
    match = false
    @word.chars.each_with_index do |char, idx|
      if char == guess
        guessed_indices << idx
        match = true
      end
    end
    match
  end

end

if __FILE__ == $PROGRAM_NAME
  a = Computer.new
  b = Human.new
  Hangman.new(a,b).play
end
