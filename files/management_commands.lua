#!/usr/bin/lua

local socket = require("socket")

local client, success, err

local function split(str, separator)
    assert(separator ~= "", "Separator cannot be empty")

    local result = {}
    local start = 1

    while true do
        local first, last = string.find(str, separator, start, true)

        if not first then
            table.insert(result, string.sub(str, start))
            break
        end

        table.insert(result, string.sub(str, start, first - 1))
        start = last + 1
    end

    return result
end

local function parseOpenVPN(response)
    local result = {
        clients = {}
    }

    local headers = {}

    -- Process one line at a time
    for _, line in ipairs(split(response, "\n")) do
        line = line:gsub("\r$", "")

        -- Split columns by tabs
        local fields = split(line, "\t")

        -- First field indicates the record type
        local recordType = fields[1]

        if recordType == "HEADER" and fields[2] == "CLIENT_LIST" then
            local section = fields[2]

            headers[section] = {}

            -- Skip "HEADER" and the section name
            for i = 3, #fields do
                table.insert(headers[section], fields[i])
            end

        elseif recordType == "CLIENT_LIST" then

            local names = headers[recordType]

            if names then
                local entry = {}

                -- Map each column to its header
                for i, name in ipairs(names) do
                    entry[name] = fields[i + 1] or ""
                end

                table.insert(result.clients, entry)
            end
        end
    end

    return result
end


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

function receive_status()
	
end

function send_command(command, arg)
    local conn = connect()
    if conn ~= 1 then
        return "ERR_CONN"
    end

    local is_status
    local message

    if arg ~= "-1" then
        message = command .. " " .. tostring(arg) .. " HALT\n"
    else
        message = command .. "\n"
	is_status = true
    end

    local success, err = client:send(message)

    if not success then
        log("err", tostring(err))
        client:close()
        return "ERR_SEND"
    end

    local lines = {}

    while true do
        local line, err = client:receive("*l")

        if not line then
            log("err", "Receive failed: " .. tostring(err))
            client:close()
            return "ERR_RECV"
        end

        -- Ignore asynchronous management messages
        if line:sub(1, 1) == ">" then

        elseif is_status and line == "END" then
            break

        elseif not is_status and (
            line:match("^SUCCESS:") or
            line:match("^ERROR:")
        ) then
            table.insert(lines, line)
            break

        else
            table.insert(lines, line)
        end
    end

    client:close()

    local response = table.concat(lines, "\n")

    if is_status then
        return parseOpenVPN(response)
    end

    return response
end



























