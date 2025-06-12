
local FrontEnd_OnFocusMove_End = FrontEnd.OnFocusMove

FrontEnd.OnFocusMove = function(self, dir, down, ...)
    if TheInput:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV) == 1 and TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
        return true
    end
    if ((IsOtherModEnabled("Gesture Wheel") and GetOtherModConfig("Gesture Wheel", "RIGHTSTICK")) or
        (IsOtherModEnabled("Gesture Wheel (Chinese)") and GetOtherModConfig("Gesture Wheel (Chinese)", "RIGHTSTICK"))) and
        TheInput:IsControlPressed(CONTROL_MENU_MISC_3) then
        return true
    end
    return FrontEnd_OnFocusMove_End(self, dir, down, ...)
end
