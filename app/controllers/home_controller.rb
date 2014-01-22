class HomeController < ApplicationController
require 'linkedin'

 def index
    client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
    request_token = client.request_token(:oauth_callback =>
                                      root_url+"home/resume")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to client.request_token.authorize_url
  end

  #flow for any user to generate on demand
  def resume
    client = LinkedIn::Client.new(ENV["API_KEY"], ENV["API_SECRET"])
	  #hardcoded oauth tokens for page for howard to display publicly?
      session[:atoken] = ENV["USER_TOKEN"]
	  session[:asecret] = ENV["USER_SECRET"]
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      client.authorize_from_access(session[:atoken], session[:asecret])
    end
    @profile = client.profile
end


end
