--[[
	Modules/Config
	Flag-based configuration persistence.

	Elements register themselves with a `Flag` and expose Get()/Set(). The manager
	serializes flag values to JSON and writes them with the executor's file API
	(writefile/readfile/isfile), degrading to no-op when those are unavailable.
]]

return function(import)
	local HttpService = game:GetService("HttpService")

	local Config = {}
	Config.__index = Config

	local hasFileApi = (typeof(writefile) == "function")
		and (typeof(readfile) == "function")
		and (typeof(isfile) == "function")

	function Config.new(opts)
		opts = opts or {}
		local self = setmetatable({}, Config)
		self.Enabled = opts.Enabled ~= false
		self.Folder = opts.Folder or "Entnomic"
		self.FileName = opts.FileName or "default"
		self.Flags = {}            -- flag -> { Get = fn, Set = fn }
		return self
	end

	function Config:_path()
		return self.Folder .. "/" .. self.FileName .. ".json"
	end

	-- Register an element so its value participates in save/load.
	function Config:Register(flag, api)
		if flag == nil then
			return
		end
		self.Flags[flag] = api
	end

	function Config:Save()
		if not (self.Enabled and hasFileApi) then
			return false, "file api unavailable"
		end

		local data = {}
		for flag, api in pairs(self.Flags) do
			local ok, value = pcall(api.Get)
			if ok then
				data[flag] = self:_encode(value)
			end
		end

		local ok, err = pcall(function()
			if not isfolder(self.Folder) then
				makefolder(self.Folder)
			end
			writefile(self:_path(), HttpService:JSONEncode(data))
		end)
		return ok, err
	end

	function Config:Load()
		if not (self.Enabled and hasFileApi) then
			return false, "file api unavailable"
		end
		if not isfile(self:_path()) then
			return false, "no config file"
		end

		local ok, raw = pcall(readfile, self:_path())
		if not ok then
			return false, raw
		end

		local decoded
		ok, decoded = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not ok then
			return false, decoded
		end

		for flag, stored in pairs(decoded) do
			local api = self.Flags[flag]
			if api and api.Set then
				pcall(api.Set, self:_decode(stored))
			end
		end
		return true
	end

	-- Color3 / Vector2 / Enum values need light serialization.
	function Config:_encode(value)
		if typeof(value) == "Color3" then
			return { __t = "Color3", r = value.R, g = value.G, b = value.B }
		elseif typeof(value) == "EnumItem" then
			return { __t = "Enum", full = tostring(value) }
		end
		return value
	end

	function Config:_decode(value)
		if type(value) == "table" and value.__t then
			if value.__t == "Color3" then
				return Color3.new(value.r, value.g, value.b)
			elseif value.__t == "Enum" then
				-- tostring form is "Enum.KeyCode.E"
				local parts = string.split(value.full, ".")
				if #parts == 3 and Enum[parts[2]] then
					return Enum[parts[2]][parts[3]]
				end
			end
		end
		return value
	end

	return Config
end
