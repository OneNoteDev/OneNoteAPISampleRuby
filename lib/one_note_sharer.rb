require "_payload"

class OneNoteSharer
  CLIENTID = ONENOTE_CONFIG['clientId']
  CALLBACK = ONENOTE_CONFIG['callback']
  CLIENTSECRET = ONENOTE_CONFIG['secret']

  OAUTH_AUTHORIZE_URL = "https://login.live.com/oauth20_authorize.srf"
  OAUTH_TOKEN_URL = "https://login.live.com/oauth20_token.srf"
  SHARE_URL = 'https://www.onenote.com/api/v1.0/pages'

  def auth_url
    scopes = ["wl.signin", "wl.basic", "wl.offline_access", "office.onenote_create"]
    redirect_url = "#{ONENOTE_CONFIG['callback']}&response_type=code&scope=#{scopes.join(' ')}"

    "#{OAUTH_AUTHORIZE_URL}?client_id=#{CLIENTID}&display=page&locale=en&redirect_uri=#{URI.escape(redirect_url)}"
  end

  def request_access_token (content)
    payload = {
        :client_id => CLIENTID,
        :redirect_uri => CALLBACK,
        :client_secret => CLIENTSECRET
    }
    response = RestClient.post(OAUTH_TOKEN_URL, payload.merge(content))
    JSON.parse(response)
  rescue Exception => exception
    nil
  end

  def request_access_token_by_verifier (verifier)
    request_access_token ({
        :code => verifier,
        :grant_type => 'authorization_code'
    })
  end

  def request_access_token_by_refresh (refresh_token)
    request_access_token ({
        :refresh_token => refresh_token,
        :grant_type => 'refresh_token'
    })
  end
  
  def read_refresh_token
    # read refresh token of the user identified by the site.
    nil
  end

  def save_refresh_token (refresh_token)
    # save the refresh token and associate it with the user identified by your site credential system.
  end

  def handle_callback_request (params)
    if params['access_token'].present?
      return nil
    end

    verifier = params['code']
    if verifier.present?
      token_set = request_access_token_by_verifier(verifier)
      save_refresh_token(token_set['refresh_token'])
      return token_set
    end

    refresh_token = read_refresh_token
    if refresh_token.present?
      token_set = request_access_token_by_refresh(refresh_token)
      save_refresh_token(token_set['refresh_token'])
      return token_set
    end

    nil
  end

  def get_post_headers (access_token, type=nil)
    return false if access_token.blank?
    #Since cookies are user-supplied content, it must be encoded to avoid header injection
    encoded_access_token = URI::escape(access_token)
    if type=='multipart'
      headers = {:content_type => "multipart/form-data; boundary=#{@boundary}", :'Authorization' => "Bearer #{encoded_access_token}"}
    else
      headers = {:content_type => "text/html", :'Authorization' => "Bearer #{encoded_access_token}"}
    end

    headers
  end

  def create_page_with_simple_text (access_token)
    headers = get_post_headers(access_token)
    date = Time.now.to_time.iso8601

    html_part = "
      <!DOCTYPE html>
      <html>
        <head>
          <title>A page created from basic HTML-formatted text (Ruby on Rails Sample)</title>
          <meta name=\"created\" value=\"#{date}\"/>
        </head>
        <body>
          <p>This is a page that just contains some simple <i>formatted</i> <b>text</b></p>
        </body>
      </html>"

    response = RestClient.post(SHARE_URL, html_part, headers)

    JSON.parse(response)
  end

  def create_page_with_file (access_token)
    headers = get_post_headers(access_token, 'multipart')
    date = Time.now.to_time.iso8601

    html_part = "
      <!DOCTYPE html>
      <html>
        <head>
          <title>A page with a file on it (Ruby on Rails Sample)</title>
          <meta name=\"created\" value=\"#{date}\"/>
        </head>
        <body>
          <object data-attachment=\"OneNote Logo.jpg\"
            data=\"name:embeddedFile\"
            type=\"image/jpeg\"
        </body>
      </html>"

    response = RestClient.post(SHARE_URL, {
        :multipart => true,
        :Presentation => html_part,
        :embeddedFile => File.open('Logo.jpg', 'rb')
    }, headers)

    JSON.parse(response)
  end

  def create_page_with_text_and_image (access_token)
    headers = get_post_headers(access_token, 'multipart')
    date = Time.now.to_time.iso8601

    html_part = "
      <!DOCTYPE html>
      <html>
        <head>
          <title>A page created containing an image (Ruby on Rails Sample)</title>
          <meta name=\"created\" value=\"#{date}\"/>
        </head>
        <body>
          <p>This is a page that just contains some simple <i>formatted</i> <b>text</b> and an image</p>
          <img src=\"name:imageData\" alt=\"A beautiful logo\" width=\"426\" height=\"68\" />
        </body>
      </html>"

    response = RestClient.post(SHARE_URL, {
        :multipart => true,
        :Presentation => html_part,
        :imageData => File.open('Logo.jpg', 'rb')
    }, headers)

    JSON.parse(response)
  end

  def create_page_with_screenshot_from_url (access_token)
    headers = get_post_headers(access_token)
    date = Time.now.to_time.iso8601

    html_part = "
    <!DOCTYPE html>
    <html>
      <head>
        <title>A page created with a URL snapshot on it (Ruby on Rails Sample)</title>
        <meta name=\"created\" value=\"#{date}\"/>
      </head>
      <body>
        <img data-render-src=\"http://www.onenote.com\" alt=\"An important web page\" />
        Source URL: <a href=\"http://www.onenote.com\">http://www.onenote.com</a>
      </body>
    </html>"

    response = RestClient.post(SHARE_URL, html_part, headers)

    JSON.parse(response)
  end

  def create_page_with_screenshot_from_html (access_token)
    headers = get_post_headers(access_token, 'multipart')
    date = Time.now.to_time.iso8601

    screenshot = "
      <html>
        <head><title>Embedded HTML</title></head>
        <body>
          <h1>This is a screen grab of a web page</h1>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vehicula magna quis mauris accumsan, nec imperdiet nisi tempus. Suspendisse potenti.
          Duis vel nulla sit amet turpis venenatis elementum. Cras laoreet quis nisi et sagittis. Donec euismod at tortor ut porta. Duis libero urna, viverra id
          aliquam in, ornare sed orci. Pellentesque condimentum gravida felis, sed pulvinar erat suscipit sit amet. Nulla id felis quis sem blandit dapibus. Ut
          viverra auctor nisi ac egestas. Quisque ac neque nec velit fringilla sagittis porttitor sit amet quam.</p>
        </body>
      </html>"

    html_part = "
      <!DOCTYPE html>
      <html>
        <head>
          <title>A page created with a screenshot of HTML on it (Ruby on Rails Sample)</title>
          <meta name=\"created\" value=\"#{date}\"/>
        </head>
        <body>
          <img data-render-src=\"name:HtmlForScreenshot\" />
        </body>
      </html>"

    response = RestClient.post(SHARE_URL, {
        :multipart => true,
        :Presentation => html_part,
        :HtmlForScreenshot => screenshot
    }, headers)

    JSON.parse(response)
  end
end

