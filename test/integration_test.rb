require 'rack/test'
require 'webrat'
require 'test/unit'
require File.dirname(__FILE__) + '/../simple_equation_solver'

ENV['RACK_ENV'] = 'test'

Webrat.configure do |config|
  config.mode = :rack
end

class ApplicationTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  
  def app
    Sinatra::Application.new
  end
  
  def setup
    visit "/"
  end
  
  def test_it_works
    assert last_response.ok?
    assert_contain "Simple equation solver"
  end
  
  def test_shown_example
    equations = ["4x - 5y + (3z - y) = 4 * 4.5/2", "2 * 1.5x - 3y + 8z = 22 + 2y", "5x - 2(5/2 - 2y + 3.5z) = 20"]
    
    equations.each { |eq| assert_contain eq }
    
    fill_in "equations", :with => equations.join("\n")
    click_button "Solve!"
    assert_contain 'Solution: x = 6, y = 4, z = 3'
  end
  
  def test_rational_output
    fill_in "equations", :with => "b = 0.5a + 3/4\na = 7/5"
    click_button "Solve!"
    assert_contain "Solution: a = 7/5, b = 29/20"
  end
  
  def test_decimal_output
    fill_in "equations", :with => "b = 0.5a + 3/4\na = 7/5"
    check "notation"
    click_button "Solve!"
    assert_contain "Solution: a = 1.4, b = 1.45"
  end
  
  def test_inconsistent_system
    fill_in "equations", :with => "0 = c\n0 = a + b + c\n-1 = 4a + 2b + c\n4 = 9a + 3b + c\n8 = 16a + 4b + c"
    click_button "Solve!"
    assert response_text.include?("Approximate solution: a = 1, b = &minus;2, c = 1/5")
  end
  
  def test_ignorance_of_spacing
    fill_in "equations", :with => "\na=1+b\n\n4 + a     = 2a\n   \n"
    click_button "Solve!"
    assert_contain "Solution: a = 4, b = 3"
  end
  
  private
  def strip_html_tags(html)
    html.gsub(/<[^>]+>/, '')
  end
  
  def response_text
    strip_html_tags(response_body)
  end
end
