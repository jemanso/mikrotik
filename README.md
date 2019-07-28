# Mikrotik RouterOS
{ Tips, Tools, Commands, Scripts ... }

Commands manual:
- https://wiki.mikrotik.com/wiki/Manual:Scripting#Commands

## Useful terminal commands

```
/system script environment print
:put [/system clock get time-zone-name]
```

## DynDNS IP Update
* /scripts/dyndns_ip_update.rsc

API Resources
- Request details http://www.dyndns.com/developers/specs/syntax.html
- Response details https://help.dyn.com/remote-access-api/return-codes/

Installing
* go to "System/Scripts"
* create a new script "dynupdate" in your RouterOS
* copy and paste the content of ``/scripts/dyndns_ip_update.rsc``
* set the correct values for the variables: *dynUser*, *dynSKey*, *dynHost* ...

Scheduling
* go to "System/Scheduler"
* create a scheduled job to run the script periodically

```config
name = dynupdate
interval = 00:05:00
command = /system script run dynupdate
```
