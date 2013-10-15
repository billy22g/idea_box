gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_store'
require './lib/idea'
require 'yaml/store'

class IdeaStoreTest < Minitest::Test

  def setup
    IdeaStore.database
  end

  def teardown
    IdeaStore.destroy_database
  end

  def test_the_database_exists
    assert_kind_of Psych::Store, IdeaStore.database
  end

  def test_it_creates_a_new_idea_and_stores_in_database
    IdeaStore.create("title" => "Hello")
    result = IdeaStore.database.transaction {|db| db["ideas"].first}
    assert_equal "Hello", result["title"]
  end

  def test_all_gives_all_ideas_as_idea_objects
    IdeaStore.create("title" => "Hello")
    IdeaStore.create("title" => "Howdy")
    assert_equal 2, IdeaStore.all.count
    assert_equal "Hello", IdeaStore.all.first.title
    assert_equal "Howdy", IdeaStore.all.last.title
  end
end
