require "purgecss_rails"

namespace :purge_css do
  desc "Clear previous CSS files, this busts the CSS cache"
  task :clear do
    `find public/assets -type f -name '*.css' -print -delete`
    `find public/assets -type f -name '*.css.gz' -print -delete`
  end

  desc "Optimize css files with PurgeCSS"
  task :run do
    PurgecssRails.configure(purge_css_path: "node_modules/purgecss/bin/purgecss.js") do |purge|
      purge.search_css_files("public/assets/**/*.css")

      purge.match_html_files "public/assets/**/*.js",
                             "app/views/**/*.html.erb",
                             "app/helpers/**/*.rb"

      purge.optimize!
    end.enable!.run_now!
  end
end
