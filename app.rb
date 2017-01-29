require 'sinatra'
require 'data_mapper'


DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/project.db")
set :public_folder, File.dirname(__FILE__) + '/static'

enable :sessions
set :set_session_secret, "test"

class Tweet
	include DataMapper::Resource
	property :id, Serial
	property :data, String
	property :user_id, Integer
end
class User
	include DataMapper::Resource
	property :id, Serial
	property :username, String
	property :password, String
end
class Votes
	include DataMapper::Resource
	property :id, Serial
	property :tweet_id, Integer
	property :user_id, Integer
	property :upvotes, Integer
end

DataMapper.finalize

Tweet.auto_upgrade!
Votes.auto_upgrade!
User.auto_upgrade!

get '/' do
	#todos = Todo.all
	erb :index
end
get '/wall' do
	#todos = Todo.all
	tweets = Tweet.all
	users=User.all
	votes=Votes.all
	name=User.get(session[:user_id])
	erb :wall, :locals => {:tweets => tweets,:users =>users,:votes=>votes,:name=>name}
	
end
post '/session' do
	username = params[:username]
	password = params[:password]
	user = User.first({:username => username})
	if user
		if user.password == password
			puts "setting session user id to", user.id
			session[:user_id] = user.id
			redirect '/wall'
		else
			redirect '/'
		end
	else
		user = User.create(:username => username, :password => password)
		session[:user_id] = user.id
		redirect '/wall'
	end
end

post '/tweet' do
	data = params[:data]
	user_id =session[:user_id]
	tweet=Tweet.create(:data => data, :user_id => user_id)
	vote=Votes.create(:tweet_id=>tweet.id,:user_id=>user_id,:upvotes=>0)
	redirect '/wall'
	
end

get '/inc/:id' do
	id = params[:id]
	vote=Votes.first(:tweet_id=>id)
	vote.upvotes=vote.upvotes+1
	vote.save
	redirect '/wall'
	
end
