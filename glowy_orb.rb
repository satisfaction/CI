require 'rubygems'
require 'serialport'

class GlowyOrb

  def initialize
    @orb = SerialPort.new "/dev/ttyUSB0"
  end

  def build_initiated
    @orb.write("y") 
  end


  def build_succesfull
    @orb.write("g")
  end

  def build_failure
    @orb.write("r")
  end
end
