# gh-user-collection
Find Github users!!

## About
1. Display all github users
2. Search for specific users
3. View user's list of repositories
4. View repository details

## Setup
1. Preferred Ruby version manager: [rbenv](https://github.com/rbenv/rbenv)
2. Install bundler `gem install bundler`
3. Perform `bundle install` to install other dependencies

## Keys
Uses [arkana](https://github.com/rogerluan/arkana) for keys obfuscation. The package itself is not checked-in for security purposes.
1. Create an `.env` file in the root folder if it does not exist. (You can copy the format from `.env.example`)
2. Update the value with the proper credentials
    1. `githubToken`
        * On GitHub, visit your account's settings, select "Developer settings", then select "Personal access tokens" and finally click "Generate new token" leaving all the checkboxes empty
        * Copy the generated key and replace the value in the environment file
3. Running `bundle exec arkana -c .arkana.yml -e .env -l swift` will generate the Arkana package. Run this script again whenever you update keys. 
