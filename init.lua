-- ===== Open in Nvim =====

local obj = {}

obj.__index = obj

obj.name = "OpenInNeovim"
obj.version = "1.0"
obj.author = "June Kelly"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj.bind(config)
	local eventName = config.eventName or "openInNeovim"

	print("[OpenInNeovim] Binding to event '" .. eventName .. "'.")

	hs.urlevent.bind(eventName, function(_eventName, params)
		if config.token and (params["token"] ~= config.token) then
			local params_json = hs.json.encode(params)

			print("Open in Nvim: INVALID TOKEN!!!", params_json)

			hs.notify
				.new({
					title = "Open in Nvim: INVALID TOKEN!!!",
					informativeText = params_json,
				})
				:send()

			return
		else
			local filePath = params["file"]
			local lineNumber = params["line"]

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
					title = "Opened in Nvim",
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
