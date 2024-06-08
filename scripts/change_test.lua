

AddClassPostConstruct("screens/playerhud", function(self)

	local OpenContainer_Old = self.OpenContainer
	self.OpenContainer = function(self, container, side,...)
        -- print("******OpenContainer")
        OpenContainer_Old(self, container, side, ...)
	end

	local CloseContainer_Old = self.CloseContainer
	self.CloseContainer = function(self, container, side,...)
        -- print("******CloseContainer")
        CloseContainer_Old(self, container, side, ...)
	end
end)

AddClassPostConstruct("widgets/controls", function(self)

    local OnUpdate_Old = self.OnUpdate
    self.OnUpdate = function (self, dt, ...)

        OnUpdate_Old(self, dt, ...)
        
    end
end)