require 'jekyll_search/html_processor'

RSpec.describe JekyllSearch::HtmlProcessor do
  it 'stripes html' do
    expect(JekyllSearch::HtmlProcessor.strip_html('test')).to eq 'test'
    expect(JekyllSearch::HtmlProcessor.strip_html("<h1>title</h1>\n<p>text</p>")).to eq 'title text'
  end

  it 'detects sections' do
    expect(JekyllSearch::HtmlProcessor.detect_sections('test')).to eq [
        { :id => nil, :title => nil, :content => 'test' }
    ]
  end

  it 'detects sections' do
    expect(JekyllSearch::HtmlProcessor.detect_sections('<h1>foo</h1>test')).to eq [
        { :id => nil, :title => nil, :content => '' },
        { :id => nil, :title => 'foo', :content => 'test' }
    ]
  end

  it 'detects sections' do
    expect(JekyllSearch::HtmlProcessor.detect_sections("foo<h1>first</h1>bar <p>\npara\n</p>\n\n<H4 ID=\"sec\">sec<span>ond</span></H4>apple<h2>third</h2>")).to eq [
        { :id => nil, :title => nil, :content => "foo" },
        { :id => nil, :title => 'first', :content => "bar <p>\npara\n</p>\n\n" },
        { :id => 'sec', :title => 'second', :content => "apple" },
        { :id => nil, :title => 'third', :content => '' }
    ]
  end

  it 'detects sections' do
    expect(JekyllSearch::HtmlProcessor.detect_sections("<h1>foo<div id=\"inner-id\"></div></h1>bar")).to eq [
        { :id => nil, :title => nil, :content => '' },
        { :id => 'inner-id', :title => 'foo', :content => 'bar' }
    ]
  end
end
