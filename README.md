# AWS Lambda: S3 Cleanup Function

## Overview

This AWS Lambda function performs automated cleanup of an S3 bucket based on file age and frequency. It intelligently retains a minimal set of backups or logs by evaluating each file's last modified date and structured filename, thereby controlling S3 storage costs and maintaining only essential historical data.

The function is written in Ruby and assumes that file names include a date in the format `YYYY-MM-DD`.

---

## How It Works

The function connects to the specified S3 bucket and processes each object according to its `last_modified` timestamp. Based on how old each file is, the script applies different cleanup rules:

* **Files 8–31 days old**:

  * Keep only one file per day.
  * Delete all other files from the same day with the same root name.

* **Files 32–365 days old**:

  * Keep only files from the 1st day of each month.
  * Delete all others.

* **Files older than 1 year**:

  * Keep only files from the 1st day of the year.
  * Delete all others.

To avoid deleting all instances, it keeps track of how many files exist for a given key and day.

The script relies on parsing the date from the filename using a regex (`YYYY-MM-DD`) and groups files by their root key (filename prefix before the date).

---

## Environment Variables

This script expects the following environment variables to be set:

* `BUCKET_NAME` — The name of the S3 bucket to clean up.
* `REGION` — The AWS region the bucket is in.
* `TIMEZONE` — The IANA timezone string used for time calculations (e.g., `America/Los_Angeles`).

These are accessed via a helper function `fetch_env()` in the `settings.rb` file.

---

## Deployment Instructions

To deploy or update this Lambda function:

```bash
zip -r function.zip script.rb log.rb vendor
aws lambda update-function-code --function-name s3_cleanup --zip-file fileb://function.zip
```

---

## Notes

* The script uses the AWS SDK for Ruby (`aws-sdk-s3`). Ensure this and any dependencies are included in the `vendor` directory prior to zipping.
* Logging functions (`log`) are assumed to be defined in the `log.rb` file.
* The script uses ActiveSupport for time zone support; make sure it is installed and packaged.

---

## Use Cases

* Automated log pruning
* Historical data retention management
* S3 cost optimization strategies

---

## Requirements

* Ruby runtime environment in AWS Lambda
* AWS IAM role with permissions to list and delete S3 objects
* Proper packaging of dependencies (via `vendor` folder or bundler)

---

## License

MIT License

---

For questions or support, please contact info@ijabat.org.
