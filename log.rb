# frozen_string_literal: true

TIMEZONE = fetch_env('TIMEZONE')

## -----------------------------------------------------------------------------
## basic logging method
## -----------------------------------------------------------------------------
def log (level, message)
  raise ArgumentError, 'invalid log level' unless %i[debug warn info fatal].include?(level)

  time = Time.now.in_time_zone(TIMEZONE)
  upcase_level = level.to_s.upcase

  puts "#{upcase_level}, [#{time}] #{message}" if level == :debug || level == :fatal
  puts "#{upcase_level},  [#{time}] #{message}" if level == :warn || level == :info
end
