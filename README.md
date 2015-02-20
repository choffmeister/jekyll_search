# JekyllSearch

[![build](https://img.shields.io/travis/choffmeister/jekyll_search/develop.svg)](https://travis-ci.org/choffmeister/jekyll_search)
[![gem](https://img.shields.io/gem/v/jekyll_search.svg)](https://rubygems.org/gems/jekyll_search)
[![license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](http://opensource.org/licenses/MIT)

## Installation

Add this line to your application's Gemfile:

```ruby
source 'https://rubygems.org'

group :jekyll_plugins do
  gem 'jekyll_search'
end
```

or for bleeding edge:

```ruby
group :jekyll_plugins do
  gem 'jekyll_search', :git => 'https://github.com/choffmeister/jekyll_search.git', :branch => 'develop'
end
```

And then execute:

    $ bundle

## Usage

First you need a machine with [Elasticsearch][elasticsearch] installed. Then configure the search plugin by adding
the following entries into your Jekyll `_config.yml` (replace the `host` entry if needed):

```yaml
# Search index settings
search:
  host: localhost:9200
```

Now run `jekyll index` to iterate over all pages and index them with Elasticsearch. With `jekyll search` you can
throw some test searches against your freshly created search index.

If you want to customize how Elasticsearch creates the search index, then provide an additional `index` property
in your `_config.yml` (see [here][elasticsearch-createindex]:

```yaml
# Search index settings
search:
  host: localhost:9200
  index:
    mappings:
      page:
        properties:
          url:
            type: string
            analyzer: keyword
          title:
            type: string
            analyzer: english
          content:
            type: string
            analyzer: english
```

## Contributing

1. Fork it ( https://github.com/choffmeister/jekyll_search/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[elasticsearch]: http://www.elasticsearch.org/
[elasticsearch-createindex]: http://www.rubydoc.info/gems/elasticsearch-api/Elasticsearch/API/Indices/Actions#create-instance_method
