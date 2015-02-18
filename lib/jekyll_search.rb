require 'jekyll'

module Jekyll
  module Commands
    class Index < Command
      class << self
        def init_with_program(prog)
          prog.command(:index) do |c|
            c.syntax "index"
            c.description 'Creates a search index in Elasticsearch.'

            c.action do |args, options|
              options["serving"] = false
              Index.process(options)
            end
          end
        end

        def process(options)
            options = configuration_from_options(options)
            destination = options['destination']

            site = Jekyll::Site.new(options)
            settings = site.config['search']

            for page in site.pages
              puts page.to_s
            end

            puts settings
        end
      end
    end
  end
end
