require 'erb'
require File.dirname(__FILE__) + '/lib/equation_system'

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
  @solution = solve_equation_system(params[:equations], params[:notation].presence || :rational)
  erb :form
end

helpers do
  def solve_equation_system(input, notation)
    equations = EquationSystem.new(*input.split("\n").reject(&:blank?))
    solution  = equations.solution(notation.to_sym).map(&:to_html).reject(&:blank?).sort.join(', ')
    equations.approximation? ? %{<p class="approx-solution">Approximate solution: #{solution}</p>} : %{<p class="solution">Solution: #{solution}</p>}
  rescue
    '<p class="error">The equations could not be solved.</p>'
  end
end
