class GameController < ApplicationController

require 'open-uri'
require 'json'

  def run
    @grid = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @start_time = Time.parse(params[:start])
    @time = @end_time - @start_time
    @time = @time.to_i
    @answer = run_game(params[:answer], params[:grid].split(""), @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    return (0...grid_size).map { ('a'..'z').to_a.sample }.join.upcase.split("")
  end


  def traduction(attempt)
    key = "a4551ae1-82d1-46e4-a473-91b8371260b9"
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&"
    filepath = "#{url}key=#{key}&input=#{attempt}"
    attempts_json = open(filepath).read
    attempts_traduction = JSON.parse(attempts_json)["outputs"][0]["output"]
    return attempts_traduction
  end

  def validword(guess, grid)
   guess.upcase.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
  end


  def run_game(attempt, grid, start_time, end_time)
    if !validword(attempt, grid)
      return {translation: nil, score: 0, message: "not in the grid" }
    elsif traduction(attempt) == attempt
      return { time: end_time - start_time, translation: nil, score: 0, message: "not an english word" }
    else
      point = attempt.length * 1000 / (end_time - start_time).to_i
      return { time: end_time - start_time, translation: traduction(attempt), score: point, message: "well done" }
    end
  end

end
