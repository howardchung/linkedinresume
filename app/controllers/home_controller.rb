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
        User.find_or_create_by_id(:user_id=>id, :atoken=>atoken, :asecret=>asecret)
        redirect_to :controller=>"home", :action=>"resume", :id=>id
    end
    
  def resume
      #potential error when remote site tries to access this with an expired token, so cache the required data and update it on demand?
      #check for expired token, if expired, send to auth action
      #support html/pdf/json output
      @client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
      #retrieve tokens from db
      user=User.where(:user_id=>params["id"]).first
      @client.authorize_from_access(user.atoken, user.asecret)
      @profile=@client.profile(:fields => ["id", "first-name", "last-name", "public-profile-url", "email-address", "positions", "educations","projects", "skills", "member-url-resources"])
      respond_to do |format|
          format.html
          format.pdf
          format.json  { render :json => @profile) }
    end
end
    
end
