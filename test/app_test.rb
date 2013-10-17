gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/app'
require 'rack/test'

class AppTest < Minitest::Test
  include Rack::Test::Methods 

  def app
    IdeaBoxApp
  end

  def test_it_exists
    assert IdeaBoxApp
  end

  def test_hello
    get '/'
    assert_equal "Hello, world", last_response.body
  end
end
