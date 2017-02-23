module ApplicationHelper
  def act_as_link(options={})
    options[:document] # the original document
    options[:field] # the field to render
    options[:value] # the value of the field

    return link_to(body=options[:value][0], url=options[:value][0], target: '_blank')
  end

  def act_as_html(options={})
    output = []
    options[:value].each { |v|
      output.push(v)
    }

    return output.join().html_safe
  end
end
