# template.rb
# Run with:
# rails new my_app -T -d postgresql --css=tailwind --javascript=esbuild -m https://raw.githubusercontent.com/msypniewski511/rails-stimulus-template/main/template.rb

say "🛠 Setting up Tailwind, StimulusReflex, CableReady, Mrujs..."

# Tailwind + ESBuild config
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

empty_directory "app/assets/stylesheets"
create_file "app/assets/stylesheets/application.tailwind.css", <<~CSS
  @tailwind base;
  @tailwind components;
  @tailwind utilities;
CSS

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

# Gems
append_to_file "Gemfile", <<~RUBY
  gem "stimulus_reflex", "~> 3.5"
  gem "redis-session-store", "~> 0.11.6"
RUBY

# Redis dev env config
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

create_file "config/cable.yml", <<~YAML
  development:
    adapter: redis
    url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
    channel_prefix: my_app_development
YAML

create_file "config/initializers/generators.rb", <<~RUBY
  Rails.application.config.generators do |g|
    g.orm :active_record, primary_key_type: :uuid
  end
RUBY

after_bundle do
  say "🧠 Post-install: Checking JS bundler..."

  if File.exist?("package.json") && File.read("package.json").include?("esbuild")
    say "💡 JavaScript detected — running StimulusReflex install"
    run "rails stimulus_reflex:install"
  else
    say "⚠️ Skipping StimulusReflex install — JavaScript bundler not detected."
  end

  say "✅ Done!"
end
