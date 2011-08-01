Projects Dashboard
==================

A dashboard application that displays projects with commit data from GitHub post-hooks.
Sinatra server with CouchDB backend and Javascript to display and refresh the dashboard.

Inspired by the Panic Status Board

Installation and Setup
----------------------

Right now it's still kinda rough but easy enough to get up and running.

First start CouchDB with:

    couchdb

Simple enough.

Next run the server with:

    ruby -rubygems dash.rb

Lastly add the post-hook URL to any project you want to track on GitHub.
It will work with one project but looks better with multiple projects.

If you are running it locally and want to test if it works there is an included post.rb
script that will simulate a post request to the default localhost and por for Sinatra.
Just edit the post hash with the details you want displayed and run

    ruby post.rb
