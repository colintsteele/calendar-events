# README
# Colin's Calendly app

This application renders my calendly event history at http://colinsteele.io.  The events are taken by an API Gateway endpoint on AWS and routed to my EC2 instance through a Lambda function.  Events are rendered in real time, through ActionCable, so if you send a meeting invite to my Calendly account, Colin Steele, the event (or events if it is a reschedule) will show up without the need for the page to be refreshed.  If for whatever reason my application is not running, events will be stored in an Amazon S3 bucket and saved to my database on application startup through a rails initializer.  

This app ended up having a more dev-ops/infrastructure focus as opposed to a focus on functionality around the data model coming from Calendly's API.  The reason for this is perhaps because my development team lost our ops engineer and has been relying more on the developers to get ops work done.  Because of this, I've been spending more time working on my skills with AWS and this assignment has been a good opportunity to exercise those skills.  Unfortunately, none of this is readily apparent when looking at the application's index page, but I'll be happy to demo it at the Calendly offices ;) 

# Issues
  - If events from Calendly can come in with the same Timecode, only the most recent one will be available on S3.
  - Several times throughout the development process, I had to change permissions for folders, such as `tmp/cache` for Rails' System Tests.  Once this happened with the development database as well.
  - The S3 gem stopped working briefly when it stopped being able to access my AWS config and didn't have a region name.  The solution was to add it to the `ENV` hash, and there's probably a better way to do this.
  - To avoid excessive migrations, I placed the entire event's `payload` json in a `text` field on the Event model.  This made it difficult to differentiate or classify events early.  I likely could have used a NoSQL database setup to achieve the same result, but I felt that would entail too much work and it wasn't something I saw myself doing in the future.
  - The Rails System tests are rather ugly and convoluted since I'm used to the Selenium syntax and not Capybara.  Additionally, the tests for my S3EventChecker class are rather implementation heavy as opposed to feature heavy - in other words they are very concerned with how my class works, and not as concerned that it simply does work.  This is probably because most of tested functionality is in AWS' hands, not mine.

# To do
  - Create a high-level integration test that makes sure AWS is receiving, storing, and forwarding the events properly.
  - Set up unique identifiers for events. 
  - Show only the most recent event/status for a meeting.
  - Add Event JSON parsable validation.
  - Put the initializer behind a `Rails::Command::ServerCommand` so that if your AWS infrastructure is not working, you can still run the application without touching the infrastructure.  Because of a `rescue` on `S3EventChecker` however, you should still be able to run the application regardless.
  - Use ActionCable's model syntax.
  - Add a feature flag to disable S3 event checking (mostly for testing purposes).


# AWS Infrastructure
  If you'd like to set up this application locally, or replicate the redundancy system for events, then you'll need to set up the AWS infrastructure, with most of the onus on the Lambda.
 
  - Create an S3 bucket with a unique name for your lambda.
  - Create a Lambda function on AWS targeted at Ruby 2.5.
  - Create an IAM role with the S3FullAccess policy for your lambda as well as a user with the appropriate access whose access and secret keys you'll plug into the Lambda as environment variables.  You'll also need to place these credentials in the `config/secrets.yml`  for your Rails app.
  - You'll need to create a folder for your lambda so you can upload it along with its dependencies to AWS...
  - Create a folder on a local machine with the following Gemfile:
 ```sh
source 'https://rubygems.org'
gem 'aws-sdk-s3'
```
  - Install your gems via Bundler then run `bundle install --deployment` in order to create a `vendor/bundle` folder.  Again make sure you're doing this on Ruby 2.5, since AWS doesn't support anything lower.
  - Create a file called `lambda_function.rb` with the following contents
````ruby
require 'json'
require 'net/http'
require 'uri'
require 'aws-sdk-s3'

COLIN_URL = 'yoururlgoeshere'
BACKUP_S3_BUCKET =  'yourbucketnamegoeshere'

def lambda_handler(event:, context:)
  send_to_colin(event['body'])
end

def send_to_colin(payload)
  uri = URI.parse(COLIN_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type': 'application/json'})
  request.body = payload
  begin
    response = http.request(request)
    {statusCode: 204}
  rescue Errno::ECONNREFUSED => e
    send_to_s3(payload)
    {statusCode: 204}
  end
end

def send_to_s3(payload)
  Aws.config[:credentials] = Aws::Credentials.new(ENV['access'], ENV['secret'])
  s3 = Aws::S3::Client.new
  
  resp = s3.put_object({
    body: payload, 
    bucket: BACKUP_S3_BUCKET,
    key: JSON.parse(payload)['time']
  })
end
````
  - Zip the folder up `zip -r yourlambdafoldername *`.  Don't do `zip -r ./*` inside of the lambda folder because you'll be zipping your compressed folder every time you have to make a change to the Lambda function and upload it.
  - Download and install the AWS CLI for terminal, and set up your AWS credentials.
  - `aws lambda update-function-code --function-name YourLambdaName --zip-file fileb://yourzipname.zip`
  - Create an API gateway endpoint with a `/post` resource and associate the endpoint with your lambda. This option will show up during the creation process.
  - Create a deploy resource for your API Gateway through CloudDeploy and deploy your API Gateway.
  - You should now see API Gateway as a trigger on your Lambda function's page.
  - That should be it!  If you have issues receiving requests, you can always check your Lambda's CloudWatch logs.

