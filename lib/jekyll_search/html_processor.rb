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
  end
end
