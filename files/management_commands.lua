require("socket")

local client, success, err

function connect()
	local ip, port = string.match(management, "^(%S+)%s+(%S+)$")
	port = tonumber(port)

	if not ip or not port then
		print("IP or Port is invalid!")
		return 0
	end
	client, err = socket.tcp()
	if not client then
		print(err)
		return 0
	end
	
	client:settimeout(5)
	success, err = client:connect(ip, port)
	if not success then
		print(err)
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
		print(err)
		client:close()
		return "ERR_SEND"
	end
	local message, err = client:receive("*a")
	if not message then
		print(err)
		client:close()
		return "ERR_RECV"
	end
	client:close()
	return message
end
	


