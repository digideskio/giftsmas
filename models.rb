require 'rubygems'
require 'digest/sha1'
require 'logger'
require 'sequel'

unless defined?(GIFTSMAS_ENV)
GIFTSMAS_ENV = ENV['GIFTSMAS_TEST'] ? :test : :production
end

begin
  load File.join(File.dirname(__FILE__), 'config.rb')
rescue LoadError
  DB = Sequel.connect(ENV['DATABASE_URL'] || "postgres:///giftsmas#{'_test' if GIFTSMAS_ENV != :production}")
end
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :prepared_statements_associations

%w'user event person gift'.each{|x| require "models/#{x}"}
