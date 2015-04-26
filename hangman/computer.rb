require_relative 'player'

class Computer < Player

  def initialize
    @word, @last_guess, @potential_guesses, @guessed_indices = nil, nil, [], []
    @guessed_letters = Set.new
  end

  def success?
    @word ? @guessed_indices.length == @word.length : !@guess_array.include?(nil)
  end

  # is master

  def display_word
    "was #{@word}"
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

  def master_word
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

  def to_s
    "Computer"
  end

  # when guesser

  def word_length_is(length)
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

  def guesser_word
    render_word = ""
    @guess_array.each_with_index do |char, idx|
      char ? render_word << char : render_word << '_'
    end
    render_word
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
