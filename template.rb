# template.rb
# Run this script with:
# rails new my_app -T -d postgresql --skip-javascript -m https://raw.githubusercontent.com/msypniewski511/rails-stimulus-template/main/template.rb

say "🛠 Setting up Tailwind, Stimulus, CableReady, StimulusReflex, Mrujs..."

# Tailwind CSS and ESBuild setup
run "yarn add postcss-import chokidar @tailwindcss/forms"
create_file "postcss.config.js", <<~JS
  module.exports = {
    plugins: [
      require('postcss-import'),
      require('tailwindcss'),
      require('autoprefixer'),
    ]
  }
JS

# Tailwind entry point
empty_directory "app/assets/stylesheets"
create_file "app/assets/stylesheets/application.tailwind.css", <<~CSS
  @tailwind base;
  @tailwind components;
  @tailwind utilities;
CSS

# Tailwind config
create_file "tailwind.config.js", <<~JS
  module.exports = {
    mode: 'jit',
    content: [
      './app/views/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/assets/stylesheets/**/*.css',
      './app/javascript/**/*.js',
    ],
    theme: {
      extend: {},
    },
    plugins: [require('@tailwindcss/forms')],
  }
JS

# Add required gems
append_to_file "Gemfile", <<~RUBY

  gem "stimulus_reflex", "~> 3.5"
  gem "redis-session-store", "~> 0.11.6"
RUBY

# Redis caching config
gsub_file "config/environments/development.rb", /config\.cache_store = :memory_store/, <<~RUBY.chomp
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
  }

  config.session_store :redis_session_store,
    key: "_sessions_development",
    compress: true,
    pool_size: 5,
    expire_after: 1.year
RUBY

# ActionCable setup
create_file "config/cable.yml", <<~YAML
  development:
    adapter: redis
    url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
    channel_prefix: your_app_development
YAML

# UUID as default primary key
create_file "config/initializers/generators.rb", <<~RUBY
  Rails.application.config.generators do |g|
    g.orm :active_record, primary_key_type: :uuid
  end
RUBY

after_bundle do
  say "Cleaning up importmap (if accidentally installed)..."
  run("bin/rails importmap:uninstall") rescue say("Skipping importmap uninstall (not installed)")

  say "Installing stimulus_reflex..."
  run "rails stimulus_reflex:install"

  say "Done!"
end
