set :stage, :production
set :branch, 'asciidoc'

role :app, %w{ryanbigg@twistbooks.com}
role :db, %w{ryanbigg@twistbooks.com}

fetch(:default_env).merge!(rails_env: :production)
