class HomeController < ApplicationController
require 'linkedin'
require "prawn"
 
  def index 
  end
  
 def auth
    client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
    request_token = client.request_token(:oauth_callback=>root_url+"home/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to client.request_token.authorize_url
end

    def callback
    client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
      pin = params[:oauth_verifier]
      atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
        
        @profile=client.profile(:fields => ["id", "first-name", "last-name", "public-profile-url", "email-address", "positions", "educations","projects", "skills", "member-url-resources"])
        id=@profile["id"]
        #save data to db
        user=User.find_or_create_by_user_id(id)
        user.update(:user_id=>id, :atoken=>atoken, :asecret=>asecret)
        redirect_to :controller=>"home", :action=>"resume", :id=>id, :format=>"pdf"
    end
    
    #provide link to refresh/reauth
  def resume
          client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
          user=User.where(:user_id=>params[:id]).first
      #try to grab updated data, if failed, fallback to db
      begin
          client.authorize_from_access(user.atoken, user.asecret)
           @profile=client.profile(:fields => ["id", "first-name", "last-name", "public-profile-url", "email-address", "positions", "educations","projects", "skills", "member-url-resources"])
          user.update(:profile=>@profile.to_json)
      rescue
      #grab user profile from db
      @profile=user.profile
      end

      respond_to do |format|
          format.pdf {
            pdf = Prawn::Document.new
            send_data pdf.render, filename: @profile["first_name"]+@profile["last_name"]+"Resume.pdf', type: 'application/pdf', disposition: 'inline'
}
          format.json  { render :json => @profile }
    end
  end
end