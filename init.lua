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

	if config.translateRootPath ~= nil then
		if config.translateRootPath.from == nil or config.translateRootPath.to == nil then
			log("ERROR: config.translateRootPath requires both 'from' and 'to' fields in present")
			return false
		end
	end

	return true
end

local function buildFilePath(filePath, config)
	if config.translateRootPath == nil then
		return filePath
	else
		return filePath:gsub("^" .. config.translateRootPath.from, config.translateRootPath.to)
	end
end

function obj.bind(config)
	log("Binding URL event" .. hs.inspect.inspect(config))

	if not validateConfig(config) then
		return
	end

	local eventName = config.eventName or "openInNeovim"

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
			local filePath = buildFilePath(params.file, config)
			local lineNumber = params.line

			hs.task
				.new(config.nvimPath, nil, {
					"--server",
					config.nvimServerPipePath,
					"--remote-send",
					"<ESC><ESC><ESC><ESC>:e " .. "+" .. lineNumber .. " " .. filePath .. "<CR>",
				})
				:start()

			hs.notify
				.new({
					title = "Opened in Neovim",
					informativeText = filePath .. ":" .. lineNumber,
				})
				:send()

			if config.foregroundApp then
				local app = hs.application.find(config.foregroundApp)
				app:setFrontmost(true)
			end
		end
	end)
end

return obj
