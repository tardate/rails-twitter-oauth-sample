require 'json'
require 'oauth/consumer'

class TwitterOauth

	class GeneralError < StandardError
	end
	class APIError < TwitterOauth::GeneralError
	end
	class UnexpectedResponse < TwitterOauth::APIError
	end	
	class APILimitWarning < TwitterOauth::APIError
	end
	

	# initialize the oauth consumer, and also access token if user_token and user_secret provided
    def initialize( user_token = nil, user_secret = nil )
		#RAILS_DEFAULT_LOGGER.info "TwitterOauth.initialize user_token=#{user_token}, user_secret=#{user_secret}" 
		@consumer = OAuth::Consumer.new(TWOAUTH_KEY, TWOAUTH_SECRET, { :site=> TWOAUTH_SITE  })
		@access_token = OAuth::AccessToken.new( @consumer, user_token, user_secret ) if user_token && user_secret
    end	
	
	# returns the consumer
	def consumer
		#RAILS_DEFAULT_LOGGER.info "TwitterOauth.consumer" 
		@consumer
	end
	
	# returns the access token, also initializes new access token if user_token and user_secret provided
    def access_token( user_token = nil, user_secret = nil )
		( user_token && user_secret ) ? @access_token = OAuth::AccessToken.new( self.consumer, user_token, user_secret ) : @access_token
    end
    def access_token=(new_access_token)
		@access_token = new_access_token || false
    end


	# when the callback has been received, exchange the request token for an access token
	def exchange_request_for_access_token( request_token,  request_token_secret, oauth_verifier )
		begin
			#request_token = self.request_token( request_token, request_token_secret )
			request_token = OAuth::RequestToken.new(self.consumer, request_token, request_token_secret)
			#Exchange the request token for an access token. this may get 401 error
			self.access_token = request_token.get_access_token( :oauth_verifier => oauth_verifier )
		rescue => err
			puts "Exception in exchange_request_for_access_token: #{err}"
			raise err
		end
	end
	
	# helper 
#	def  request_token( request_token,  request_token_secret )
#		#RAILS_DEFAULT_LOGGER.info "TwitterOauth. request_token: request_token=#{request_token}, request_token_secret=#{request_token_secret}" 
#		OAuth::RequestToken.new(self.consumer, request_token, request_token_secret)
#   end

	# gets a request token to be used for the authorization request to twitter 
	def get_request_token( oauth_callback = TWOAUTH_CALLBACK )
		self.consumer.get_request_token( :oauth_callback => oauth_callback )
	end

	
	# twitter API methods
	
	# Twitter REST API Method: account verify_credentials
	def verify_credentials
		begin
			response = self.access_token.get('/account/verify_credentials.json')
			case response
			when Net::HTTPSuccess
				credentials=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless credentials.is_a? Hash
				credentials
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in verify_credentials: #{err}"
			raise err
		end
	end

	# Twitter REST API Method: account rate_limit_status
	def rate_limit_status
		begin
			response = access_token.get('/account/rate_limit_status.json')
			case response
			when Net::HTTPSuccess
				status=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless status.is_a? Hash
				status
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in rate_limit_status: #{err}"
			raise err
		end
	end	
	
	# Twitter REST API Method: statuses friends
	def friends(user=nil)
		begin
			response = access_token.get("/statuses/friends#{ user ? '/' + user : '' }.json")
			case response
			when Net::HTTPSuccess
				friends=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless friends.is_a? Array
				friends
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in friends: #{err}"
			raise err
		end
	end

	# Twitter REST API Method: statuses followers
	def followers(user=nil)
		begin
			response = access_token.get("/statuses/followers#{ user ? '/' + user : '' }.json")
			case response
			when Net::HTTPSuccess
				followers=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless followers.is_a? Array
				followers
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in followers: #{err}"
			raise err
		end
	end
	
	# Twitter REST API Method: friendships exists
	# Will return true if user_a follows user_b, otherwise will return false.
	def friendship_exists?(user_a, user_b)
		begin
			return true if user_a == user_b
			response = access_token.get("/friendships/exists.json?user_a=#{user_a}&user_b=#{user_b}")
			case response
			when Net::HTTPSuccess
				response.body == 'true'
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in friendship_exists?: #{err}"
			raise err
		end
	end

	# Twitter REST API Method: friendships show
	def friendship_show?(user_a, user_b)
		begin
			return true if user_a == user_b
			response = access_token.get("/friendships/show.json?user_a=#{user_a}&user_b=#{user_b}")
			case response
			when Net::HTTPSuccess
				friendship=JSON.parse(response.body)
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in friendship_show?: #{err}"
			raise err
		end
	end
	
	# Twitter REST API Method: friendships create
	def follow!(new_friend)
		begin
			#return if current_user.screen_name == new_friend
			response = access_token.post("/friendships/create/#{new_friend}.json")
			case response
			when Net::HTTPSuccess
				friend=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless friend.is_a? Hash
				friend
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in follow!: #{err}"
			raise err
		end
	end
	
	# Twitter REST API Method: friendships destroy
	def unfollow!(unfriend)
		begin
			response = access_token.post("/friendships/destroy/#{unfriend}.json")
			case response
			when Net::HTTPSuccess
				friend=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless friend.is_a? Hash
				friend
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in unfollow!: #{err}"
			raise err
		end
	end

	# Twitter REST API Method: direct_messages
	def direct_messages( since_id = nil, max_id = nil , count = nil, page = nil )
		begin
			params = (
				{ :since_id => since_id, :max_id => max_id, :count => count, :page => page }.collect { |n| "#{n[0]}=#{n[1]}" if n[1] }
			).compact.join('&')
			response = access_token.get('/direct_messages.json' + ( params.empty? ? '' : '?' + params ) )
			case response
			when Net::HTTPSuccess
				messages=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless messages.is_a? Array
				messages
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in direct_messages: #{err}"
			raise err
		end
	end

	# Twitter REST API Method: direct_messages new
	def send_direct_message!( screen_name, text )
		begin
			response = access_token.post('/direct_messages/new.json', { :screen_name => screen_name, :text => text })
			case response
			when Net::HTTPSuccess
				message=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless message.is_a? Hash
				message
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in send_direct_message!: #{err}"
			raise err
		end
	end

	# Twitter REST API Method: statuses update
	def update_status!(  status , in_reply_to_status_id = nil )
		begin
			if in_reply_to_status_id
				response = access_token.post('/statuses/update.json', { :status => status, :in_reply_to_status_id => in_reply_to_status_id })
			else
				response = access_token.post('/statuses/update.json', { :status => status })
			end
			case response
			when Net::HTTPSuccess
				message=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless message.is_a? Hash
				message
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in update_status!: #{err}"
			raise err
		end
	end

	# Twitter REST API Method: statuses mentions
	def mentions( since_id = nil, max_id = nil , count = nil, page = nil )
		begin
			params = (
				{ :since_id => since_id, :max_id => max_id, :count => count, :page => page }.collect { |n| "#{n[0]}=#{n[1]}" if n[1] }
			).compact.join('&')
			response = access_token.get('/statuses/mentions.json' + ( params.empty? ? '' : '?' + params ) )
			case response
			when Net::HTTPSuccess
				messages=JSON.parse(response.body)
				raise TwitterOauth::UnexpectedResponse unless messages.is_a? Array
				messages
			else
				raise TwitterOauth::APIError
			end
		rescue => err
			puts "Exception in mentions: #{err}"
			raise err
		end
	end
	

	
end
