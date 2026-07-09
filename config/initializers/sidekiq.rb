# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(
      Rails.root.join("config/sidekiq.yml")
    )[:schedule]

    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end