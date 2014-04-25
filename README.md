#OneNote API Ruby on Rails Sample README

Created by Microsoft Corporation, 2014. Provided As-is without warranty. Trademarks mentioned here are the property of their owners.
 
###API functionality demonstrated in this sample
This sample illustrates how to use the OneNote REST API for the following use cases:
    
* Authenticate the user in an Ruby on Rails app
* Create a OneNote page with simple HTML 
* Create a page with a URL rendered as an image on the page
* Create a OneNote page with multi-part message with image data included in the request
* Create a OneNote page with a PDF file attachment
 

###Prerequisites

#####Tools and Libraries

You will need to download, install, and configure for your Ruby on Rails development environment. If you are new to Ruby on Rails, please go to [http://rubyonrails.org/download](http://rubyonrails.org/download) to get started.

Once you have your Ruby on Rails environment up and running, be sure to verify the prerequisites for these too (in Gemfile for yours app).
    
   * gem 'jquery-rails'
   * gem 'rest-client'	
   * gem 'rest-client-multipart'
    

#####Microsoft Account
    
As the developer, you'll need to have a [Microsoft account](http://msdn.microsoft.com/EN-US/library/office/dn575426.aspx) and get a client ID so your app can authenticate with the Microsoft Live connect services.
    

###Using the sample###

After you've setup your development tools, and installed the prerequisites listed above,....

   1. Download the repo as a ZIP file to your local computer, and extract the files. Or, clone the repository into a local copy of Git. 
   2. Get a client ID string and copy it into the file: config/onenote.yml 
   3. Setup route for yours callback path in the routes.rb 
   4. Build and run the Ruby on rails app. 
   5. Authenticate in the running app, using your Microsoft account. 
   6. Allow the app to create new pages in OneNote. 
