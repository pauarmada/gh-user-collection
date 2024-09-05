# gh-user-collection
Find Github users!!

## Setup
1. Preferred Ruby version manager: [rbenv](https://github.com/rbenv/rbenv)
2. Install bundler `gem install bundler`
3. Perform `bundle install` to install other dependencies

## Keys
Uses [arkana](https://github.com/rogerluan/arkana) for keys obfuscation.
1. To generate the Arkana package, make sure to create a `.env` file with the correct keys
    1. `githubToken`
        * On GitHub, visit your account's settings, select "Developer settings", then select "Personal access tokens" and finally click "Generate new token"
        * Leave all the checkboxes empty
2. Running `bundle exec arkana -c .arkana.yml -e .env -l swift` to re-generate the Arkana package
