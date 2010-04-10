require 'erb'
require 'equation_system'
require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'

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
    "Solution: <strong>" + EquationSystem.new(*input.split("\n")).solution.map { |name, value| "<var>#{name}</var> = #{value}" }.join(', ') + "</strong>"
  rescue
    "The equations could not be solved."
  end
end
