# frozen_string_literal: true

## to deploy this script run the following 2 commands:
## zip -r function.zip script.rb log.rb vendor
## aws lambda update-function-code --function-name s3_cleanup --zip-file fileb://function.zip
require_relative './settings.rb'

BUCKET_NAME = fetch_env('BUCKET_NAME')
REGION = fetch_env('REGION')
TIMEZONE = fetch_env('TIMEZONE')

## -----------------------------------------------------------------------------
## Script
## -----------------------------------------------------------------------------
def cleanup_s3(event:, context:)
  log :debug, 'starting'

  start = Time.now.in_time_zone(TIMEZONE).beginning_of_day
  script_start = Time.now.in_time_zone(TIMEZONE)

  client = Aws::S3::Client.new(region: REGION)
  s3 = Aws::S3::Resource.new(client: client)

  bucket = s3.bucket(BUCKET_NAME)

  log :debug, "successfully connected to s3 #{BUCKET_NAME}"

  obj = {}
  bucket.objects.each do |item|
    modified = item.data.last_modified

    ## using regex, extract the YYYY-MM-DD from the filename
    date_stamp = item.key[/(\d{4})-(\d{2})-(\d{2})/]

    ## get the root filename
    key = item.key.split(date_stamp)[0].chomp('_').chomp('.')

    ## Number of Days Since Modified (created)
    n = (start - modified).to_i / 86_400

    ## declare an in memory index to manage the number of occurrences of a file
    ## per day
    obj[key] = {} if obj[key].blank?
    obj[key][modified.year] = {} if obj[key][modified.year].blank?
    obj[key][modified.year][modified.month] = {} if obj[key][modified.year][modified.month].blank?
    obj[key][modified.year][modified.month][modified.day] = 0 if obj[key][modified.year][modified.month][modified.day].nil?

    ## based on how old the file is, determine whether it should be removed or not
    if n <= 31 && n > 7
      ## keep one per day
      ## remove if there are multiple on that day already
      if obj[key][modified.year][modified.month][modified.day].positive?
        log :debug, "removing #{item.key}"
        item.delete
      end
    elsif n <= 365 && n > 31
      ## keep the first day of the month
      ## remove if there are multiple on that day already
      if modified.day != 1 || obj[key][modified.year][modified.month][modified.day].positive?
        log :debug, "removing #{item.key}"
        item.delete
      end
    elsif n > 365
      ## keep the first of the year
      ## remove if there are multiple on that day already
      if modified.yday != 1 || obj[key][modified.year][modified.month][modified.day].positive?
        log :debug, "removing #{item.key}"
        item.delete
      end
    end

    ## update the in memory index to include the file occurrence
    obj[key][modified.year][modified.month][modified.day] += 1
  end

  log :info, "finished, #{Time.now.in_time_zone(TIMEZONE) - script_start}"
end
