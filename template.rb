# template.rb
run "bundle install"
run "yarn install"
rails_command "db:create"

git :init
git add: "."
git commit: %Q{ -m 'Initial commit from template' }