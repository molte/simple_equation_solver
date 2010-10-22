require 'erb'
require File.dirname(__FILE__) + '/lib/equation_system'

require 'rubygems'
require 'sinatra'
require 'active_support/core_ext/object/blank'

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
