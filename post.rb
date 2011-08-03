require 'net/http'
require 'time'
require 'rubygems'
require 'json'

@host = 'localhost'
@port = '4567'

@post_ws = "/commit"

@payload ={
  :before     => "before",
  :after      => "after",
  :ref        => "ref",
  :commits    => [{
    :id        => "commit.id",
    :message   => "I fixed something",
    :timestamp => "#{(Time.now - 800000).xmlschema}",
    :url       => "commit_url",
    :added     => "array_of_added_paths",
    :removed   => "array_of_removed_paths",
    :modified  => "array_of_modified_paths",
    :author    => {
      :name  => "someone",
      :email => "commit.author.email"
    }
  }],
  :repository => {
    :name        => "youcantseeme",
    :url         => "repo_url",
    :pledgie     => "repository.pledgie.id",
    :description => "repository.description",
    :homepage    => "repository.homepage",
    :watchers    => "repository.watchers.size",
    :forks       => "repository.forks.size",
    :private     => "repository.private?",
    :owner => {
      :name  => "repository.owner.login",
      :email => "repository.owner.email"
    }
  }
}.to_json

def post
     req = Net::HTTP::Post.new(@post_ws, initheader = {'Content-Type' =>'application/json'})
          #req.basic_auth @user, @pass
          req.body = @payload
          response = Net::HTTP.new(@host, @port).start {|http| http.request(req) }
           puts "Response #{response.code} #{response.message}:
          #{response.body}"
        end

thepost = post
puts thepost
