class ArrayInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:type] ||= "string"
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.template.content_tag(:div, :class => "array-inputs-container") do
      Array(object.public_send(attribute_name)).map do |array_el|
        @builder.text_field(nil, merged_input_options.merge(:value => array_el, :name => "#{object_name}[#{attribute_name}][]"))
      end.join.html_safe
    end
  end
end
