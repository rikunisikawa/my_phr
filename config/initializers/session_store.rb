# Configure cookies for sessions to work correctly when proxied through Cloudflare.
Rails.application.config.session_store :cookie_store,
  key: "_app_session",
  secure: true,
  same_site: :lax
