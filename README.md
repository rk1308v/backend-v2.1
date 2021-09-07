# SMX Backend App

![](public/img/smx-200x75.png)

SMX Mobile Money App Backend Code

![Gem](https://img.shields.io/gem/v/ruby?label=ruby)
![Gem](https://img.shields.io/gem/v/rails?label=rails)
![Gem](https://img.shields.io/gem/v/puma?label=puma)
![Gem](https://img.shields.io/gem/v/spring?label=spring)
![Bitbucket Pipelines](https://img.shields.io/bitbucket/pipelines/smxaccounts/backend-v2.1)

This README contains steps that are necessary to get the application up and running.


# Versions
- **v2.1** - Current version in development

# Requirements
* `Ruby version - 2.6.5`
* `Rails Version - ~> 6.1.4`
* `Puma Version - ~> 3.0`

# Instructions

## Database Set up
```
1. Database - Postgres / MySQL

2. Database creation

   rake db:create

3. Database Migration

   rake db:migrate

4. Database seeding

   rake db:seed # Do it first time only

5. How to run the test suite

   bundle exec rspec
```

## Run application
Steps to run application

    1. Run "bundle install" inside the application

    2. Run the database creation/migration steps

    3. Start the server using "rails s" command

    4. Check the API documentation on - http://localhost:3000/apipie (Don't specify the port in production) -> (username == "admin@money-api.com" && password == "Password")

    5. In config/application.yml, please enter the correct twilio authentication values to send the messages to phone. The Api will not send messages until those values are correct.

    6. In config/application.yml, enter the AWS S3  credentials for file store.


## Deploy applicaton

### Staging setup for BitBucket & Heroku (Only development/staging setup)

    1.  BitBucket:
        Clone:git clone git@bitbucket.org:smxapp/backend-v2.1.git
        Init existing code: git remote add origin git clone git@bitbucket.org:smxapp/backend-v2.1.git

    2.  Heroku:
        `Setup:` git remote add staging git@heroku.com:stormy-money-api-app-staging.git

P.S.: Application is deployed to master manually

### Push code to BitBucket
Command to push to BitBucket (Developers will use development branch only):
```
1. git add .
2. git commit -m "Commit message"
3. git push origin development
```

### Push code to Heroku
Command to push to Heroku (Developers will use development branch only):
```
1. git add .
2. git commit -m "Commit message"
3. git push staging development:master -> This will directly push to Heroku staging app (stormy-money-api-app-staging)
```

# Contribution guidelines
* Follow MVC Architecture
* Use IOS best practices
* Write tests
* Code review
* Create builds

# Contact
For information or to request access:
* SMX Mobile Money - info@smxmoney.com 


# Copyright Information
**SMX Mobile Money**  
Copyright (c) 2013-2019 `SMX International Inc.` All Rights Reserved. 

NOTICE: This product includes software developed at `SMX International Inc.` All information contained herein is, and remains the property of `SMX International Inc.` and its affiliates, if any. This product is protected by U.S and international copyright laws. Reproduction and distribution of any file from this product is strictly prohibited without prior written permission from `SMX International Inc.`
