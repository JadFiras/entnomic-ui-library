--[[

	Entnomic UI Library
	-------------------
	A clean, modern, dark UI library for Roblox scripts.

	Loader entry point.

	Usage:
		local Entnomic = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/entnomic/main/loader.lua"))()

	This file resolves the modular source tree over HttpGet using a lightweight
	dependency-injection importer. Every module returns a single function that
	accepts the `import` function and returns its exported value.

	After you upload this repository to GitHub, set BASE_URL below to your raw
	repository path (the folder that contains the `src/` directory).

]]

local BASE_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/entnomic/main/src/"

return (function()
	local cache = {}

	local function import(path)
		if cache[path] ~= nil then
			return cache[path]
		end

		local url = BASE_URL .. path .. ".lua"

		local source
		local ok, err = pcall(function()
			source = game:HttpGet(url, true)
		end)
		assert(ok, "[Entnomic] Failed to fetch module '" .. path .. "'\n" .. tostring(err))

		local chunk, compileErr = loadstring(source, "=entnomic/" .. path)
		assert(chunk, "[Entnomic] Failed to compile module '" .. path .. "'\n" .. tostring(compileErr))

		local factory = chunk()
		assert(
			type(factory) == "function",
			"[Entnomic] Module '" .. path .. "' must return a function(import)"
		)

		local result = factory(import)
		cache[path] = result
		return result
	end

	return import("Entnomic")
end)()
