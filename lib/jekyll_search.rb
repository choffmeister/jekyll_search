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

          client = Elasticsearch::Client.new host: settings['host'], log: false
          create_index(client, settings)

          pages = site.pages.
              select { |p| p.data['searchable'].nil? or p.data['searchable'] != false }

          for page in pages
            body = {
              url: site.baseurl + page.url,
              title: page.data['title'],
              content: clean_content(page.content)
            }

            client.index index: 'documentation', type: 'page', body: body
          end
        end

        def clean_content(dirty)
          strip_pre = Loofah::Scrubber.new do |node|
            if node.name == 'pre'
              node.remove
              Loofah::Scrubber::STOP
            end
          end

          Loofah.fragment(dirty).
              scrub!(:prune).
              scrub!(strip_pre).
              to_text.
              gsub(/([\r\n\t\s]+)/, ' ').strip
        end

        def create_index(client, settings)
          if client.indices.exists index: 'documentation'
            client.indices.delete index: 'documentation'
          end

          client.indices.create index: 'documentation', body: (settings['index'] or {})
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

          puts "Total: #{result['hits']['total']}"
          puts "Max score: #{result['hits']['max_score']}"
          for hit in result['hits']['hits']
            puts "Hit at #{hit['_source']['url']} (#{hit['_score']})"
          end
        end
      end
    end
  end
end
