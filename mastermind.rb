class Code

  attr_reader :pegs

  COLORS = %w[r g b y o p].map(&:to_sym)

  def initialize
    @pegs = []
  end

  def random
    4.times { @pegs << COLORS.sample }
    self
  end

  def parse(input)
    @pegs = input.chars.map(&:downcase).map(&:to_sym)
    self
  end

  def is_valid?
    @pegs.length == 4 && @pegs.all? { |peg| COLORS.include?(peg) }
  end

  def exact_matches(guess)
    count = 0
    4.times { |i| @pegs[i] == guess.pegs[i] ? count += 1 : count }
    count
  end

  def near_matches(guess)
    count = 0
    4.times do |i|
      if @pegs.include?(guess.pegs[i]) && @pegs[i] != guess.pegs[i]
        count += 1
      end
    end
    count
  end

end

class Game

  def initialize
    @correct_code = Code.new.random
    @turns_passed = 0
    @got_it_right = false
  end

  def play
    until game_over || @got_it_right
      input = Code.new.parse(get_input)
      if input.is_valid?
        @turns_passed += 1
        check(input)
      else
        render(error: true)
      end
    end
    puts @got_it_right ? "You did it!" : "Game over!"
  end

  def check(input)
    exact = input.exact_matches(@correct_code)
    near = input.near_matches(@correct_code)
    turns_remaining = 8 - @turns_passed
    @got_it_right = true if exact == 4
    render(exact: exact, near: near, turns: turns_remaining)
  end

  def game_over
    @turns_passed >= 8
  end

  def get_input
    puts "Enter your guess, like so: \"RGBY\"."
    input = gets.chomp[0..3]
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



if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
