#!/usr/bin/expect -f
set timeout -1
spawn /splunkforwarder/bin/splunk start --accept-license
expect "Please enter an administrator username: "
send -- "adminforward\r"
expect "Please enter a new password: "
send -- "admin4orward\r"
expect "Please confirm new password: "
send -- "admin4orward\r"
expect eof
