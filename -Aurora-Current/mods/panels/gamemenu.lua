---@diagnostic disable: duplicate-set-field
UNLOCKAURORA()

AU:NewDefaults('gamemenu', {
    version = {value = '1.0'},
    enabled = {value = true},
    gui = {
        {indexRange = {1, 1}, tab = 'gamemenu', subtab = 1},
    },

    gamemenuprint = {value = true, metadata = {element = 'checkbox', category = 'General', index = 1, description = 'gamemenu print description'}},

    -- we keep gamemenuprint as full metadata example, index/category must be given!
    -- gamemenuprint = {value = 50, metadata = {element = 'slider', category = 'General', index = 2, description = 'This is an example description with five to nine words', extraDesc = 'additional text', dependency = {key = 'enabled', state = true}, exclusiveGroup = 'groupName', isNew = false, min = 0, max = 100, stepSize = 1}},
})

AU:NewModule('gamemenu', 1, function()
    AU.common.KillFrame(GameMenuFrame)

    local frame = AU.ui.CreatePaperDollFrame('AU_GameMenuFrame', UIParent, 240, 500, 3)
    frame:SetPoint('CENTER', 0, 0)
    frame:Hide()
    frame:SetScale(.9)
    frame:EnableMouse(true)
    frame:SetFrameStrata('DIALOG')

    local yOffset = -60
    local buttonHeight = 22
    local buttonSpacing = 5
    local emptySpacing = 5

    local dfBtn = AU.ui.Button(frame, info.addonNameColor, 160, buttonHeight)
    dfBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    dfBtn:SetScript('OnClick', function()
        frame:Hide()
        AURORAToggleGUI()
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing * emptySpacing

    local editBtn = AU.ui.Button(frame, 'Edit Mode', 160, buttonHeight)
    editBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    editBtn:SetScript('OnClick', function()
        frame:Hide()
        local editFrame = getglobal('AU_EditModeFrame')
        if editFrame then
            editFrame:Show()
        end
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing

    local biosBtn = AU.ui.Button(frame, 'BIOS', 160, buttonHeight)
    biosBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    biosBtn:SetScript('OnClick', function()
        -- frame:Hide()
        -- ToggleBiosFrame()
    end)
    biosBtn:SetScript('OnClick', function()
        frame:Hide()
        local biosFrame = getglobal('AU_BIOSFrame')
        if biosFrame then
            biosFrame:Show()
        end
    end)

    yOffset = yOffset - buttonHeight - buttonSpacing

    local addonsBtn = AU.ui.Button(frame, 'Addons', 160, buttonHeight)
    addonsBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    addonsBtn:SetScript('OnClick', function()
        frame:Hide()
        local addonsFrame = getglobal('AU_AddonsFrame')
        if addonsFrame then
            addonsFrame:Show()
        end
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing * emptySpacing

    local soundBtn = AU.ui.Button(frame, 'Sound', 79, buttonHeight)
    soundBtn:SetPoint('TOP', frame, 'TOP', -40.5, yOffset)
    soundBtn:SetScript('OnClick', function()
        frame:Hide()
        ShowUIPanel(SoundOptionsFrame)
    end)

    local videoBtn = AU.ui.Button(frame, 'Video', 79, buttonHeight)
    videoBtn:SetPoint('LEFT', soundBtn, 'RIGHT', -2, 0)
    videoBtn:SetScript('OnClick', function()
        frame:Hide()
        ShowUIPanel(OptionsFrame)
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing

    local uiBtn = AU.ui.Button(frame, 'Interface', 160, buttonHeight)
    uiBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    uiBtn:SetScript('OnClick', function()
        frame:Hide()
        ShowUIPanel(UIOptionsFrame)
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing * emptySpacing

    local keybindsBtn = AU.ui.Button(frame, 'Keybinds', 140, buttonHeight)
    keybindsBtn:SetPoint('TOP', frame, 'TOP', - 10, yOffset)
    keybindsBtn:SetScript('OnClick', function()
        frame:Hide()
        KeyBindingFrame_LoadUI()
        ShowUIPanel(KeyBindingFrame)
    end)

    local hmBtn = AU.ui.Button(frame, '+', 21, buttonHeight)
    hmBtn:SetPoint('LEFT', keybindsBtn, 'RIGHT', -2, 0)
    yOffset = yOffset - buttonHeight - buttonSpacing

    local macrosBtn = AU.ui.Button(frame, 'Macros', 160, buttonHeight)
    macrosBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    macrosBtn:SetScript('OnClick', function()
        frame:Hide()
        MacroFrame_LoadUI()
        ShowUIPanel(MacroFrame)
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing * emptySpacing

    local logoutTimer = 0
    local logoutText = nil
    local exitTimer = 0
    local exitText = nil
    local logoutBtn = AU.ui.Button(frame, 'Logout', 160, buttonHeight)
    logoutBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    logoutBtn:SetScript('OnClick', function()
        frame:Hide()
        Logout()
        logoutTimer = 20
        AU.ui.StaticPopup_Show('Logging out in 20 seconds...', 'Cancel', function()
            CancelLogout()
            logoutTimer = 0
        end)
        logoutText = AU.ui.staticPopup.bodyText
        AU.ui.staticPopup.frame:SetPoint('TOP', UIParent, 'TOP', 0, -100)
        AU.ui.staticPopup.frame:SetScript('OnHide', function()
            CancelLogout()
            logoutTimer = 0
        end)
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing

    local exitBtn = AU.ui.Button(frame, 'Exit Game', 160, buttonHeight)
    exitBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    exitBtn:SetScript('OnClick', function()
        frame:Hide()
        exitTimer = 20
        AU.ui.StaticPopup_Show('Exiting in 20 seconds...', 'Exit Now', function()
            ForceQuit()
        end, 'Cancel', function()
            CancelLogout()
            exitTimer = 0
        end)
        exitText = AU.ui.staticPopup.bodyText
        AU.ui.staticPopup.frame:SetPoint('TOP', UIParent, 'TOP', 0, -100)
        AU.ui.staticPopup.frame:SetScript('OnHide', function()
            CancelLogout()
            exitTimer = 0
        end)
        Quit()
    end)
    yOffset = yOffset - buttonHeight - buttonSpacing * emptySpacing

    local returnBtn = AU.ui.Button(frame, 'Return to Game', 160, buttonHeight)
    returnBtn:SetPoint('TOP', frame, 'TOP', 0, yOffset)
    returnBtn:SetScript('OnClick', function()
        PlaySound('igMainMenuQuit')
        frame:Hide()
    end)

    local creditText = AU.ui.Font(frame, 7, 'made by guzruul', {.7, .7, .7}, 'CENTER')
    creditText:SetPoint('BOTTOM', frame, 'BOTTOM', 33, 5)

    frame:SetScript('OnShow', function()
        local btn = getglobal('AU_MicroButton_MainMenu')
        if btn then btn:SetButtonState('PUSHED', 1) end
        local buttonNames = {'Character', 'Spellbook', 'Talents', 'QuestLog', 'Socials', 'WorldMap', 'Help'}
        for _, name in ipairs(buttonNames) do
            local microBtn = getglobal('AU_MicroButton_' .. name)
            if microBtn then
                microBtn:EnableMouse(nil)
                local normalTex = microBtn:GetNormalTexture()
                if normalTex then normalTex:SetDesaturated(1) end
            end
        end
        local mainBag = getglobal('AU_MainBag')
        if mainBag then
            mainBag:Disable()
            local normalTex = mainBag:GetNormalTexture()
            if normalTex then normalTex:SetDesaturated(1) end
        end
        for i = 0, 3 do
            local smallBag = getglobal('AU_Bag' .. i)
            if smallBag then
                smallBag:Disable()
                if smallBag.icon then
                    smallBag.icon:SetDesaturated(1)
                    smallBag.icon:SetVertexColor(0.5, 0.5, 0.5)
                end
            end
        end
        local keyRing = getglobal('AU_KeyRing')
        if keyRing then keyRing:Disable() end
    end)
    frame:SetScript('OnHide', function()
        local btn = getglobal('AU_MicroButton_MainMenu')
        if btn then btn:SetButtonState('NORMAL') end
        local buttonNames = {'Character', 'Spellbook', 'Talents', 'QuestLog', 'Socials', 'WorldMap', 'Help'}
        for _, name in ipairs(buttonNames) do
            local microBtn = getglobal('AU_MicroButton_' .. name)
            if microBtn then
                microBtn:EnableMouse(1)
                local normalTex = microBtn:GetNormalTexture()
                if normalTex then normalTex:SetDesaturated(nil) end
            end
        end
        local mainBag = getglobal('AU_MainBag')
        if mainBag then
            mainBag:Enable()
            local normalTex = mainBag:GetNormalTexture()
            if normalTex then normalTex:SetDesaturated(nil) end
        end
        for i = 0, 3 do
            local smallBag = getglobal('AU_Bag' .. i)
            if smallBag then
                smallBag:Enable()
                if smallBag.icon then
                    smallBag.icon:SetDesaturated(nil)
                    smallBag.icon:SetVertexColor(1, 1, 1)
                end
            end
        end
        local keyRing = getglobal('AU_KeyRing')
        if keyRing then keyRing:Enable() end
    end)

    _G.ToggleGameMenu = function()
        if StaticPopup_EscapePressed() then
            return
        elseif frame:IsVisible() then
            PlaySound('igMainMenuQuit')
            frame:Hide()
        else
            local closedMenus = CloseMenus()
            local closedWindows = CloseAllWindows()
            if not (closedMenus or closedWindows) then
                if UnitExists('target') then
                    ClearTarget()
                else
                    PlaySound('igMainMenuOpen')
                    frame:Show()
                end
            end
        end
    end

    local origShowUIPanel = ShowUIPanel
    _G.ShowUIPanel = function(frm, force)
        if frm == GameMenuFrame then
            return
        end
        return origShowUIPanel(frm, force)
    end

    local origStaticPopup_Show = StaticPopup_Show
    _G.StaticPopup_Show = function(which, a1, a2, a3, a4, a5)
        if which == 'CAMP' or which == 'QUIT' then
            return
        end
        return origStaticPopup_Show(which, a1, a2, a3, a4, a5)
    end

    local lastUpdate = 0
    local updateFrame = CreateFrame('Frame')
    updateFrame:SetScript('OnUpdate', function()
        if logoutTimer > 0 then
            logoutTimer = logoutTimer - arg1
            lastUpdate = lastUpdate + arg1
            if logoutTimer <= 0 then
                logoutTimer = 0
                AU.ui.StaticPopup_Hide()
            elseif lastUpdate >= 0.1 and logoutText then
                lastUpdate = 0
                logoutText:SetText('Logging out in ' .. math.ceil(logoutTimer) .. ' seconds...')
            end
        end
        if exitTimer > 0 then
            exitTimer = exitTimer - arg1
            lastUpdate = lastUpdate + arg1
            if exitTimer <= 0 then
                exitTimer = 0
                AU.ui.StaticPopup_Hide()
            elseif lastUpdate >= 0.1 and exitText then
                lastUpdate = 0
                exitText:SetText('Exiting in ' .. math.ceil(exitTimer) .. ' seconds...')
            end
        end
    end)

    -- callbacks
    local helpers = {}
    local callbacks = {}

    callbacks.gamemenuprint = function(value)
        if value then
            -- print('gamemenu print from AU!')
        end
    end

    AU:NewCallbacks('gamemenu', callbacks)
end)
