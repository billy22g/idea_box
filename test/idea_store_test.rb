gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require './lib/idea_box/idea_store'
require './lib/idea_box/idea'
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

  def test_it_searches_for_ideas_by_tag
    IdeaStore.create("title" => "Howdy", "tags" => "1, 2, blue heaven")
    IdeaStore.create("title" => "Heyo", "tags" => "1, five, blue heaven")
    IdeaStore.create("title" => "Howdy", "tags" => "five, seven")
    result = IdeaStore.search_tags("Blue heaven")
    assert_equal 2, result.count
    assert_equal "Heyo", result.last.title
  end

  def test_it_searches_for_ideas_by_description
    IdeaStore.create("description" => "Howdy friends and family", "tags" => "1, 2, blue heaven")
    IdeaStore.create("description" => "Heyo", "tags" => "1, five, blue heaven")
    IdeaStore.create("description" => "Howdy besties", "tags" => "five, seven")
    result = IdeaStore.search_description("besties")
    assert_equal 1, result.count
    assert_equal "five, seven", result.last.tags
  end

  def test_it_searches_for_ideas_by_title
    IdeaStore.create("title" => "Howdy", "tags" => "1, 2, blue heaven")
    IdeaStore.create("title" => "Heyo", "tags" => "1, five, blue heaven")
    IdeaStore.create("title" => "Howdy", "tags" => "five, seven")
    result = IdeaStore.search_title("howdY")
    assert_equal 2, result.count
    assert_equal "1, 2, blue heaven", result.first.tags
  end

  def test_it_searches_for_ideas_by_group
    IdeaStore.create("title" => "Howdy", "tags" => "1, 2, blue heaven", "group" => "Travel")
    IdeaStore.create("title" => "Heyo", "tags" => "1, five, blue heaven", "group" => "Travel")
    IdeaStore.create("title" => "Howdy", "tags" => "five, seven", "group" => "Misc")
    result = IdeaStore.search_group("Travel")
    assert_equal 2, result.count
    assert_equal "Howdy", result.first.title
  end

  def test_it_should_return_an_id
    assert_equal 1, IdeaStore.get_next_id
  end

  def test_the_id_returned_should_be_unique
    IdeaStore.create("title" => "Howdy", "tags" => "1, 2, blue heaven", "group" => "Travel", "id" => 3)
    IdeaStore.create("title" => "Howdy", "tags" => "1, 2, blue heaven", "group" => "Travel", "id" => 6)
    IdeaStore.create("title" => "Howdy", "tags" => "1, 2, blue heaven", "group" => "Travel", "id" => 2)
    assert_equal 7, IdeaStore.get_next_id
  end
    # It should return an id
    # There should be no ideas with the id
    # The id should be one above the previous id

end
