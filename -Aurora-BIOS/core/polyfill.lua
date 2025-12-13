_G = getfenv(0)

local frameMT = getmetatable(CreateFrame'Frame')
local oldIndex = frameMT.__index
frameMT.__index = function(t, k)
    if k == 'SetSize' then
        return function(self, width, height)
            self:SetWidth(width)
            self:SetHeight(height)
        end
    elseif k == 'GetSize' then
        return function(self)
            return self:GetWidth(), self:GetHeight()
        end
    end
    return oldIndex(t, k)
end
