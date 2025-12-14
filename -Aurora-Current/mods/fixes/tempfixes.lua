UNLOCKAURORA()

AU:NewDefaults('tempfixes', {
    enabled = {value = true},
    version = {value = '1.0'},
    gui = {
        {tab = 'tempfixes', subtab = 'mainbar', categories = 'General'},
    },

})

AU:NewModule('tempfixes', 1, 'PLAYER_ENTERING_WORLD', function()
    local tooltip = {}

    function tooltip:HookActionBars()
        local setup = AU.setups.actionbars
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
        local setup = AU.setups.unitframes
        if not setup or not setup.portraits then return end

        for _, unitFrame in setup.portraits do
            unitFrame:SetScript('OnEnter', function()
                if UnitExists(this.unit) then
                    GameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
                    GameTooltip:ClearAllPoints()
                    GameTooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -5, 5)
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
        local setup = AU.setups.micromenu
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
        local setup = AU.setups.buffs
        if not setup then return end

        local buffFrame = _G['AU_BuffFrame']
        local debuffFrame = _G['AU_DebuffFrame']

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
        local bagbar = AU.setups.bagbar
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

        local bags = AU.setups.bags
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
        local gameTimeButton = _G['AU_GameTimeButton']
        local zoomIn = _G['AU_MinimapZoomIn']
        local zoomOut = _G['AU_MinimapZoomOut']

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

    function tooltip:Init()
        self:HookActionBars()
        self:HookUnitFrames()
        self:HookBags()
        self:HookMicroMenu()
        self:HookBuffs()
        self:HookMinimap()
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


    local questTracker = CreateFrame('Frame', 'AU_QuestTracker', UIParent)
    questTracker:SetPoint('RIGHT', UIParent, 'RIGHT', -140, 200)
    questTracker:SetWidth(170)
    questTracker:SetHeight(10)
    questTracker:SetScale(.8)
    QuestWatchFrame:SetParent(questTracker)
    QuestWatchFrame:SetAllPoints(questTracker)
    QuestWatchFrame:SetFrameLevel(1)

    DurabilityFrame:ClearAllPoints()
    DurabilityFrame:SetPoint('RIGHT', UIParent, 'RIGHT', -15, 200)
    DurabilityFrame:SetScale(0.7)

    -- callbacks
    local callbacks = {}

    AU:NewCallbacks('tempfixes', callbacks)
end)
