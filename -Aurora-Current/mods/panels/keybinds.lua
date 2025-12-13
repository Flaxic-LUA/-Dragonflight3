UNLOCKAURORA()

AU:NewDefaults('keybinds', {
    version = {value = '1.0'},
    enabled = {value = true},
    gui = {
        {indexRange = {1, 1}, tab = 'keybinds', subtab = 1},
    },

})

AU:NewModule('keybinds', 1, 'PLAYER_ENTERING_WORLD', function()
    local keybindsFrame = AU.ui.CreatePaperDollFrame('AU_KeybindsFrame', UIParent, 600, 600, 2)
    keybindsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    keybindsFrame:EnableMouse(true)
    keybindsFrame:SetFrameStrata('MEDIUM')
    keybindsFrame:Hide()

    local closeButton = AU.ui.CreateRedButton(keybindsFrame, 'close', function()
        LoadBindings(GetCurrentBindingSet())
        keybindsFrame:Hide()
    end)
    closeButton:SetPoint('TOPRIGHT', keybindsFrame, 'TOPRIGHT', 0, -1)

    local header = AU.ui.Font(keybindsFrame, 12, 'Keybinds', {1, 1, 1}, 'CENTER')
    header:SetPoint('TOP', keybindsFrame, 'TOP', 0, -6)

    local charSpecificCheck = AU.ui.Checkbox(keybindsFrame, 'Character Specific Keybinds', 13, 13, 'RIGHT')
    charSpecificCheck:SetPoint('TOP', keybindsFrame, 'TOP', 70, -30)

    local okButton = AU.ui.Button(keybindsFrame, 'Okay', 100, 30)
    okButton:SetPoint('BOTTOMRIGHT', keybindsFrame, 'BOTTOMRIGHT', -10, 10)
    okButton:SetScript('OnClick', function()
        SaveBindings(GetCurrentBindingSet())
        keybindsFrame:Hide()
    end)

    local cancelButton = AU.ui.Button(keybindsFrame, 'Cancel', 100, 30)
    cancelButton:SetPoint('RIGHT', okButton, 'LEFT', -5, 0)
    cancelButton:SetScript('OnClick', function()
        LoadBindings(GetCurrentBindingSet())
        keybindsFrame:Hide()
    end)

    local unbindButton = AU.ui.Button(keybindsFrame, 'Unbind Key', 100, 30)
    unbindButton:SetPoint('RIGHT', cancelButton, 'LEFT', -5, 0)
    unbindButton:SetScript('OnClick', function()
        if keybindsFrame.selected and keybindsFrame.keyID then
            local key1, key2 = GetBindingKey(keybindsFrame.selected)
            if keybindsFrame.keyID == 1 and key1 then
                SetBinding(key1)
            elseif keybindsFrame.keyID == 2 and key2 then
                SetBinding(key2)
            end
            if keybindsFrame.buttonPressed and keybindsFrame.buttonPressed.border then
                keybindsFrame.buttonPressed.border:Hide()
            end
            keybindsFrame.selected = nil
            keybindsFrame:UpdateRows()
        end
    end)

    local resetButton = AU.ui.Button(keybindsFrame, 'Reset to Defaults', 130, 30)
    resetButton:SetPoint('RIGHT', unbindButton, 'LEFT', -5, 0)
    resetButton:SetScript('OnClick', function()
        LoadBindings(0)
        keybindsFrame:UpdateRows()
    end)

    local commandLabel = AU.ui.Font(keybindsFrame, 10, 'Command', {1, 0.82, 0}, 'LEFT')
    commandLabel:SetPoint('TOPLEFT', keybindsFrame, 'TOPLEFT', 30, -55)
    local key1Label = AU.ui.Font(keybindsFrame, 10, 'Key 1', {1, 0.82, 0}, 'LEFT')
    key1Label:SetPoint('LEFT', commandLabel, 'LEFT', 175, 0)
    local key2Label = AU.ui.Font(keybindsFrame, 10, 'Key 2', {1, 0.82, 0}, 'LEFT')
    key2Label:SetPoint('LEFT', key1Label, 'LEFT', 180, 0)

    local scrollFrame = AU.ui.Scrollframe(keybindsFrame, 500, 490, 'AU_KeybindsScrollFrame')
    scrollFrame:SetPoint('TOPLEFT', keybindsFrame, 'TOPLEFT', 20, -70)
    scrollFrame:SetPoint('BOTTOMRIGHT', keybindsFrame, 'BOTTOMRIGHT', -15, 45)
    -- debugframe(scrollFrame)

    local ROWS_DISPLAYED = 18
    local ROW_HEIGHT = 27
    local rows = {}

    for i = 1, ROWS_DISPLAYED do
        local row = CreateFrame('Frame', nil, scrollFrame.content)
        row:SetWidth(560)
        row:SetHeight(25)
        row:SetPoint('TOPLEFT', scrollFrame.content, 'TOPLEFT', 0, -(i-1) * ROW_HEIGHT)

        row.header = AU.ui.Font(row, 10, '', {1, 0.82, 0}, 'LEFT')
        row.header:SetPoint('LEFT', row, 'LEFT', 0, 0)
        row.header:Hide()

        row.desc = AU.ui.Font(row, 9, '', {1, 1, 1}, 'LEFT')
        row.desc:SetPoint('LEFT', row, 'LEFT', 0, 0)
        row.desc:Hide()

        row.key1 = AU.ui.Button(row, '', 180, 22)
        row.key1:SetPoint('LEFT', row, 'LEFT', 175, 0)
        row.key1:Hide()

        row.key1.border = CreateFrame('Frame', nil, row.key1)
        row.key1.border:SetAllPoints(row.key1)
        row.key1.border:SetBackdrop({edgeFile = 'Interface\\Buttons\\WHITE8X8', edgeSize = 1})
        row.key1.border:SetBackdropBorderColor(1, 1, 1)
        row.key1.border:Hide()

        row.key2 = AU.ui.Button(row, '', 180, 22)
        row.key2:SetPoint('LEFT', row.key1, 'RIGHT', 0, 0)
        row.key2:Hide()

        row.key2.border = CreateFrame('Frame', nil, row.key2)
        row.key2.border:SetAllPoints(row.key2)
        row.key2.border:SetBackdrop({edgeFile = 'Interface\\Buttons\\WHITE8X8', edgeSize = 1})
        row.key2.border:SetBackdropBorderColor(1, 1, 1)
        row.key2.border:Hide()

        row.key1:SetScript('OnClick', function()
            if keybindsFrame.buttonPressed and keybindsFrame.buttonPressed.border then
                keybindsFrame.buttonPressed.border:Hide()
            end
            keybindsFrame.selected = this.commandName
            keybindsFrame.keyID = this.keyID
            keybindsFrame.buttonPressed = this
            this.border:Show()
            keybindsFrame:UpdateRows()
        end)

        row.key2:SetScript('OnClick', function()
            if keybindsFrame.buttonPressed and keybindsFrame.buttonPressed.border then
                keybindsFrame.buttonPressed.border:Hide()
            end
            keybindsFrame.selected = this.commandName
            keybindsFrame.keyID = this.keyID
            keybindsFrame.buttonPressed = this
            this.border:Show()
            keybindsFrame:UpdateRows()
        end)

        rows[i] = row
    end

    function keybindsFrame:UpdateRows()
        local numBindings = GetNumBindings()
        local offset = math.floor(scrollFrame:GetVerticalScroll() / ROW_HEIGHT)

        for i = 1, ROWS_DISPLAYED do
            local index = offset + i
            local row = rows[i]

            row:ClearAllPoints()
            row:SetPoint('TOPLEFT', scrollFrame.content, 'TOPLEFT', 0, -((index - 1) * ROW_HEIGHT))

            if index <= numBindings then
                local commandName, binding1, binding2 = GetBinding(index)

                if string.sub(commandName, 1, 6) == 'HEADER' then
                    row.header:SetText(getglobal('BINDING_'..commandName) or commandName)
                    row.header:Show()
                    row.desc:Hide()
                    row.key1:Hide()
                    row.key2:Hide()
                else
                    row.header:Hide()
                    row.desc:SetText(getglobal('BINDING_NAME_'..commandName) or commandName)
                    row.desc:Show()

                    row.key1.commandName = commandName
                    row.key1.keyID = 1
                    if binding1 and binding1 ~= '' then
                        row.key1.text:SetText(binding1)
                        row.key1.text:SetTextColor(1, 1, 1)
                    else
                        row.key1.text:SetText('Not Bound')
                        row.key1.text:SetTextColor(1, 0.82, 0)
                    end
                    row.key1:Show()

                    row.key2.commandName = commandName
                    row.key2.keyID = 2
                    if binding2 and binding2 ~= '' then
                        row.key2.text:SetText(binding2)
                        row.key2.text:SetTextColor(1, 1, 1)
                    else
                        row.key2.text:SetText('Not Bound')
                        row.key2.text:SetTextColor(1, 0.82, 0)
                    end
                    row.key2:Show()
                end
                row:Show()
            else
                row:Hide()
            end
        end
    end

    keybindsFrame:EnableKeyboard(true)
    keybindsFrame:SetScript('OnKeyDown', function()
        if not keybindsFrame.selected then return end

        local key = arg1
        if key == 'ESCAPE' then
            if keybindsFrame.buttonPressed and keybindsFrame.buttonPressed.border then
                keybindsFrame.buttonPressed.border:Hide()
            end
            keybindsFrame.selected = nil
            keybindsFrame:UpdateRows()
            return
        end

        if IsShiftKeyDown() then key = 'SHIFT-'..key end
        if IsControlKeyDown() then key = 'CTRL-'..key end
        if IsAltKeyDown() then key = 'ALT-'..key end

        local key1, key2 = GetBindingKey(keybindsFrame.selected)
        if key1 then SetBinding(key1) end
        if key2 then SetBinding(key2) end

        if keybindsFrame.keyID == 1 then
            SetBinding(key, keybindsFrame.selected)
            if key2 then SetBinding(key2, keybindsFrame.selected) end
        else
            if key1 then SetBinding(key1, keybindsFrame.selected) end
            SetBinding(key, keybindsFrame.selected)
        end

        if keybindsFrame.buttonPressed and keybindsFrame.buttonPressed.border then
            keybindsFrame.buttonPressed.border:Hide()
        end
        keybindsFrame.selected = nil
        keybindsFrame:UpdateRows()
    end)

    keybindsFrame:SetScript('OnShow', function()
        LoadBindings(GetCurrentBindingSet())
        keybindsFrame:UpdateRows()
    end)

    local numBindings = GetNumBindings()
    scrollFrame.content:SetHeight(numBindings * ROW_HEIGHT)
    scrollFrame.updateScrollBar()
    keybindsFrame:UpdateRows()

    local oldMouseWheel = scrollFrame:GetScript('OnMouseWheel')
    scrollFrame:SetScript('OnMouseWheel', function()
        if oldMouseWheel then oldMouseWheel() end
        keybindsFrame:UpdateRows()
    end)

    scrollFrame.scrollBar:SetScript('OnValueChanged', function()
        local value = this:GetValue()
        scrollFrame:SetVerticalScroll(value)
        keybindsFrame:UpdateRows()
    end)

    table.insert(UISpecialFrames, keybindsFrame:GetName())

    -- callbacks
    local helpers = {}
    local callbacks = {}


    AU.common.KillFrame(KeyBindingFrame)

    AU:NewCallbacks('keybinds', callbacks)
end)
