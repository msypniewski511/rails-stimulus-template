# Run with:
# rails new my_app -T -d postgresql --css=tailwind --javascript=esbuild -m https://raw.githubusercontent.com/msypniewski511/rails-stimulus-template/main/template.rb

say "🛠 Setting up Tailwind, StimulusReflex, CableReady, Redis, Mrujs..."

# ⬇️ Clone and apply external template files (e.g., package.json, tailwind.config.js)
REPO_URL = "https://github.com/msypniewski511/rails-stimulus-template.git"
TEMP_CLONE_PATH = "tmp_template_clone"

say "🔄 Cloning files from #{REPO_URL}..."
run "git clone --depth=1 #{REPO_URL} #{TEMP_CLONE_PATH}"

%w[
  package.json
  yarn.lock
  postcss.config.js
  tailwind.config.js
].each do |file|
  source = File.join(TEMP_CLONE_PATH, file)
  run "cp #{source} ./#{file}" if File.exist?(source)
end

run "rm -rf #{TEMP_CLONE_PATH}"

# Reinstall node dependencies
say "📦 Installing Yarn packages from updated package.json..."
run "yarn install"

# Create Tailwind entrypoint
empty_directory "app/assets/stylesheets"
create_file "app/assets/stylesheets/application.tailwind.css", <<~CSS
  @tailwind base;
  @tailwind components;
  @tailwind utilities;
CSS

# Gemfile additions
append_to_file "Gemfile", <<~RUBY

  # ✅ Real-time & Reflex
  gem "stimulus_reflex", "~> 3.5"
  gem "cable_ready"
  gem "redis", "~> 4.0"
  gem "redis-session-store", "~> 0.11.6"
RUBY

# Redis session store config (development)
inject_into_file "config/environments/development.rb", before: /^end/ do
  <<~RUBY

    config.cache_store = :redis_cache_store, {
      url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
    }

    config.session_store :redis_session_store,
      key: "_sessions_development",
      compress: true,
      pool_size: 5,
      expire_after: 1.year
  RUBY
end

# Action Cable Redis config
create_file "config/cable.yml", <<~YAML
  development:
    adapter: redis
    url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
    channel_prefix: my_app_development

  test:
    adapter: test

  production:
    adapter: redis
    url: <%= ENV["REDIS_URL"] %>
    channel_prefix: my_app_production
YAML

# UUID default for models
create_file "config/initializers/generators.rb", <<~RUBY
  Rails.application.config.generators do |g|
    g.orm :active_record, primary_key_type: :uuid
  end
RUBY

# After dependencies installed
after_bundle do
  say "🧠 Post-install: Setting up JavaScript and Reflex..."

  run "rails javascript:install:esbuild"

  # StimulusReflex & CableReady
  run "rails stimulus_reflex:install"

  say "✅ Setup complete!"
end
