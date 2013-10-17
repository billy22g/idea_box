gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require './lib/idea_store'
require './lib/idea'
require 'yaml/store'

class IdeaStoreTest < Minitest::Test

  def setup
    IdeaStore.destroy_database
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

  def test_it_deletes_an_idea_by_position_in_database
    IdeaStore.create("title" => "Hello")
    IdeaStore.create("title" => "Howdy")
    IdeaStore.create("title" => "Heyo")
    assert_equal 3, IdeaStore.all.count
    IdeaStore.delete(2)
    assert_equal "Howdy", IdeaStore.all.last.title
    assert_equal "Hello", IdeaStore.all.first.title
  end

  def test_it_destroys_database_contents
    IdeaStore.create("title" => "Hello")
    assert_equal 1, IdeaStore.all.count
    IdeaStore.destroy_database
    assert_equal 0, IdeaStore.all.count
  end

  def test_find_method_finds_by_id
    IdeaStore.create("title" => "Hello")
    IdeaStore.create("title" => "Howdy")
    IdeaStore.create("title" => "Heyo")
    result = IdeaStore.find(1)
    assert_equal 1, result.id
    assert_equal "Howdy", result.title
    assert_kind_of Idea, result
  end

  def test_it_can_update_an_idea
    IdeaStore.create("title" => "Hello")
    IdeaStore.update(0, "title" => "Howdy")
    result = IdeaStore.find(0)
    assert_equal "Howdy", result.title
  end

  def test_it_does_not_reset_votes_when_updating_idea
    IdeaStore.create("title" => "Hello", "votes" => 2)
    IdeaStore.update(0, "title" => "Heyo")
    result = IdeaStore.find(0)
    assert_equal 2, result.votes
  end

  def test_like_method_updates_votes_in_database
    IdeaStore.create("title" => "Hello")
    idea = IdeaStore.find(0)
    assert_equal 0, idea.votes 
    idea.like!
    assert_equal 1, idea.votes
    idea.like!
    assert_equal 2, idea.votes 
  end

  def test_it_leaves_others_unchanged_when_updating_idea
    IdeaStore.create("title" => "Hello")
    IdeaStore.create("title" => "Howdy")
    IdeaStore.create("title" => "Heyo")
    IdeaStore.update(1, "title" => "Bonjour")
    assert_equal "Hello", IdeaStore.all.first.title
    assert_equal "Heyo", IdeaStore.all.last.title
    updated_idea = IdeaStore.find(1)
    assert_equal "Bonjour", updated_idea.title
  end
end
