-- ===== Open in Neovim =====

local obj = {}

obj.__index = obj

obj.name = "OpenInNeovim"
obj.version = "1.0"
obj.author = "June Kelly"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function log(logString)
	print("[OpenInNeovim] " .. logString)
end

local function validateConfig(config)
	if config.nvimPath == nil then
		log("ERROR: config.nvimPath is required")
		return false
	end
	if config.nvimServerPipePath == nil then
		log("ERROR: config.nvimServerPipePath is required")
		return false
	end

	return true
end

function obj.bind(config)
	if not validateConfig(config) then
		return
	end

	local eventName = config.eventName or "openInNeovim"

	log("Binding to URL event '" .. eventName .. "'")

	hs.urlevent.bind(eventName, function(_eventName, params)
		if config.token and (params.token ~= config.token) then
			local params_json = hs.json.encode(params)

			log("Invalid Token! " .. params_json)

			hs.notify
				.new({
					title = "Open in Neovim: Invalid Token!",
					informativeText = params_json,
				})
				:send()

			return
		else
			local filePath = params.file
			local lineNumber = params.line

			hs.task
				.new(config.nvimPath, nil, {
					"--server",
					config.nvimServerPipePath,
					"--remote-send",
					"<ESC><ESC><ESC><ESC>:e " .. filePath .. "<CR>" .. lineNumber .. "G",
				})
				:start()

			hs.notify
				.new({
					title = "Opened in Neovim",
					informativeText = filePath .. ":" .. lineNumber,
				})
				:send()

			if config.focusTerminalApp then
				local app = hs.application.find(config.focusTerminalApp)
				app:setFrontmost(true)
			end
		end
	end)
end

return obj
