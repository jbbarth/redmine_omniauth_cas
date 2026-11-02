# frozen_string_literal: true

require "spec_helper"

describe ApplicationController, :type => :controller do
  def validate(url)
    controller.send(:validate_back_url, url)
  end

  it "accepts a local path" do
    expect(validate('/my/page?foo=bar')).to eq('/my/page?foo=bar')
  end

  it "ignores the scheme and the port of the current host" do
    expect(validate('https://test.host/my/page')).to eq('/my/page')
    expect(validate('http://test.host:8443/my/page')).to eq('/my/page')
  end

  it "rejects another host" do
    expect(validate('https://example.net/my/page')).to be(false)
    expect(validate('//example.net/my/page')).to be(false)
    expect(validate('https://test.host@example.net/my/page')).to be(false)
  end

  it "rejects a url that becomes protocol-relative once its authority is removed" do
    expect(validate('https://test.host//example.net/my/page')).to be(false)
  end

  it "rejects urls that browsers resolve to another host" do
    expect(validate('/\\example.net')).to be(false)
    expect(validate('https://test.host/\\example.net')).to be(false)
    expect(validate("/\t/example.net")).to be(false)
    expect(validate("/\n/example.net")).to be(false)
  end

  it "rejects a script url" do
    expect(validate('javascript:alert(1)')).to be(false)
  end

  it "rejects a value that is not a string" do
    expect(validate(['/my/page'])).to be(false)
    expect(validate({'a' => '/my/page'})).to be(false)
  end

  it "keeps the other checks of the core method" do
    expect(validate('/my/../admin')).to be(false)
    expect(validate('https://test.host/login')).to be(false)
  end
end
