require 'yaml/store'
require './lib/idea_box/idea'

class IdeaStore 

  class << self    

    def database
      @database ||= YAML::Store.new "db/ideabox"
    end

    def create(attributes)
      database.transaction do |db|
        db["ideas"] ||= []
        db["ideas"].push(attributes)
      end
    end

    def idea_data
      database.transaction {|db| db["ideas"] || []}
    end

    def all
      idea_data.each_with_index.collect do |attributes, index|
        Idea.new(attributes.merge("id" => index))
      end
    end

    def destroy_database
      database.transaction do |db|
        db["ideas"] = []
      end
    end

    def delete(position)
      database.transaction do |db|
        db["ideas"].delete_at(position)
      end
    end

    def idea_data_for_id(id)
      database.transaction do |db|
        db["ideas"].at(id)
      end
    end

    def find(id)      
      Idea.new(idea_data_for_id(id).merge("id" => id))
    end

    def update(id, edits)
      idea = IdeaStore.find(id)
      updated = idea.data_hash.merge(edits)
      database.transaction do |db| 
        db["ideas"][id] = updated
      end
    end

    def search(search_term)
      IdeaStore.all.select do |idea|
        split_tags = idea.tags.split(", ")
        split_tags.any? do |tag|
          tag == search_term
        end
      end      
    end

    
  end
end
