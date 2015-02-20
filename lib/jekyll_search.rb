require 'jekyll'
require 'elasticsearch'
require 'loofah'
require 'loofah/helpers'
require 'jekyll_search/html_processor'

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
              select { |p| p.url =~ /\.html$/ }.
              select { |p| p.data['searchable'].nil? or p.data['searchable'] != false }

          for page in pages
            body = {
              url: site.baseurl + page.url,
              title: page.data['title'],
              content: JekyllSearch::HtmlProcessor.strip_html(page.content)
            }

            client.index index: settings['index']['name'], type: 'page', body: body
          end
        end

        def create_index(client, settings)
          if client.indices.exists index: settings['index']['name']
            client.indices.delete index: settings['index']['name']
          end

          client.indices.create index: settings['index']['name'], body: (settings['index']['settings'] or {})
        end
      end
    end

    class Search < Command
      class << self
        def init_with_program(prog)
          prog.command(:search) do |c|
            c.syntax "search query"
            c.description 'Searches a search index in Elasticsearch.'

            c.action do |args, options|
              query = args.join(' ').strip
              options["serving"] = false
              Search.process(options, query)
            end
          end
        end

        def process(options, query)
          options = configuration_from_options(options)
          site = Jekyll::Site.new(options)
          settings = site.config['search']

          client = Elasticsearch::Client.new host: settings['host'], log: false
          result = client.search index: settings['index']['name'], body: { query: { match: { content: query } }, highlight: { fields: { content: {} }} }

          puts "Query: #{query}"
          puts "Total: #{result['hits']['total']}"
          puts "Max score: #{result['hits']['max_score']}"
          for hit in result['hits']['hits']
            puts "Hit at #{hit['_source']['url']} (#{hit['_score']})"
            hit['highlight']['content'].each { |c| puts '- ' + c }
          end
        end
      end
    end
  end
end
