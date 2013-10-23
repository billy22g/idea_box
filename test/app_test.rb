gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/app/app'
require 'rack/test'

class AppTest < Minitest::Test
  include Rack::Test::Methods 

  def app
    IdeaBoxApp
  end

  def test_it_exists
    assert IdeaBoxApp
  end
end
