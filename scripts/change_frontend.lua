local OnFocusMove_Old = FrontEnd.OnFocusMove
FrontEnd.OnFocusMove = function (self, dir, down, ...)
	if TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then return true end
	return OnFocusMove_Old(self, dir, down, ...)
end