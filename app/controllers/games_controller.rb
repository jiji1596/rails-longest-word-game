ALPHABET = ('a'..'z').to_a
require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    vowels = %w[a b c d e]
    @letters = ALPHABET.sample(8) + vowels.sample(2)
  end

  def score
    session[:score] = 0 unless session[:score]
    @end_time = Time.now
    total_time = @end_time - params[:start_time].to_datetime
    @word = params[:word]
    url = "https://dictionary.lewagon.com/#{@word}"
    serialized_url = URI.parse(url).read
    check_api = JSON.parse(serialized_url)
    @letters = params[:letters].split("")
    if check_api["found"] && @word.chars.all? do |char|
      @letters.include?(char) && @letters.count(char) >= @word.chars.count(char)
    end
      @message = "Congratulations! #{@word} is valid word!"
      @score = (check_api['length'] + (20 - total_time)).round(2)
      session[:score] += @score
    else
      @message = check_api["found"] ? "Sorry but #{@word} can't be built out of #{@letters.join(',').upcase}" : "Sorry but #{@word} is not an english word"
      @score = 0
    end
  end

  def reset
    session.delete(:score)

    redirect_to new_path
  end
end
