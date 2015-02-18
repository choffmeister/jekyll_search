require 'jekyll'
require 'elasticsearch'
require 'loofah'
require 'loofah/helpers'

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
          site.process
          settings = site.config['search']

          client = Elasticsearch::Client.new log: false
          client.indices.delete index: 'documentation'

          for page in site.pages
            body = {
              url: site.baseurl + page.url,
              title: page.data['title'],
              content: clean_content(page.content)
            }

            client.index index: 'documentation', type: 'page', body: body
          end
        end

        def clean_content(dirty)
          Loofah.fragment(dirty).to_text
          #.gsub(/([\r\n\t\s]+)/, ' ').strip
        end
      end
    end

    class Search < Command
      class << self
        def init_with_program(prog)
          prog.command(:search) do |c|
            c.syntax "search"
            c.description 'Searches a search index in Elasticsearch.'

            c.action do |args, options|
              options["serving"] = false
              Search.process(options)
            end
          end
        end

        def process(options)
          puts 'Enter query string:'
          query = gets

          client = Elasticsearch::Client.new log: false
          result = client.search index: 'documentation', body: { query: { match: { content: query } }, highlight: { fields: { content: {} }} }

          puts "Total: #{result['total']}"
          puts "Max score: #{result['max_score']}"
          for hit in result['hits']['hits']
            puts "Hit at #{hit['_source']['url']} (#{hit['_score']})"
            puts hit['highlight']['content']
          end
        end
      end
    end
  end
end
