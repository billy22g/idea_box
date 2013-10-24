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

    def get_next_id
      if idea_data == []
        1
      else
        ids = idea_data.collect { |idea_hash| idea_hash["id"] }
        ids.sort.last + 1
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

    # def clean_input
    #   IdeaStore.all.collect do |idea|
    #     idea.tags.gsub(/[^\w\s]/,"").split(" ")
    #   end
    # end

    def search_tags(search_term)
      IdeaStore.all.select do |idea|
        split_tags = idea.tags.split(", ")
        split_tags.any? do |tag|
          tag.downcase == search_term.downcase
        end   
      end  
    end

    def search_group(group)
      IdeaStore.all.select do |idea|
        idea.group == group
      end
    end

    def search_description(keyword)
      IdeaStore.all.select do |idea|
        split_words = idea.description.split(" ")
        split_words.any? do |word|
          word.downcase == keyword.downcase
        end
      end
    end

    def search_title(keyword)
      IdeaStore.all.select do |idea|
        idea.title.downcase == keyword.downcase
      end
    end

    def tags
      tags =  IdeaStore.all.collect do |idea|
                idea.tags.split(", ")
              end
      tags.uniq.join(', ')
    end
  end
end
