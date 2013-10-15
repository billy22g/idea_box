class Idea
  attr_reader :title, :description, :id, :votes

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @id = attributes["id"]
    @votes = 0
  end

  def data_hash
    {"title" => title,
     "description" => description,
     "votes" => votes}
  end

  def like!
    @votes += 1
  end

  def <=>(other)
    other.votes <=> votes
  end
end
