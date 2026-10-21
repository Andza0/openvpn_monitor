#!/usr/bin/lua

local socket = require("socket")

local client, success, err

function connect()
	local ip, port = string.match(management, "^(%S+)%s+(%S+)$")
	port = tonumber(port)
	if not ip or not port then
		log("err", "IP or Port is invalid!")
		return 0
	end

	client, err = socket.tcp()
	if not client then
		log("err", "socket create err:" .. err)
		return 0
	end
	
	success, err = client:connect(ip, port)
	if not success then
		log("err", "conn err: " .. err)
		client:close()
		return 0
	end
	return 1
end

function send_command(command, arg)
	local conn = connect()
	if conn ~= 1 then
		return "ERR_CONN"
	end

	if arg ~= 0 then
		success, err = client:send(command .. " " .. arg .. "\n")
	else
		success, err = client:send(command .. "\n")
	end
	if not success then
		log("err", err)
		client:close()
		return "ERR_SEND"
	end

	local lines = {}
	while true do
		local line, err = client:receive("*l")

		if not line then
			log("err", "Receive failed:" .. err)
			client:close()
			return "ERR_RECV"
		end

		if line == "END" then 
			break
		end

		table.insert(lines, line)

	end

	local message = table.concat(lines, "\n")
	client:close()
	return message
end
	


