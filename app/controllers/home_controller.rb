class HomeController < ApplicationController
require 'linkedin'
  
  def index 
  end
  
 def auth
    @client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
    request_token = @client.request_token(:oauth_callback=>root_url+"home/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to @client.request_token.authorize_url
     
  end

    def callback
    @client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
      pin = params[:oauth_verifier]
      atoken, asecret = @client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
        
        id=@client.profile(:fields => ["id"])["id"]
        #save data to db
        user=User.find_or_create_by_user_id(id)
        user.update(:user_id=>id, :atoken=>atoken, :asecret=>asecret)
        redirect_to :controller=>"home", :action=>"resume", :id=>id
    end
    
  def resume
      @client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
      #retrieve tokens from db
      user=User.where(:user_id=>params["id"]).first
     
      begin
          @client.authorize_from_access(user.atoken, user.asecret)
      rescue
        #check for expired token, if expired, send to auth action
        redirect_to :controller=>"home", :action=>"auth"
        return
      end
      #TODO potential error when remote site tries to access this with an expired token, so cache the profile to DB, and provide link to update/refresh tokens on demand

      @profile=@client.profile(:fields => ["id", "first-name", "last-name", "public-profile-url", "email-address", "positions", "educations","projects", "skills", "member-url-resources"])
      respond_to do |format|
          format.html {}
          format.pdf {}
          format.json  { render :json => @profile }
    end
end
    
end
