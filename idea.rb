require 'yaml/store'

class Idea
    
    attr_reader :title, :description
    #the attr_reader bit above means we dont have to create seperate methods in order to show/edit what the content of a title or description actually is. Note we pass in what the title or description is for now
    def initialize(title,description)
        @title = title 
        @description = description
    end
    #we create this method as when we initialize an idea with idea.new we want to be able to pass it arguments e.g. idea = Idea.new("app, "social network for dogs")
    #but we also need to make the title and description available for use to the save method. Hence inside we define them as instance variables and add an attr_reader for them
    #we then refactor this so the initialize method takes a hash 
    
    def self.database
       @database ||= YAML::Store.new "ideabox"
       #so this database method will either fetch the database or create a new database called ideabox, this is because of the conditional assignment operator we have used
       #note that this database method is only available to instances of Idea not the Idea class itself
    end
    
    def database
        Idea.database
    end
    #so now with the aboe methods we can now get our database be it either an instance method or class method
    
    def save
        database.transaction do |db|
            #the above makes a call to the YAML store database we defined above. It refers to the database with a local variable db
            db['ideas'] ||= []
            #in the above we tell the database that there should be an array in it called ideas, if not we are going to make one
            db['ideas'] << {title: title, description: description}
            #in the above we are taking the just made ideas array and shovelling some hash data into it that we have made up
            #we then slightly change this to instead shovel a title and description that we define when the class is initatied
        end
    end
    

    def self.raw_ideas
        database.transaction do |db| 
            db['ideas'] || []
        end
        #so the abobe method takes the database we created and conditionaly assigns it to an array
    end 
    
    def self.all
        raw_ideas.map do |data|
            new(data[:title],data[:description])
        end
        #so this method takes the array we created from self.raw_ideas and returns idea instances
    end
    
    def self.delete(position)
        database.transaction do 
            database['ideas'].delete_at(position)
        end
        #the above method goes into the database array called ideas and deletes at given position
        #but the problem is the position needs to be an integer not a string for .delete_at(position) to work. HTTP requrest are always made of strings. So when you use params in sinatra the values are always strings
    end
    
    def self.find(id)
        raw_idea = find_raw_idea(id)
        Idea.new(raw_idea[:title], raw_idea[:description])
        #at first this method returns the raw hash of an idea from the database
        #we then made a change to create take the raw hash and create a new instance with it
    end
    
    def self.find_raw_idea(id)
        database.transaction do 
            database['ideas'].at(id)
            #this method seems to find a single raw idea as a hash
        end 
    end
    
    def self.update(id,data)
        database.transaction do 
            database['ideas'][id] = data
        end
        #this method takes the id and 'data' hash we created from sinatra params and updates the idea we choose to edit
    end
    
        
end
