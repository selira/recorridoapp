require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Recorridoapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Santiago"
    config.after_initialize do
      alerts = Alert.all
      alerts.each do |a|
        unless a.last_update.nil? #only execute if started before
          AlertJob.set(wait: 5.seconds).perform_later(a.id)
        end
      end
    end
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
