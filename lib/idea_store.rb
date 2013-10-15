require 'yaml/store'
require './lib/idea'

class IdeaStore
    

    def self.database
      @database ||= YAML::Store.new "db/ideabox"
    end

    def self.create(attributes)
      database.transaction do |db|
        db["ideas"] ||= []
        db["ideas"].push(attributes)
      end
    end

    def self.idea_data
      database.transaction {|db| db["ideas"] || []}
    end

    def self.all
      ideas = []
      idea_data.each do |attributes|
        ideas.push(Idea.new(attributes))
      end
    end

    def self.destroy_database
      @database = nil
      File.delete('./db/ideabox')
    end
end
