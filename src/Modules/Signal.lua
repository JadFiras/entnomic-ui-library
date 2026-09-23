--[[
	Modules/Signal
	A tiny, dependency-free event implementation.
]]

return function(import)
	local Signal = {}
	Signal.__index = Signal

	function Signal.new()
		return setmetatable({ _handlers = {} }, Signal)
	end

	function Signal:Connect(fn)
		table.insert(self._handlers, fn)
		return {
			Disconnect = function()
				for i = #self._handlers, 1, -1 do
					if self._handlers[i] == fn then
						table.remove(self._handlers, i)
					end
				end
			end,
		}
	end

	function Signal:Fire(...)
		for _, fn in ipairs(self._handlers) do
			task.spawn(fn, ...)
		end
	end

	function Signal:DisconnectAll()
		self._handlers = {}
	end

	return Signal
end
