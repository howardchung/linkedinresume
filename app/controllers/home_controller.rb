class HomeController < ApplicationController
require 'linkedin'

  def index
    
  end
  
 def auth
     redirect_to "home/resume" unless session[:atoken].nil?
     
    client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
    request_token = client.request_token(:oauth_callback=>root_url+"home/resume")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to client.request_token.authorize_url
  end

  #flow for any user to generate on demand
  def resume
    client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      client.authorize_from_access(session[:atoken], session[:asecret])
    end
      @profile = client.profile(:fields => ["id", "first-name", "last-name", "public-profile-url", "email-address", "positions", "educations","projects", "skills", "member-url-resources"])
end

end
