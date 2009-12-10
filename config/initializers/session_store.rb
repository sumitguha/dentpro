# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dentpro_session',
  :secret      => '1e29ee72a41c305867c36db87ada08a5ddafa3e6997f7b51afc5a2ec19c98558842305f993d6e72db3dbfa404e97b19b58e8c2180caf9edd6d35aef8f31a6f36'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
