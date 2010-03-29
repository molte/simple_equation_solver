require 'erb'
require 'rubygems'
require 'sinatra'
require 'equation_system'

set(:app, __FILE__)

get '/' do
  erb :form
end

post '/' do
  @solution = solve_equation_system(params[:equations])
  erb :form
end

helpers do
  def solve_equation_system(input)
    "Solution: " + EquationSystem.new(*input.split("\n")).solution.map { |name, value| "<var>#{name}</var> = #{value}" }.join(', ')
  rescue
    "The equations could not be solved."
  end
end
