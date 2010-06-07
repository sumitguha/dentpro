# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

# clearance
HOST = "localhost"

# email config
DENTPRO_EMAIL_RECIPIENTS = 'sumitguha2@gmail.com'
DENTPRO_EMAIL_FROM = 'dentpro@rempe.us'

ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address  => "smtp.gmail.com",
  :port  => 587,
  :user_name  => DENTPRO_EMAIL_FROM,
  :password  => "1108will",
  :authentication  => :login
}

# turn off the rails asset caching in dev when editing in 'css edit' otherwise
# the page you are modifying is constantly changing under you due to rails' cache busting.
#ENV["RAILS_ASSET_ID"] = ''