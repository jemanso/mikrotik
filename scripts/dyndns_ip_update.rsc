# Author: Jose Eduardo Manso
# Create a scheduled job to run this script periodically
# command: /system script run dynupdate

:global dynUser "my_username"
:local dynSKey "my_password"
:global dynHost "my_domain.dyndns.org"
:global alertEmail "my_email"

:local dynForceUpdate false
:local dynBeepIPChanges true
:local dynRespFile "dyndns_lastresp.txt"
:local dynCheckIPFile "dyndns_checkip.txt"
:local dynLogPrefix "DynDNS:"

:global currentIP
:global previousIP

:global dynLastUpdate
:global dynLastResp
:local dynURL

:log info ("$dynLogPrefix $dynHost")

# DynDNS Response will be stored in "/$dynRespFile"
:if ([:len [/file find name=$dynRespFile]] > 0) do={
  :local ipfile [/file get $dynRespFile contents]
  :local ipstart ([find $ipfile " " -1] + 1)
  :local ipend [:len $ipfile]
  :set previousIP [:pick $ipfile $ipstart $ipend]
} else={
  :set previousIP "0.0.0.0"
}

# Get the current external IP address
/tool fetch mode=http address="checkip.dyndns.com" src-path="/" dst-path="/$dynCheckIPFile"
:delay 1s

# Parse DynDNS response
:local result [/file get $dynCheckIPFile contents]
:local resultLen [:len $result]
:local startLoc [:find $result ": " -1]
:set startLoc ($startLoc + 2)
:local endLoc [:find $result "</body>" -1]
:set currentIP [:pick $result $startLoc $endLoc]

# Check if IP has changed
:if (($currentIP != $previousIP) || ($dynForceUpdate = true)) do={
  :log info ("$dynLogPrefix updating $previousIP to $currentIP")
  :set dynForceUpdate false
  :set dynURL "http://$dynUser:$dynSKey@members.dyndns.org/v3/update?hostname=$dynHost&myip=$currentIP&wildcard=no"
  /tool fetch url=$dynURL mode=http dst-path="/$dynRespFile"
  :delay 1s
  :set dynLastResp [/file get $dynRespFile contents]
  :log info ("$dynLogPrefix update result - ".$dynLastResp)
  # Mark last update dateime
  :local msgDate [/system clock get date]
  :local msgTime [/system clock get time]
  :set dynLastUpdate "$msgDate $msgTime"
  # Beep if IP has changed
  :if ($dynBeepIPChanges = true) do={
    :beep length=1
  }
  # Send E-mail
  :if ($alertEmail ~ "@") do={
    :local msg "DynDNS last update response: $dynLastResp"
    /tool e-mail send to="$alertEmail" subject="$dynLogPrefix updated at $dynLastUpdate" body="$msg"
  }
} else={
  :log info ("$dynLogPrefix already up to date")
}
