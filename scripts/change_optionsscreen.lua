AddClassPostConstruct("screens/redux/optionsscreen", function(self)
    local UpdateMenu_Old = self.UpdateMenu
    self.UpdateMenu = function (self, ...)
        self.integratedbackpackSpinner:Enable()
        self.integratedbackpackSpinner:SetSelectedIndex(self.integratedbackpackSpinner.selectedIndex)
        UpdateMenu_Old(self, ...)
    end

	local GetHelpText_Old = self.GetHelpText
	self.GetHelpText = function (self, ...)
		GetHelpText_Old(self, ...)
		self:UpdateMenu()
	end
end)