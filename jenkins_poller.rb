require 'rubygems'
require 'glowy_orb'
require 'json'
require 'net/http'
require 'ruby-debug'

DEBUG = 0

def debug(message)
  puts message if DEBUG == 1
end

module Jenkins
  NONE = 0
  FAILURE = 1
  SUCCESS = 2
  RUNNING = 4

  STATUS = {
    '' => NONE,
    'red' => FAILURE,
    'blue' => SUCCESS,
    'anime' => RUNNING
  }

  class Job
    attr_reader :name, :status    

    def initialize(opts)
      color = (opts['color'] =~ /anime/ ? 'anime' : opts['color']) 

      @name = opts['name']
      @status = STATUS[color]
    end
  
    def self.get(job_name, host, port)
      self.new(self.all.detect{|job| job['name'] == job_name})
    end

    def self.all
      response, data = Jenkins.connection.get('/api/json?tree=jobs[name,color]')
      JSON.parse(data)['jobs']
    end
  end

  module Configuration 
    def set_config(host, port)
      @host = host
      @port = port
    end    

    def connection
      @@connection ||= Net::HTTP.new(@host, @port)
    end
  end

  extend Configuration
end

# GET host and port from de command line PARAMS
host, port = ARGV

Jenkins.set_config(host, port)
the_ball = GlowyOrb.new

current_status = ''

while true
  dev_build = Jenkins::Job.get('dev', host, port)
  release_build = Jenkins::Job.get('release', host, port)

  debug "Dev status: #{dev_build.status}" 
  debug "Release status: #{release_build.status}" 

  # wait 2 seconds! Why 2 seconds, well because I SAYS SO!
  sleep 2

  new_status = dev_build.status | release_build.status
  next if new_status == current_status 
  current_status = new_status

  debug "Current Status bit value: #{current_status}"
  
  if current_status & Jenkins::RUNNING == Jenkins::RUNNING
    debug 'Running'
    the_ball.build_initiated
  elsif current_status == Jenkins::SUCCESS
    debug 'Success'
    the_ball.build_succesfull
  elsif current_status & Jenkins::FAILURE == Jenkins::FAILURE
    debug 'Failure'
    the_ball.build_failure
  else
    debug "Off"
  end

end
