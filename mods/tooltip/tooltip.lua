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
    local tooltip = {}

    function tooltip:HookActionBars()
        local setup = DF.setups.actionbars
        if not setup or not setup.bars then return end

        for barName, bar in setup.bars do
            for i = 1, table.getn(bar.buttons) do
                local btn = bar.buttons[i]
                local origOnEnter = btn:GetScript('OnEnter')
                local origOnLeave = btn:GetScript('OnLeave')

                btn:SetScript('OnEnter', function()
                    if origOnEnter then origOnEnter() end

                    local id = this:GetID()
                    if id >= 200 and id <= 209 then
                        GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
                        GameTooltip:SetShapeshift(id - 199)
                    elseif id >= 133 and id <= 142 then
                        GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
                        GameTooltip:SetPetAction(id - 132)
                    elseif HasAction(id) then
                        GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
                        GameTooltip:SetAction(id)
                    end
                end)
                btn:SetScript('OnLeave', function()
                    if origOnLeave then origOnLeave() end
                    GameTooltip:Hide()
                end)
            end
        end
    end

    function tooltip:HookUnitFrames()
        local setup = DF.setups.unitframes
        if not setup or not setup.portraits then return end

        for _, unitFrame in setup.portraits do
            unitFrame:SetScript('OnEnter', function()
                if UnitExists(this.unit) then
                    GameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
                    GameTooltip:ClearAllPoints()
                    GameTooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -25, 35)
                    GameTooltip:SetUnit(this.unit)
                    GameTooltip:Show()
                end
            end)
            unitFrame:SetScript('OnLeave', function()
                GameTooltip:Hide()
            end)

            for i = 1, 16 do
                local buff = unitFrame.buffs[i]
                local capturedUnit = unitFrame.unit
                local capturedIndex = i
                buff:SetScript('OnEnter', function()
                    if UnitBuff(capturedUnit, capturedIndex) then
                        GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
                        GameTooltip:SetUnitBuff(capturedUnit, capturedIndex)
                        GameTooltip:Show()
                    end
                end)
                buff:SetScript('OnLeave', function()
                    GameTooltip:Hide()
                end)

                local debuff = unitFrame.debuffs[i]
                debuff:SetScript('OnEnter', function()
                    if UnitDebuff(capturedUnit, capturedIndex) then
                        GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
                        GameTooltip:SetUnitDebuff(capturedUnit, capturedIndex)
                        GameTooltip:Show()
                    end
                end)
                debuff:SetScript('OnLeave', function()
                    GameTooltip:Hide()
                end)
            end
        end
    end

    function tooltip:HookMicroMenu()
        local setup = DF.setups.micromenu
        if not setup or not setup.buttons then return end

        for i = 1, table.getn(setup.buttons) do
            local btn = setup.buttons[i]
            local origEnter = btn:GetScript('OnEnter')
            local btnData = btn.data
            btn:SetScript('OnEnter', function()
                if origEnter then origEnter() end
                GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
                GameTooltip:SetText(btnData.name)
                GameTooltip:Show()
            end)
            local origLeave = btn:GetScript('OnLeave')
            btn:SetScript('OnLeave', function()
                if origLeave then origLeave() end
                GameTooltip:Hide()
            end)
        end
    end

    function tooltip:HookBuffs()
        local setup = DF.setups.buffs
        if not setup then return end

        local buffFrame = _G['DF_BuffFrame']
        local debuffFrame = _G['DF_DebuffFrame']

        if buffFrame and buffFrame.buttons then
            for i = 1, table.getn(buffFrame.buttons) do
                local btn = buffFrame.buttons[i]
                local origEnter = btn:GetScript('OnEnter')
                btn:SetScript('OnEnter', function()
                    if origEnter then origEnter() end
                    if this.buffIndex and this.buffIndex >= 0 then
                        GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
                        GameTooltip:SetPlayerBuff(this:GetID())
                        GameTooltip:Show()
                    end
                end)
            end
        end

        if debuffFrame and debuffFrame.buttons then
            for i = 1, table.getn(debuffFrame.buttons) do
                local btn = debuffFrame.buttons[i]
                local origEnter = btn:GetScript('OnEnter')
                btn:SetScript('OnEnter', function()
                    if origEnter then origEnter() end
                    if this.buffIndex and this.buffIndex >= 0 then
                        GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
                        GameTooltip:SetPlayerBuff(this:GetID())
                        GameTooltip:Show()
                    end
                end)
            end
        end
    end

    function tooltip:HookBags()
        local bagbar = DF.setups.bagbar
        if not bagbar or not bagbar.mainBag then return end

        local hookBagButton = function(btn, tooltipFunc)
            local origEnter = btn:GetScript('OnEnter')
            local origLeave = btn:GetScript('OnLeave')
            btn:SetScript('OnEnter', function()
                if origEnter then origEnter() end
                tooltipFunc()
            end)
            btn:SetScript('OnLeave', function()
                if origLeave then origLeave() end
                GameTooltip:Hide()
            end)
        end

        hookBagButton(bagbar.mainBag, function()
            GameTooltip:SetOwner(bagbar.mainBag, 'ANCHOR_RIGHT')
            GameTooltip:SetText('Backpack')
            GameTooltip:Show()
        end)

        for i = 0, 3 do
            hookBagButton(bagbar.smallBags[i], function()
                GameTooltip:SetOwner(bagbar.smallBags[i], 'ANCHOR_RIGHT')
                GameTooltip:SetInventoryItem('player', ContainerIDToInventoryID(bagbar.smallBags[i]:GetID() + 1))
                GameTooltip:Show()
            end)
        end

        hookBagButton(bagbar.keyRing, function()
            GameTooltip:SetOwner(bagbar.keyRing, 'ANCHOR_RIGHT')
            GameTooltip:SetText('Key Ring')
            GameTooltip:Show()
        end)

        local bags = DF.setups.bags
        if bags then
            for bagID = 0, 4 do
                local bag = bags[bagID]
                if bag and bag.slots then
                    for _, button in bag.slots do
                        local capturedBtn = button
                        hookBagButton(capturedBtn, function()
                            if capturedBtn and capturedBtn.bagID and capturedBtn.slotID then
                                GameTooltip:SetOwner(capturedBtn, 'ANCHOR_RIGHT')
                                GameTooltip:SetBagItem(capturedBtn.bagID, capturedBtn.slotID)
                                GameTooltip:Show()
                            end
                        end)
                    end
                end
            end
            if bags.unified and bags.unified.slots then
                for _, button in bags.unified.slots do
                    local capturedBtn = button
                    hookBagButton(capturedBtn, function()
                        if capturedBtn and capturedBtn.bagID and capturedBtn.slotID then
                            GameTooltip:SetOwner(capturedBtn, 'ANCHOR_RIGHT')
                            GameTooltip:SetBagItem(capturedBtn.bagID, capturedBtn.slotID)
                            GameTooltip:Show()
                        end
                    end)
                end
            end
        end
    end

    function tooltip:HookMinimap()
        local gameTimeButton = _G['DF_GameTimeButton']
        local zoomIn = _G['DF_MinimapZoomIn']
        local zoomOut = _G['DF_MinimapZoomOut']

        if gameTimeButton then
            local origEnter = gameTimeButton:GetScript('OnEnter')
            gameTimeButton:SetScript('OnEnter', function()
                if origEnter then origEnter() end
                local hour, minute = GetGameTime()
                GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
                GameTooltip:SetText(string.format('Game Time: %02d:%02d', hour, minute))
                GameTooltip:Show()
            end)
            local origLeave = gameTimeButton:GetScript('OnLeave')
            gameTimeButton:SetScript('OnLeave', function()
                if origLeave then origLeave() end
                GameTooltip:Hide()
            end)
        end

        if zoomIn then
            local origEnter = zoomIn:GetScript('OnEnter')
            zoomIn:SetScript('OnEnter', function()
                if origEnter then origEnter() end
                GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
                GameTooltip:SetText('Zoom In')
                GameTooltip:Show()
            end)
            local origLeave = zoomIn:GetScript('OnLeave')
            zoomIn:SetScript('OnLeave', function()
                if origLeave then origLeave() end
                GameTooltip:Hide()
            end)
        end

        if zoomOut then
            local origEnter = zoomOut:GetScript('OnEnter')
            zoomOut:SetScript('OnEnter', function()
                if origEnter then origEnter() end
                GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
                GameTooltip:SetText('Zoom Out')
                GameTooltip:Show()
            end)
            local origLeave = zoomOut:GetScript('OnLeave')
            zoomOut:SetScript('OnLeave', function()
                if origLeave then origLeave() end
                GameTooltip:Hide()
            end)
        end
    end

    tooltip:HookActionBars()
    tooltip:HookUnitFrames()
    tooltip:HookMicroMenu()
    tooltip:HookBuffs()
    tooltip:HookMinimap()

    local bagHookFrame = CreateFrame'Frame'
    bagHookFrame.elapsed = 0
    bagHookFrame:SetScript('OnUpdate', function()
        this.elapsed = this.elapsed + arg1
        if this.elapsed > 0.6 then
            tooltip:HookBags()
            this:SetScript('OnUpdate', nil)
        end
    end)

    local origSetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor
    local origUnitFrameOnLeave = _G.UnitFrame_OnLeave

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
            _G.UnitFrame_OnLeave = function()
                if SpellIsTargeting() then
                    SetCursor('CAST_ERROR_CURSOR')
                end
                this.updateTooltip = nil
                GameTooltip:Hide()
            end
        else
            cursorFrame:SetScript('OnUpdate', nil)
            _G.GameTooltip_SetDefaultAnchor = origSetDefaultAnchor
            _G.UnitFrame_OnLeave = origUnitFrameOnLeave
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
