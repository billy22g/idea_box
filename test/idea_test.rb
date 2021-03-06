gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/idea.rb'

class IdeaTest < Minitest::Test
  def test_basic_idea
    idea = Idea.new("title" => "dinner", 
                    "description" => "chicken BBQ", 
                    "id" => "1",
                    "tags" => "best",
                    "uploads" => "imagefile.png")
    assert_equal "dinner", idea.title
    assert_equal "chicken BBQ", idea.description
    assert_equal "1", idea.id
    assert_equal "best", idea.tags
    assert_equal "imagefile.png", idea.uploads
  end

  def test_it_has_a_data_hash_with_data_passed_in
    idea = Idea.new("title" => "dinner", 
                    "description" => "chicken BBQ", 
                    "id" => "1",
                    "tags" => "best",
                    "uploads" => "imagefile.png")
    expected = {    "title" => "dinner", 
                    "description" => "chicken BBQ", 
                    "votes" => 0,
                    "tags" => "best",
                    "uploads" => "imagefile.png",
                    "group" => "Misc"}
    assert_equal expected, idea.data_hash
    idea.like!
    expected2 = {    "title" => "dinner", 
                    "description" => "chicken BBQ", 
                    "votes" => 1,
                    "tags" => "best",
                    "uploads" => "imagefile.png",
                    "group" => "Misc" }
    assert_equal expected2, idea.data_hash
  end

  def test_it_gets_a_votes_of_0_initially
    idea = Idea.new
    assert_equal 0, idea.votes
  end

  def test_like_method_raises_the_vote_count_by_one_each_time
    idea = Idea.new
    assert_equal 0, idea.votes
    idea.like!
    assert_equal 1, idea.votes
    idea.like!
    assert_equal 2, idea.votes
  end

  def test_spaceship_operator_compares_votes
    idea = Idea.new
    bad_idea = Idea.new
    assert_equal 0, idea.<=>(bad_idea)
    idea.like!
    assert_equal -1, idea.<=>(bad_idea)
    bad_idea.like!
    bad_idea.like!    
    assert_equal 1, idea.<=>(bad_idea)
  end

  def test_it_gets_assigned_to_a_group
    idea = Idea.new("title" => "dinner", 
                    "description" => "chicken BBQ", 
                    "id" => "1",
                    "tags" => "best",
                    "uploads" => "imagefile.png",
                    "group" => "Travel")
    assert_equal "Travel", idea.group
    idea = Idea.new("title" => "dinner", 
                    "description" => "chicken BBQ", 
                    "id" => "1",
                    "tags" => "best",
                    "uploads" => "imagefile.png")
    assert_equal "Misc", idea.group
  end
end
