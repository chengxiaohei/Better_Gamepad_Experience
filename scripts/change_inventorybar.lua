
AddClassPostConstruct("widgets/inventorybar", function(self)
	local CursorLeft_Old = self.CursorLeft
	self.CursorLeft = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end
		return CursorLeft_Old(self, ...)
	end

	local CursorRight_Old = self.CursorRight
	self.CursorRight = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end
		return CursorRight_Old(self, ...)
	end

	local CursorUp_Old = self.CursorUp
	self.CursorUp = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end
		return CursorUp_Old(self, ...)
	end

	local CursorDown_Old = self.CursorDown
	self.CursorDown = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end
		return CursorDown_Old(self, ...)
	end
end)


-- Prevent Cursor move while adjust camera
-- AddClassPostConstruct("widgets/inventorybar", function(self)
-- 	local CursorLeft_Old = self.CursorLeft
-- 	self.CursorLeft = function (self, ...)
-- 		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
-- 			-- (self.open and TheInput:IsControlPressed(CONTROL_MOVE_LEFT)) then
-- 			return true
-- 		end
-- 		return CursorLeft_Old(self, ...)
-- 	end

-- 	local CursorRight_Old = self.CursorRight
-- 	self.CursorRight = function (self, ...)
-- 		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
-- 			-- (self.open and TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)) then
-- 			return true
-- 		end
-- 		return CursorRight_Old(self, ...)
-- 	end

-- 	local CursorUp_Old = self.CursorUp
-- 	self.CursorUp = function (self, ...)
-- 		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
-- 			-- (self.open and TheInput:IsControlPressed(CONTROL_MOVE_UP)) then
-- 			return true
-- 		end
-- 		return CursorUp_Old(self, ...)
-- 	end

-- 	local CursorDown_Old = self.CursorDown
-- 	self.CursorDown = function (self, ...)
-- 		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
-- 			-- (self.open and TheInput:IsControlPressed(CONTROL_MOVE_DOWN)) then
-- 			return true
-- 		end
-- 		return CursorDown_Old(self, ...)
-- 	end
-- end)