require 'erb'
require File.join(File.dirname(__FILE__), 'lib', 'equation_system')

begin
  # Require the preresolved locked set of gems.
  require ::File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end
require 'sinatra'

set(:app_file, __FILE__)

get '/' do
  erb :form
end

post '/' do
  @solution = solve_equation_system(params[:equations])
  erb :form
end

helpers do
  def solve_equation_system(input)
    solution = EquationSystem.new(*input.split("\n")).solution.map { |name, value| "<var>#{name}</var> = #{value}" }.join(', ')
    %{<p class="solution">Solution: #{solution}</p>}
  rescue
    '<p class="error">The equations could not be solved.</p>'
  end
end
