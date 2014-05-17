module JsonMachinist
  def jsonist(string)
    arr = []
    string.lines.each do |line|
      arr << line.chomp.split('|')
    end
    arr.compact.reject { |arr| arr.all?(&:blank?) }
  end
end

module MemoryUsage
  def ram
    [
        [`/usr/bin/free | awk '{ print $1 }'`.lines[1].chomp],
        [`/usr/bin/free | awk '{ print $2 }'`.lines[1].chomp],
        [`/usr/bin/free | awk '{ print $3 }'`.lines[1].chomp]
    ]
  end
end

module Utilities

  Utils = {
      ruby: {version: '-v'},
      php: {version: '--version'},
      node: {version: '-v'},
      mysql: {version: '--version'},
      python: {version: '--version'},
      apache2: {version: '--version'},
      nginx: {version: '--version'},
      openssl: {version: 'version'},
      vsftpd: {version: '--version'},
      make: {version: '-v'}
  }

  def packages_content
    html = "Software|Installation\n"
    Utils.each do |package_name|
      html += "#{package_name.first.to_s}|#{`whereis #{package_name.first.to_s}`}\n"
    end
    html
  end

  def whereis
    jsonist(packages_content)
  end

end


module GeneralInformation

  def issue
    [`lsb_release -ds ` + `/bin/uname -r`].to_json
  end

  def uptime
    [`uptime`].to_json
  end

  def hostname
    [`/bin/hostname`].to_json
  end

  def time
    [`/bin/date`].to_json
  end

  def numberofcores
    [`LC_ALL=C /bin/grep -c ^processor /proc/cpuinfo`].to_json
  end

  def ps
    jsonist(`/bin/ps aux | awk '{print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 }'`)
  end

  def df
    jsonist(`/bin/df | awk '{print $1 "|"  $2 "|" $3 "|" $4 "|" $5 "|" $6 " "$7}'`)
  end

  def load_average
    [
        [`/bin/cat /proc/loadavg | /usr/bin/awk '{print $1}'`, `/bin/cat /proc/loadavg | /usr/bin/awk '{print $1}'`],
        [`/bin/cat /proc/loadavg | /usr/bin/awk '{print $2}'`, `/bin/cat /proc/loadavg | /usr/bin/awk '{print $2}'`],
        [`/bin/cat /proc/loadavg | /usr/bin/awk '{print $3}'`, `/bin/cat /proc/loadavg | /usr/bin/awk '{print $3}'`]
    ]
  end

  def numberofcores

  end

  #def load_avg_one_minute
  #  `/bin/cat /proc/loadavg | /usr/bin/awk '{print $1}'`
  #end
  #
  #def load_avg_five_minute
  #  `/bin/cat /proc/loadavg | /usr/bin/awk '{print $2}'`
  #end
  #
  #def load_avg_fiften_minute
  #  `/bin/cat /proc/loadavg | /usr/bin/awk '{print $3}'`
  #end

  def last_login
    jsonist(`/usr/bin/lastlog --time 365 | awk '{ print $1 "|" $2 "|" $3 "|" $5 "-" $6 "-" $4 " " $7 $8 " " $9}'`)
  end

  def swap
    jsonist(`/bin/cat /proc/swaps | /usr/bin/awk '{print $1"|"$2"|"$3"|"$4"|"$5}'`)
  end

  def users
    jsonist("Time|User|Home\n#{`/usr/bin/awk -F: '{if ($3<=499) print "system|"$1"|"$6; else print "user|"$1"|"$6; }' < /etc/passwd | sort -r`}")
  end

  def online
    jsonist(`PROCPS_FROMLEN=40 /usr/bin/w | /usr/bin/tail -n+2  | /usr/bin/awk '{print $1"|"$3"|"$4"|"$5"|"$8}'`)
  end

  def netstats
    jsonist("Number of Connections|	IP Address\n#{`netstat -ntu | awk '{print "|"$5}' | sort  | uniq -c`}")
  end

  def ping
    command_output = ''
    ['gnu.org', 'github.com', 'wikipedia.org'].each do |host|
      command_output += "#{host}|#{`/bin/ping -qc 2 'www.google.com' | /usr/bin/tail -n+5 | awk '{print $4}'`.split('/')[1]}\n"
    end
    jsonist("Host|Time (in ms)\n#{command_output}")
  end

end


module InternetProtocolAddress

  def ips
    output = ''
    #output += "Internal ip (eth0) | #{`for interface in eth0; do for family in inet inet6; do /bin/ip -oneline -family $family addr show $interface | /bin/grep -v fe80 | /usr/bin/awk '{print $4}'; done; done`}\n"
    #output += "Internal ip (wlan0) | #{`for interface in wlan0; do for family in inet inet6; do /bin/ip -oneline -family $family addr show $interface | /bin/grep -v fe80 | /usr/bin/awk '{print $4}'; done; done`}"
    #output += "External ip | #{`GET http://ipecho.net/plain`}"
    #raw table(output)
  end

end

module Bandwidth
  def bandwidth(type)
    _start = `cat /sys/class/net/eth0/statistics/#{type}_bytes`.chomp.to_i
    sleep(2)
    _end = `cat /sys/class/net/eth0/statistics/#{type}_bytes`.chomp.to_i
    (_end - _start)
  end
end

module Gutter
  module GutterHelper
    include JsonMachinist
    include GeneralInformation
    include Utilities
    include MemoryUsage
    include InternetProtocolAddress
    include Bandwidth
  end
end

