# dash.rb
require 'rubygems'
require 'sinatra'
require 'time'
require 'httparty'
require 'json'

# Setup DB class for calls to the CouchDB database
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

  def new_db()
    self.class.put("")
  end
end

database = DB.new
projects = {}

# When the server is started check pull in the projects from the database and throw into a hash
if database.get_all().parsed_response["rows"] != nil
  database.get_all().parsed_response["rows"].each do |project|
    projects[project["id"]] = project["doc"]
  end
else
  database.new_db()
end
# Serve the dashboard page
get '/' do
  erb :index
end

# Return the projects as json
get '/commit_data.json' do
  weekly = projects
  weekly.each do |key, value|
    weekly[key]["count"] = 0
    value["commits"].each do |commit|
      time = commit["timestamp"]
      diff = Time.now - Time.parse(time.to_s)
      if diff > 604800.0
        puts("!!!!IN!!!!")
        weekly[key]["commits"].delete(commit)
      end
    end
    weekly[key]["count"] = weekly[key]["commits"].length
    if weekly[key]["count"] == 0
      weekly.delete(key)
    end
  end
  content_type :json
  weekly.to_json
end

# Handle GitHub post-hooks and add the information to the database and hash
post '/commit' do
  push = JSON.parse(request.body.read)
  repo = push["repository"]
  repo_name = repo["name"].downcase
   if projects.has_key?(repo_name)
     # Exists
     projects[repo_name]["count"] += push["commits"].length
     projects[repo_name]["last"] =  push["commits"][0]["author"]["name"]
     projects[repo_name]["message"] = push["commits"][0]["message"]
     projects[repo_name]["commits"] += push["commits"]
     database.new_doc(repo_name, projects[repo_name].to_json)
     projects[repo_name] = database.get_doc(repo_name)
   else
     # Doesn't exist create it
     projects[repo_name] = repo
     projects[repo_name]["count"] = push["commits"].length
     projects[repo_name]["last"] =  push["commits"][0]["author"]["name"]
     projects[repo_name]["message"] = push["commits"][0]["message"]
     projects[repo_name]["commits"] = push["commits"]
     database.new_doc(repo_name, projects[repo_name].to_json)
     projects[repo_name] = database.get_doc(repo_name)
   end

   "Got your post"

end
