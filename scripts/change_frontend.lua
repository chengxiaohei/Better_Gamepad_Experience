
local FrontEnd_OnFocusMove_End = FrontEnd.OnFocusMove

FrontEnd.OnFocusMove = function(self, dir, down, ...)
    if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
        return true
    end
    return FrontEnd_OnFocusMove_End(self, dir, down, ...)
end
