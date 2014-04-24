class WelcomeController < ApplicationController
  @resourse_url

  def index
    oneNoteClient = OneNoteSharer.new
    @auth_url = oneNoteClient.authUrl
  end

  def submit
    @resourse_url = nil
    @response_code = nil
    oneNoteClient = OneNoteSharer.new
    access_token = cookies['access_token']
    result = nil
    case params[:submit]
      when 'text'
        result = oneNoteClient.createPageWithSimpleText access_token
      when 'textimage'
        result = oneNoteClient.createPageWithTextAndImage access_token
      when 'url'
        result = oneNoteClient.createPageWithScreenshotFromUrl access_token
      when 'html'
        result = oneNoteClient.createPageWithScreenshotFromHtml access_token
      when 'file'
        result = oneNoteClient.createPageWithFile access_token

    end
    if !result.nil?
      @resourse_url = result['links']['oneNoteWebUrl']['href']
    end
  rescue Exception => e
    @response = e.response
    @response_code = e.http_code
  end

  def callback
    oneNoteClient = OneNoteSharer.new
    token_set = oneNoteClient.handleCallbackRequest (params)
    if !token_set.nil?
      expire_in = token_set['expires_in'].to_i
      cookies['access_token'] = { :value => token_set['access_token'], :expires => expire_in.seconds.from_now }
      cookies['authentication_token'] = { :value => token_set['authentication_token'], :expires => expire_in.seconds.from_now }
      cookies['scope'] = { :value => token_set['scope'], :expires => expire_in.seconds.from_now }
      refresh_token = token_set['refresh_token']
      if !refresh_token.nil?
        oneNoteClient.saveRefreshToken refresh_token
      end
    end
  end

end
