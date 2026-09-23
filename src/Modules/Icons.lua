--[[
	Modules/Icons
	Lucide icon support (https://lucide.dev/icons).

	Accepts three input forms anywhere an `Icon` field is used:
		- a number            -> treated as a Roblox asset id
		- "rbxassetid://123"  -> used directly
		- "lucide-name"       -> resolved through the Lucide spritesheet provider

	Lucide icons ship as spritesheets, so a resolved icon returns:
		{ Image = "rbxassetid://...", ImageRectOffset = Vector2, ImageRectSize = Vector2 }

	The provider is loaded lazily over HttpGet from the community Lucide port
	(the same source WindUI uses). If it is unavailable, icons degrade gracefully
	to an empty image instead of erroring. You can also inject your own provider
	via Icons.SetProvider(fn) where fn(name) -> { Image, ImageRectOffset, ImageRectSize }.
]]

return function(import)
	local Icons = {}

	-- Community Lucide spritesheet providers, tried in order.
	local PROVIDER_SOURCES = {
		"https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua",
	}

	local provider
	local providerTried = false
	local customProvider

	local EMPTY = {
		Image = "",
		ImageRectOffset = Vector2.zero,
		ImageRectSize = Vector2.zero,
	}

	local function ensureProvider()
		if providerTried then
			return
		end
		providerTried = true

		for _, url in ipairs(PROVIDER_SOURCES) do
			local ok, result = pcall(function()
				return loadstring(game:HttpGet(url, true))()
			end)
			if ok and result then
				provider = result
				break
			end
		end
	end

	-- Normalize whatever shape the community module returns into our contract.
	local function normalize(data)
		if type(data) ~= "table" then
			return nil
		end

		-- Footagesus/Icons style: { Url/Image, ImageRectPosition/Offset, ImageRectSize }
		local image = data.Image or data.Url or data.url
		local offset = data.ImageRectOffset or data.ImageRectPosition or data.Position
		local size = data.ImageRectSize or data.Size

		if image then
			return {
				Image = tostring(image),
				ImageRectOffset = offset or Vector2.zero,
				ImageRectSize = size or Vector2.zero,
			}
		end

		return nil
	end

	local resolveCache = {}

	function Icons.SetProvider(fn)
		customProvider = fn
	end

	-- Resolve any accepted icon input into image render properties.
	function Icons.Resolve(icon)
		if icon == nil then
			return EMPTY
		end

		if type(icon) == "number" then
			return {
				Image = "rbxassetid://" .. icon,
				ImageRectOffset = Vector2.zero,
				ImageRectSize = Vector2.zero,
			}
		end

		if type(icon) == "string" then
			if icon:match("^rbxassetid://") or icon:match("^rbxasset://") or icon:match("^http") then
				return {
					Image = icon,
					ImageRectOffset = Vector2.zero,
					ImageRectSize = Vector2.zero,
				}
			end

			if resolveCache[icon] then
				return resolveCache[icon]
			end

			-- Custom provider takes priority.
			if customProvider then
				local ok, data = pcall(customProvider, icon)
				if ok then
					local n = normalize(data) or (type(data) == "table" and data.Image and data)
					if n then
						resolveCache[icon] = n
						return n
					end
				end
			end

			ensureProvider()
			if provider then
				local getters = {
					function() return provider.GetAsset and provider.GetAsset(icon) end,
					function() return provider.SetIcon and provider.SetIcon(icon) end,
					function() return provider.Icons and provider.Icons[icon] end,
					function() return provider[icon] end,
				}
				for _, get in ipairs(getters) do
					local ok, data = pcall(get)
					if ok and data then
						local n = normalize(data)
						if n then
							resolveCache[icon] = n
							return n
						end
					end
				end
			end
		end

		return EMPTY
	end

	-- Convenience: does this icon input resolve to something drawable?
	function Icons.Exists(icon)
		local r = Icons.Resolve(icon)
		return r.Image ~= ""
	end

	return Icons
end
