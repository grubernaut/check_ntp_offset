#!/usr/bin/ruby1.8

#----------------------------------------------------------------------------------------------------------
#
# Program Name: check_ntp_offset.rb
# Purpose:      To check ntp offset for Nagios without flipping out when an offset cannot be found
# Date:         11.12.13
# Author:       Jake Champlin
#
#----------------------------------------------------------------------------------------------------------

require 'ping'
require 'rubygems'
require 'net/ntp'
require 'time'

def showHelp()
	puts "USAGE: check_ntp_offset.rb [HOST] [WARN] [CRITICAL]"
	puts ""
	puts "ARGUMENTS"
	puts "\tHost -> IP, or DNS-Hostname of NTP Server"
	puts "\tWarn -> Offset time in (s) to issue warning flag at" 
	puts "\tCritical -> Offset time in (s) to critically warn and notify at"
end

def checkNTPAlive(host)
	return true if Ping.pingecho(host,10)
end

def retrieveOffset(host)
	Net::NTP.get("#{host}")
	time = Time.now().to_i
	offset = ((Net::NTP.get.receive_timestamp - Net::NTP.get.originate_timestamp) + (Net::NTP.get.transmit_timestamp - time) / 2)
        return offset
end

def checkOffset(offset,warn,crit)
	if ( offset >=0 ) 
		if (offset >= crit)
			puts "NTP Critical: Offset #{"%.4f" % offset} secs|offset=#{"%.4f" % offset}"
			exit(2)
		elsif (offset >= warn)
			puts "NTP WARNING: Offset #{"%.4f" % offset} secs|offset=#{"%.4f" % offset}"
			exit(1)
		else
			puts "NTP OK: Offset #{"%.4f" % offset} secs|offset=#{"%.4f" % offset}"
			exit(0)
		end
	else
		if (offset <= crit)	
			puts "NTP Critical: Offset #{"%.4f" % offset} secs|offset=#{"%.4f" % offset}"
			exit(2)
		elsif (offset <= warn)
			puts "NTP WARNING: Offset #{"%.4f" % offset} secs|offset=#{"%.4f" % offset}"
			exit(1)
		else
			puts "NTP OK: Offset #{"%.4f" % offset} secs|offset=#{"%.4f" % offset}"
			exit(0)
		end
	end

end

options = {}

if (ARGV.empty? || ARGV.length < 3 || ARGV.length >= 4)
	showHelp()	
	exit
else
	options[:host] = ARGV[0]
	options[:warn] = ARGV[1]
	options[:crit] = ARGV[2]
end

if (checkNTPAlive(options[:host]))
	offset = retrieveOffset(options[:host])
	checkOffset(offset,options[:warn].to_i,options[:crit].to_i)
else
	puts "NTP WARNING: NTP Server not alive|offset=nil"
	exit(1)
end
