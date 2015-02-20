require 'jekyll_search/html_processor'

RSpec.describe JekyllSearch::HtmlProcessor do
  it 'stripes html' do
    expect(JekyllSearch::HtmlProcessor.strip_html('test')).to eq 'test'
    expect(JekyllSearch::HtmlProcessor.strip_html("<h1>title</h1>\n<p>text</p>")).to eq 'title text'
  end
end
