require 'equation_system'

# x + 2y + z = 2
# 3x + 8y + z = 12
# 4y + z = 2

Shoes.app(:title => 'Equation solver', :width => 600, :height => 300) do
  stack(:margin => 10) do
    para "Only simple ordered equations can be solved. Separate each equation in a system with a newline."
    @input_area = edit_box(:width => '90%')
    button('Solve equation system', :margin => [0, 10, 0, 10]) do
      begin
        @output_area.text = EquationSystem.new(*@input_area.text.split(/[\n\r]+/)).solution.map { |name, value| "#{name} = #{value}" }.join(', ')
      rescue
        @output_area.text = "The equation could not be solved."
      end
    end
    @output_area = para
  end
end
