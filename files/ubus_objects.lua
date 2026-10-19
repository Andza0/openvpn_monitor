require "ubus"
require "uloop"
uloop.init()

name = assert(arg[1], "Missing server name")
management = assert(arg[2], "Missing management interface")

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

require("management_commands.send_command")	


local objects = {
	[name] = {
		client_info = {
			function(req, msg)
				conn:reply(req, { response = send_command(msg.command, 0) })
			end,
			{ command = ubus.STRING }
		},
		disconnect_client = {
			function(req, msg)
				conn:reply(req, { response = send_command(msg.command, msg.arg) })
			end,
			{ 	command = ubus.STRING,
				arg = ubus.STRING
			}
		}
	}
}

conn:add(objects)

uloop.run()



