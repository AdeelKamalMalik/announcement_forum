# README

## _Development Setup_
Follow the steps below to setup and run app locally.

* Add Postgres Database user/password in config/database.yml

* rvm install ruby-3.0.2 (You can use any ruby version above 2.7.0)

* rvm use ruby-3.0.2 (You can use any ruby version above 2.7.0)

* gem install bundler

* bundler install

* rake db:create

* rake db:migreate

* rails server (http://localhost:3000)

* Use POSTMAN collection to run APIs (Load Environment File in POSTMAN) - Files present in docs/ folder

## _Run Rspec_
* rspec 