# Rails StimulusReflex + Tailwind Template

A modern Ruby on Rails 7+ starter template preconfigured with:

- Tailwind CSS (via ESBuild + PostCSS)
- Stimulus (Hotwire)
- StimulusReflex
- CableReady
- Redis for caching and sessions
- Mrujs (modern JS UJS replacement)
- UUIDs enabled by default

Perfect for building reactive Rails applications with Hotwire + Reflex power.

---

## Why Use This Template?

Instead of spending hours configuring Tailwind, Redis, StimulusReflex, and other modern tools — use this prebuilt template and start building instantly.

---

## Quick Start

Create a new app using this template:

```bash
rails new my_app -d postgresql --skip-javascript -m https://raw.githubusercontent.com/msypniewski511/rails-stimulus-template/main/template.rb
cd my_app
bundle install
rails db:create
```

## Then finalize Reflex setup:

```bash
rails stimulus_reflex:install
rails generate stimulus controller example
```

## Features Included
 - Rails 7.1+

 - Tailwind CSS via PostCSS + ESBuild

 - Hot reload for JS via chokidar + EventSource

 - StimulusReflex 3.5.x

 - CableReady support

 - Mrujs installed and ready

 - Redis cache and session store

 - ActionCable via Redis

 - UUIDs as default primary key type

## File Structure (Highlights)
```arduino
app/
├── assets/stylesheets/application.tailwind.css
├── javascript/
│   ├── application.js
│   ├── controllers/
│   ├── channels/
│   └── esbuild.config.js
config/
├── environments/development.rb
├── cable.yml
```

## Development Setup
Use the Procfile and custom ESBuild watcher for hot reload:
Procfile.dev
```bash
web: bin/rails server -p 3000
js: node esbuild.config.js --watch
css: yarn build:css --watch
```
Start with:
```bash
bin/dev
```

## UUID Support
To enable UUIDs:

```bash
rails g migration EnableUuid
```

```ruby
# db/migrate/xxxxxx_enable_uuid.rb
class EnableUuid < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
```

If migration fails:

```bash
sudo -u postgres psql -d your_app_development
```
Then inside psql:

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
\q
```

Finish with:

```bash
rails db:migrate
```

Set global UUID preference:

```ruby
# config/initializers/generators.rb
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
```

## License
MIT
