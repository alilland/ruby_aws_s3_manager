# frozen_string_literal: true

require 'aws-sdk-s3'
require 'active_support/time'
require 'date'
require_relative './log.rb'

Dotenv.load
