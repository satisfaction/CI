require 'rubygems'
require 'glowy_orb'
require 'json'
require 'net/http'

module Jenkins
  class Job
    attr_reader :name, :status    

    def initialize(opts)
      @name   = opts['name']
      @status = opts['color']
    end
  
    def is_running?
      @status =~ /anime/
    end
  
    def success?
      @status =~ /blue/
    end
  
    def failure?
      @status =~ /red/
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

Jenkins.set_config( host, port )
the_ball = GlowyOrb.new

the_ball.build_initiated
current_status = ''

while true
  dev_build = Jenkins::Job.get('dev', host, port)
  # wait 2 seconds! Why 2 seconds, well because I SAYS SO!
  sleep 2
  next if current_status == dev_build.status
  current_status = dev_build.status
  
  if dev_build.is_running? 
    puts 'is runno'
    the_ball.build_initiated
  elsif dev_build.success? 
    the_ball.build_succesfull
  elsif dev_build.failure?
    the_ball.build_failure
  else
    #turn off the ball
  end

end
