class Idea
  attr_reader :title, :description, :id, :votes, :tags

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @id = attributes["id"]
    @votes = attributes["votes"] || 0
    @tags = attributes["tags"]
  end

  def data_hash
    {"title" => title,
     "description" => description,
     "votes" => votes,
     "tags" => tags}
  end

  def like!
    @votes += 1
  end

  def <=>(other)
    other.votes <=> votes
  end
end
