UNLOCKDRAGONFLIGHT()

DF:NewDefaults('tooltip', {
    enabled = {value = true},
    version = {value = '1.0'},
    gui = {
        {tab = 'tooltip', 'General'},
    },
    tooltipMouseAnchor = {value = false, metadata = {element = 'checkbox', category = 'General', indexInCategory = 1, description = 'Anchor tooltip to mouse cursor'}},
    tooltipOffsetX = {value = 35, metadata = {element = 'slider', category = 'General', indexInCategory = 2, description = 'Tooltip X offset', min = -100, max = 100, stepSize = 1, dependency = {key = 'tooltipMouseAnchor', state = true}}},
    tooltipOffsetY = {value = 10, metadata = {element = 'slider', category = 'General', indexInCategory = 3, description = 'Tooltip Y offset', min = -100, max = 100, stepSize = 1, dependency = {key = 'tooltipMouseAnchor', state = true}}},
    tooltipHideHealthBar = {value = false, metadata = {element = 'checkbox', category = 'General', indexInCategory = 4, description = 'Hide tooltip healthbar'}},
    tooltipHealthText = {value = false, metadata = {element = 'checkbox', category = 'General', indexInCategory = 5, description = 'Show HP text on healthbar', dependency = {key = 'tooltipHideHealthBar', stateNot = true}}},

})

DF:NewModule('tooltip', 1, 'PLAYER_ENTERING_WORLD', function()
    local origSetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor

    GameTooltip:SetScript('OnShow', function()
        if GameTooltip:GetAnchorType() ~= 'ANCHOR_NONE' then return end
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -25, 35)
    end)

    local cursorFrame = CreateFrame('Frame', nil, UIParent)
    cursorFrame:SetSize(1, 1)

    local callbacks = {}
    local callbackHelper = {definesomethinginheredirectly}
    local offsetX, offsetY

    callbacks.tooltipMouseAnchor = function(value)
        if value then
            cursorFrame:SetScript('OnUpdate', function()
                local scale = UIParent:GetScale()
                local x, y = GetCursorPosition()
                this:ClearAllPoints()
                this:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', x/scale, y/scale)
            end)
            _G.GameTooltip_SetDefaultAnchor = function(frame, parent)
                frame:SetOwner(parent, 'ANCHOR_CURSOR')
                frame:SetPoint('BOTTOMLEFT', cursorFrame, 'CENTER', offsetX or 0, offsetY or 0)
            end
        else
            cursorFrame:SetScript('OnUpdate', nil)
            _G.GameTooltip_SetDefaultAnchor = origSetDefaultAnchor
        end
    end

    callbacks.tooltipOffsetX = function(value)
        offsetX = value
    end

    callbacks.tooltipOffsetY = function(value)
        offsetY = value
    end

    callbacks.tooltipHideHealthBar = function(value)
        if value then
            GameTooltipStatusBar:Hide()
            GameTooltipStatusBar:SetScript('OnShow', function() this:Hide() end)
        else
            GameTooltipStatusBar:SetScript('OnShow', nil)
        end
    end

    callbacks.tooltipHealthText = function(value)
        if value then
            if not GameTooltipStatusBar.text then
                GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, 'OVERLAY')
                GameTooltipStatusBar.text:SetFont('Fonts\\FRIZQT__.TTF', 12, 'OUTLINE')
                GameTooltipStatusBar.text:SetPoint('CENTER', GameTooltipStatusBar, 'CENTER', 0, 0)
            end
            GameTooltipStatusBar:SetScript('OnValueChanged', function()
                HealthBar_OnValueChanged(arg1)
                local min, max = this:GetMinMaxValues()
                local cur = this:GetValue()
                if cur > 0 then
                    this.text:SetText(cur..'/'..max)
                else
                    this.text:SetText('')
                end
            end)
        else
            if GameTooltipStatusBar.text then
                GameTooltipStatusBar.text:SetText('')
            end
            GameTooltipStatusBar:SetScript('OnValueChanged', function()
                HealthBar_OnValueChanged(arg1)
            end)
        end
    end

    DF:NewCallbacks('tooltip', callbacks)
end)
