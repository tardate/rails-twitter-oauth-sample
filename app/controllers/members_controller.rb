class MembersController < ApplicationController

	include OauthSystem

	before_filter :oauth_login_required, :except => [ :callback, :signout, :index ]

	before_filter :init_member, :except => [ :callback, :signout, :index ]

	before_filter :access_check, :except => [ :callback, :signout, :index ]


	# GET /members
	# GET /members.xml
	def index
	end

	def new
		# this is a do-nothing action, provided simply to invoke authentication
		# on successful authentication, user will be redirected to 'show'
		# on failure, user will be redirected to 'index'
	end
	
	# GET /members/1
	# GET /members/1.xml
	def show
		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @member }
		end
	end

	def update_status
		if self.update_status!(params[:status_message])
			flash[:notice] = 'status update sent'
		else
			flash[:error] = 'status update problem'
		end
		redirect_to member_path(@member)
	end

	def partialfriends
		if (request.xhr?)
			@friends = self.friends()
			render :partial => 'members/friend', :collection => @friends, :layout => false
		else
			flash[:error] = 'method only supporting XmlHttpRequest'
			member_path(@member)
		end
	end

	def partialfollowers
		if (request.xhr?)
			@followers = self.followers()
			render :partial => 'members/friend', :collection => @followers, :as => :friend, :layout => false
		else
			flash[:error] = 'method only supporting XmlHttpRequest'
			member_path(@member)
		end
	end

	def partialmentions
		if (request.xhr?)
			@messages = self.mentions()
			render :partial => 'members/status', :collection => @messages, :as => :status, :layout => false
		else
			flash[:error] = 'method only supporting XmlHttpRequest'
			member_path(@member)
		end
	end

	def partialdms
		if (request.xhr?)
			@messages = self.direct_messages()
			render :partial => 'members/direct_message', :collection => @messages, :as => :direct_message, :layout => false
		else
			flash[:error] = 'method only supporting XmlHttpRequest'
			member_path(@member)
		end
	end


	
	
protected

	# controller helpers
	
	def init_member
		begin
			screen_name = params[:id] unless params[:id].nil?
			screen_name = params[:member_id] unless params[:member_id].nil?
			@member = Member.find_by_screen_name(screen_name)
			raise ActiveRecord::RecordNotFound unless @member
		rescue
			flash[:error] = 'Sorry, that is not a valid user.'
			redirect_to root_path
			return false
		end
	end
	
	
	def access_check
		return if current_user.id == @member.id
		flash[:error] = 'Sorry, permissions prevent you from viewing other user details.'
		redirect_to member_path(current_user) 
		return false		
	end	

	

end
