activate :automatic_image_sizes

configure :development do
  activate :livereload
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :relative_assets
end

activate :deploy do |deploy|
  deploy.method = :rsync
  deploy.host = 'HOST'          # TODO
  deploy.port = 22
  deploy.user = 'USERNAME'      # TODO
  deploy.path = 'PATH'          # TODO
  deploy.build_before = true
end


Ferenc::Yss.load('data/yss.yml') unless Ferenc::Yss.current
