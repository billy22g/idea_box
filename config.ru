$:.unshift File.expand_path("./../lib", __FILE__)

require 'bundler'
Bundler.require

require 'sinatra'
require './lib/app/app'

run IdeaBoxApp
