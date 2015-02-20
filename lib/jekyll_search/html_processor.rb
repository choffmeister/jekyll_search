require 'loofah'
require 'loofah/helpers'

module JekyllSearch
  class HtmlProcessor
    def self.strip_html(input)
      strip_pre = Loofah::Scrubber.new do |node|
        if node.name == 'pre'
          node.remove
          Loofah::Scrubber::STOP
        end
      end

      Loofah.fragment(input).
          scrub!(:prune).
          scrub!(strip_pre).
          to_text.
          gsub(/([\r\n\t\s]+)/, ' ').strip
    end

    def self.detect_sections(input)
      result = []

      current = { :id => nil, :title => nil, :content => '' }
      Loofah.fragment(input).children.each { |node|
        if node.name =~ /^h\d$/
          result << current
          current = { :id => nil, :title => nil, :content => '' }
          current[:id] = if node.has_attribute?('id') then node.attribute('id').value else nil end
          current[:title] = node.text
        else
          current[:content] += node.to_html
        end
      }
      if current[:title] != nil or current[:content] != ''
        result << current
      end

      result
    end
  end
end
