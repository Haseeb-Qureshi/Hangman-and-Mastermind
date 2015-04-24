class Game

  def initialize
    @correct_code = Code.random
    @turns_passed = 0
    @won = false
  end

  def play
    until @won || @turns_passed == 8
      input_code = Code.parse(get_input)
      process(input_code)
    end

    puts @won ? "You did it!" : "Game over!"
  end

  def get_input
    puts "Enter your guess, like so: \"RGBY\"."
    gets.chomp[0..3]
  end

  def process(input_code)
    if input_code.is_valid?
      @turns_passed += 1
      check(input_code)
    else
      render(error: true)
    end
  end

  def check(input_code)
    exact = input_code.exact_matches(@correct_code)
    near = input_code.near_matches(@correct_code)
    turns_remaining = 8 - @turns_passed

    @won = true if exact == 4
    render(exact: exact, near: near, turns: turns_remaining)
  end

  def render(params = {})
    if params[:error]
      puts "Not a valid guess!"
    else
      puts "You have #{params[:exact]} exact matches."
      puts "You have #{params[:near]} correct colors."
      puts "You have #{params[:turns]} turns left."
    end
  end
end

class Code
  COLORS = %w[r g b y o p].map(&:to_sym)

  def self.random
    pegs = []
    4.times { pegs << COLORS.sample }
    new(pegs)
  end

  def self.parse(input)
    pegs = input.chars.map(&:downcase).map(&:to_sym)
    new(pegs)
  end

  def is_valid?
    @pegs.length == 4 && @pegs.all? { |peg| COLORS.include?(peg) }
  end

  def exact_matches(guess)
    count = 0
    4.times { |i| count += 1 if @pegs[i] == guess.pegs[i] }
    count
  end

  def near_matches(guess)
    count = 0
    4.times do |i|
      count += 1 if @pegs.include?(guess.pegs[i]) && @pegs[i] != guess.pegs[i]
    end
    count
  end

  protected

  attr_reader :pegs

  private

  def initialize(pegs = [])
    @pegs = pegs
  end

end

if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
