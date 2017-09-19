require 'sinatra'
require 'sinatra/contrib'
require './idea'

set :method_override, true
#this code above just tells sinatra that you are creating dummy post routes that are really other routes with the correct information in the hidden inputs

configure :development do
    register Sinatra::Reloader
end

not_found do
    erb :error
end

get '/' do 
    erb :index, locals: {ideas: Idea.all}
    #notice above we are rendering the index template and also defining an empty array called ideas in its scope 
    #but passing over an empty area is not very useful we want to pass over all the ideas currently in the database. So we try locals: {ideas: Idea.all}. But we have to make an all method in the idea class first
end 

post '/' do
    #1. Create an idea based on the form parameters
    idea = Idea.new(params['idea_title'], params['idea_description'])
    #you hace created an idea but it has no content, you need to suck the content in from the params hash. 
    #the idea class you created takes in two paramaters an idea and a description. You need to set these two paramaters to the data you get from the form.
    #we know this data is stored in the params hash params.inspect returns {"idea_title" =>"boat", "idea_description" => "buy a mangusta"}. Notice the keys come from the name tag we defined in the html 
    #we are then able to pass the keys into idea.new. As params['idea_title'] = "boat" and params['idea_description'] = "buy a mangusta". We have something like idea=Idea.new("boat","buy mangusta")
    #2. Store it 
    idea.save
    #but we havent defined how we are actually going to save ideas, we are going to save them to a built in ruby database. When we create an instance of an idea it needs access to the database
    #3. Send us back to the index page to see all the ideas
    redirect '/'
    #at this point though the redirect does not show us an index page with the current ideas. So we need to get the ideas out of the database and display them on the index page
end 

delete '/:id' do |id|
    #1. Should delete the idea 
    Idea.delete(id.to_i)
    #but we have not yet defined a delete method
    #we went and defined the delete method but we had to to make it delete(id.to_i) to deal with the fact that the id we get from the sinatra route is stored as a string and .delete_at works only with integers
    #2. Should redirect us back to the route page 
    redirect '/'
end

get '/:id/edit' do |id|
    idea=Idea.find(id.to_i)
    #you just called the find method but first you need to define what this method does
    #we then created the find method it goes through the database and shows us all the different ideas. But we have to use Idea.find(id.to_i) because we cant index into an aray with a string
    erb :edit, locals: {id: id, idea: idea}
    #but when we click edit we want to be taken to a page where we can make our edits. So we will create an erb template called edit to deal with this and put it in the views directory
    #notice in the above we used /:id/edit. the :id is what sinatra gives us in that position as a local variable. So locals: {id: id} says create a local variable for our erb template with the name id which refers to the value of id in the route
    #we pass in the idea as a local variable to the edit template 
end

put '/:id' do |id|
    #at first we created a not so helpful put route to deal with an edit we make to an exisiting idea.
    #1. Want to update the idea in the database 
    #below we do this by building a hash called data from the form data sinatra stores in params 
    data = {
        :title => params['idea_title'],
        :description => params['idea_description']
    }
    #then we use a method update and pass the above data hash to it. We neeed to however create this method update in idea.rb. It is now made and works 
    Idea.update(id.to_i,data)
    #2. Redirect to the index page 
    redirect '/'
end 
