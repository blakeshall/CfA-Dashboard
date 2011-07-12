# dash.rb
require 'rubygems'
require 'sinatra'

require 'httparty'
require 'json'

class DB
  include HTTParty
  base_uri 'localhost:5984/projects'
  format :json
  
  def new_doc(name, text)
    options = { :body => text, :headers => {'Content-Type' => 'application/json'} }
    self.class.put("/#{name}", options)
  end
  
  def get_all()
    self.class.get('/_all_docs?include_docs=true')
  end
  
  def get_doc(name)
    self.class.get("/#{name}")
  end
end

database = DB.new
projects = {}

database.get_all().parsed_response["rows"].each do |project|
  projects[project["id"]] = project["doc"]
end




get '/' do
  erb :index
  
end

get '/commit_data.json' do
  content_type :json
  projects.to_json
end

post '/commit' do
  push = JSON.parse(request.body.read)
  repo = push["repository"]
  repo_name = repo["name"].downcase
   if projects.has_key?(repo_name)
     # Exists
     projects[repo_name]["count"] += push["commits"].length
     projects[repo_name]["last"] =  push["commits"][0]["author"]["name"]
     projects[repo_name]["message"] = push["commits"][0]["message"]
     database.new_doc(repo_name, projects[repo_name].to_json)
     projects[repo_name] = database.get_doc(repo_name)
   else
     # Doesn't exist create it
     projects[repo_name] = repo
     projects[repo_name]["count"] = push["commits"].length
     projects[repo_name]["last"] =  push["commits"][0]["author"]["name"]
     projects[repo_name]["message"] = push["commits"][0]["message"]
     database.new_doc(repo_name, projects[repo_name].to_json)
     projects[repo_name] = database.get_doc(repo_name)
   end
   
   "Got your post"

end