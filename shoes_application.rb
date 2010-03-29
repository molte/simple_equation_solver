require 'equation_system'

# Example:
# y + x + y + z = 2
# 3x + 8y - 2 + z = 10
# 4y = 2 - z

Shoes.app(:title => 'Equation solver', :width => 900, :height => 450) do
  stack(:margin => 10) do
    para <<-EOT
The EquationSystem class is able to solve a system of n first-degree equations with n unknown variables.
Requirements:
 - The equations may only contain variables with coefficients (eg. 4z) and numbers.
 - All numbers should be rational, written with decimal-notation.
 - The only allowed operators are plus and minus (except the hidden multiplication sign between the coefficient and the variable).
EOT
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
