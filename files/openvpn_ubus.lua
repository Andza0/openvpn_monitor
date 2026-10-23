#!/usr/bin/lua

require("ubus")
require("uloop")
require("management_commands")	
nixio = require("nixio")
uloop.init()


nixio.openlog("openvpn_ubus", "pid")

function log(level, message)
	nixio.syslog(level, tostring(message))
end

name = arg[1]
if not name then
	log("err", "Missing server name")
end

management = arg[2]
if not management then
	log("err", "Missing management interface")
end

local conn = ubus.connect()
if not conn then
	log("err", "Failed to connect to ubus")
end

local objects = {
	[name] = {
		client_info = {
			function(req, msg)
				local result = send_command("status 3", 0)
				conn:reply(req, { response = result })
			end,
			{}
		},
		disconnect_client = {
			function(req, msg)
				local result = send_command("client-kill", msg.arg)
				conn:reply(req, { response = result })
			end,
			{arg = ubus.STRING}
		}
	}
}
conn:add(objects)
uloop.run()

uloop.close()


