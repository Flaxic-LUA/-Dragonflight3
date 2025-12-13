UNLOCKAURORA()

AU:NewDefaults('macros', {
    version = {value = '1.0'},
    enabled = {value = true},
    gui = {
        {indexRange = {1, 1}, tab = 'macros', subtab = 1},
    },

    macrosprint = {value = true, metadata = {element = 'checkbox', category = 'General', index = 1, description = 'macros print description'}},
})

AU:NewModule('macros', 1, 'PLAYER_ENTERING_WORLD', function()
    AU.common.KillFrame(MacroFrame)

    local macrosFrame = AU.ui.CreatePaperDollFrame('AU_MacroFrame', UIParent, 350, 450, 2)
    macrosFrame:SetPoint('LEFT', UIParent, 'LEFT', 15, 100)
    macrosFrame:EnableMouse(true)
    macrosFrame:Hide()

    local closeButton = AU.ui.CreateRedButton(macrosFrame, 'close', function() macrosFrame:Hide() end)
    closeButton:SetPoint('TOPRIGHT', macrosFrame, 'TOPRIGHT', 0, -1)

    local header = AU.ui.Font(macrosFrame, 12, 'Macros', {1, 1, 1}, 'CENTER')
    header:SetPoint('TOP', macrosFrame, 'TOP', 0, -6)

    local currentTab = 'general'

    macrosFrame:AddTab('General', function()
        currentTab = 'general'
    end)

    macrosFrame:AddTab(UnitName('player') .. ' Macros', function()
        currentTab = 'character'
    end, 120)

    local selectedMacroIcon = macrosFrame:CreateTexture(nil, 'ARTWORK')
    selectedMacroIcon:SetWidth(20)
    selectedMacroIcon:SetHeight(20)
    selectedMacroIcon:SetPoint('CENTER', macrosFrame, 'CENTER', -145, -15)
    selectedMacroIcon:Hide()

    local selectedMacroPrefix = AU.ui.Font(macrosFrame, 11, 'Selected Macro:', {1, 0.82, 0}, 'LEFT')
    selectedMacroPrefix:SetPoint('LEFT', selectedMacroIcon, 'RIGHT', 5, 0)

    local selectedMacroLabel = AU.ui.Font(macrosFrame, 11, 'None', {1, 1, 1}, 'LEFT')
    selectedMacroLabel:SetPoint('LEFT', selectedMacroPrefix, 'RIGHT', 5, 0)

    local selectedMacroIndex = nil

    local macroButtons = {}
    for i = 1, 18 do
        local btn = CreateFrame('CheckButton', nil, macrosFrame)
        btn:SetWidth(35)
        btn:SetHeight(35)
        local row = math.floor((i - 1) / 6)
        local col = math.mod(i - 1, 6)
        btn:SetPoint('TOPLEFT', macrosFrame, 'TOPLEFT', 20 + col * 50, -40 - row * 46)
        btn.normalTex = btn:CreateTexture(nil, 'BACKGROUND')
        btn.normalTex:SetTexture('Interface\\Buttons\\White8x8')
        btn.normalTex:SetVertexColor(0, 0, 0, 0)
        btn.normalTex:SetAllPoints(btn)
        -- btn:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress')
        -- btn:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square')
        btn:SetCheckedTexture('Interface\\Buttons\\CheckButtonHilight')

        btn.customHighlight = btn:CreateTexture(nil, 'HIGHLIGHT')
        btn.customHighlight:SetTexture(media['tex:panels:spellbook_highlight.blp'])
        btn.customHighlight:SetWidth(42)
        btn.customHighlight:SetHeight(42)
        btn.customHighlight:SetPoint('CENTER', btn, 'CENTER', 0, 0)
        btn.customHighlight:SetBlendMode('ADD')
        btn.customHighlight:Hide()

        btn.border = btn:CreateTexture(nil, 'OVERLAY')
        btn.border:SetTexture(media['tex:bars:border.blp'])
        btn.border:SetAllPoints(btn)

        btn:SetScript('OnEnter', function()
            if this.customHighlight then
                this.customHighlight:Show()
            end
        end)
        btn:SetScript('OnLeave', function()
            if this.customHighlight then
                this.customHighlight:Hide()
            end
        end)

        btn.macroTextFrame = CreateFrame('Frame', nil, btn)
        btn.macroTextFrame:SetAllPoints(btn)
        btn.macroTextFrame:SetFrameLevel(btn:GetFrameLevel() + 2)
        btn.macroText = btn.macroTextFrame:CreateFontString(nil, 'OVERLAY')
        btn.macroText:SetFont('Fonts\\FRIZQT__.TTF', 10, 'OUTLINE')
        btn.macroText:SetPoint('BOTTOM', btn.macroTextFrame, 'BOTTOM', 0, 2)
        btn.macroText:SetTextColor(1, 1, 1, 1)
        btn.macroText:SetText('')

        macroButtons[i] = btn
    end

    local editBox = CreateFrame('ScrollFrame', nil, macrosFrame)
    editBox:SetWidth(330)
    editBox:SetHeight(150)
    editBox:SetPoint('BOTTOM', macrosFrame, 'BOTTOM', 0, 40)
    editBox:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8X8', edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border', edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    editBox:SetBackdropColor(0, 0, 0, 0.8)
    editBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    editBox:EnableMouse(true)
    -- debugframe(editBox)

    local editBoxText = CreateFrame('EditBox', nil, editBox)
    editBoxText:SetWidth(editBox:GetWidth() - 20)
    editBoxText:SetMultiLine(true)
    editBoxText:SetAutoFocus(false)
    editBoxText:SetFontObject(GameFontHighlight)
    editBoxText:SetMaxLetters(255)
    editBoxText:SetScript('OnEscapePressed', function()
        this:ClearFocus()
    end)
    editBox:SetScrollChild(editBoxText)
    editBox:SetHorizontalScroll(10)
    editBox:SetVerticalScroll(-10)
    editBox:SetScript('OnMouseDown', function()
        editBoxText:SetFocus()
    end)
    -- debugframe(editBoxText)

    local popupFrame = AU.ui.CreatePaperDollFrame('AU_MacroPopupFrame', UIParent, 300, 400, 2)
    popupFrame:SetPoint('TOPLEFT', macrosFrame, 'TOPRIGHT', 5, 0)
    popupFrame:Hide()

    local popupClose = AU.ui.CreateRedButton(popupFrame, 'close', function() popupFrame:Hide() end)
    popupClose:SetPoint('TOPRIGHT', popupFrame, 'TOPRIGHT', 0, -1)

    local popupHeader = AU.ui.Font(popupFrame, 12, 'Select Icon', {1, 1, 1}, 'CENTER')
    popupHeader:SetPoint('TOP', popupFrame, 'TOP', 0, -6)

    local nameBox = AU.ui.Editbox(popupFrame, 280, 25, false, false, 16)
    nameBox:SetPoint('TOP', popupFrame, 'TOP', 0, -30)

    local iconScroll = AU.ui.Scrollframe(popupFrame, 280, 280)
    iconScroll:SetPoint('TOP', nameBox, 'BOTTOM', 0, -10)

    local newBtn = AU.ui.Button(macrosFrame, 'New', 80, 25)
    newBtn:SetPoint('BOTTOMLEFT', macrosFrame, 'BOTTOMLEFT', 10, 10)
    newBtn:SetScript('OnClick', function()
        nameBox:SetText('')
        popupFrame.editMode = false
        popupFrame:Show()
    end)

    local updateBtn = AU.ui.Button(macrosFrame, 'Update', 80, 25)
    updateBtn:SetPoint('BOTTOM', macrosFrame, 'BOTTOM', -30, 10)
    updateBtn:SetScript('OnClick', function()
        if macrosFrame.selectedMacroIndex then
            local mName, mTexture = GetMacroInfo(macrosFrame.selectedMacroIndex)
            nameBox:SetText(mName)
            popupFrame.editMode = true
            popupFrame:Show()
        end
    end)

    local deleteBtn = AU.ui.Button(macrosFrame, 'Delete', 80, 25)
    deleteBtn:SetPoint('BOTTOMRIGHT', macrosFrame, 'BOTTOMRIGHT', -10, 10)
    deleteBtn:SetScript('OnClick', function()
        if macrosFrame.selectedMacroIndex then
            DeleteMacro(macrosFrame.selectedMacroIndex)
            macrosFrame.selectedMacroIndex = nil
            macrosFrame.selectedMacroLabel:SetText('None')
            macrosFrame.editBoxText:SetText('')
            macrosFrame:UpdateMacroButtons()
        end
    end)

    local numMacroIcons = GetNumMacroIcons()
    local iconButtons = {}
    local selectedIconIndex = nil

    for i = 1, numMacroIcons do
        local iconBtn = CreateFrame('CheckButton', nil, iconScroll.content)
        iconBtn:SetWidth(36)
        iconBtn:SetHeight(36)
        local row = math.floor((i - 1) / 6)
        local col = math.mod(i - 1, 6)
        iconBtn:SetPoint('TOPLEFT', iconScroll.content, 'TOPLEFT', 5 + col * 45, -5 - row * 45)
        local iconTex = GetMacroIconInfo(i)
        iconBtn.normalTex = iconBtn:CreateTexture(nil, 'BACKGROUND')
        iconBtn.normalTex:SetTexture('Interface\\Buttons\\White8x8')
        iconBtn.normalTex:SetVertexColor(0, 0, 0, 0)
        iconBtn.normalTex:SetAllPoints(iconBtn)
        iconBtn:SetNormalTexture(iconTex)
        iconBtn:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress')
        iconBtn:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square')
        iconBtn:SetCheckedTexture('Interface\\Buttons\\CheckButtonHilight')

        iconBtn.customHighlight = iconBtn:CreateTexture(nil, 'HIGHLIGHT')
        iconBtn.customHighlight:SetTexture(media['tex:panels:spellbook_highlight.blp'])
        iconBtn.customHighlight:SetWidth(42)
        iconBtn.customHighlight:SetHeight(42)
        iconBtn.customHighlight:SetPoint('CENTER', iconBtn, 'CENTER', 0, 0)
        iconBtn.customHighlight:SetBlendMode('ADD')
        iconBtn.customHighlight:Hide()

        iconBtn.border = iconBtn:CreateTexture(nil, 'OVERLAY')
        iconBtn.border:SetTexture(media['tex:bars:border.blp'])
        iconBtn.border:SetAllPoints(iconBtn)

        iconBtn:SetScript('OnEnter', function()
            if this.customHighlight then
                this.customHighlight:Show()
            end
        end)
        iconBtn:SetScript('OnLeave', function()
            if this.customHighlight then
                this.customHighlight:Hide()
            end
        end)

        iconBtn.iconIndex = i
        iconBtn:SetScript('OnClick', function()
            selectedIconIndex = this.iconIndex
            for j = 1, numMacroIcons do
                iconButtons[j]:SetChecked(false)
            end
            this:SetChecked(true)
        end)
        iconButtons[i] = iconBtn
    end
    iconScroll.content:SetHeight(math.ceil(numMacroIcons / 6) * 45 + 10)
    iconScroll.updateScrollBar()

    local okayBtn = AU.ui.Button(popupFrame, 'Okay', 100, 30)
    okayBtn:SetPoint('BOTTOM', popupFrame, 'BOTTOM', 0, 10)
    okayBtn:SetScript('OnClick', function()
        local macroName = nameBox:GetText()
        if macroName and string.len(macroName) > 0 and selectedIconIndex then
            if popupFrame.editMode and macrosFrame.selectedMacroIndex then
                EditMacro(macrosFrame.selectedMacroIndex, macroName, selectedIconIndex)
            else
                local isLocal = currentTab == 'character' and 1 or nil
                CreateMacro(macroName, selectedIconIndex, '', isLocal)
            end
            popupFrame:Hide()
            nameBox:SetText('')
            selectedIconIndex = nil
            for i = 1, numMacroIcons do
                iconButtons[i]:SetChecked(false)
            end
            macrosFrame:UpdateMacroButtons()
        end
    end)

    table.insert(UISpecialFrames, macrosFrame:GetName())
    table.insert(UISpecialFrames, popupFrame:GetName())

    macrosFrame.currentTab = currentTab
    macrosFrame.macroButtons = macroButtons
    macrosFrame.selectedMacroIndex = selectedMacroIndex
    macrosFrame.selectedMacroLabel = selectedMacroLabel
    macrosFrame.editBoxText = editBoxText

    function macrosFrame:UpdateMacroButtons()
        for i = 1, 18 do
            self.macroButtons[i]:SetChecked(false)
        end
        local numMacros = GetNumMacros()
        local displayIndex = 1
        for i = 1, numMacros do
            local name, texture, body, isLocal = GetMacroInfo(i)
            if (self.currentTab == 'general' and not isLocal) or (self.currentTab == 'character' and isLocal) then
                if displayIndex <= 18 then
                    self.macroButtons[displayIndex]:SetNormalTexture(texture)
                    self.macroButtons[displayIndex].macroIndex = i
                    local macroName = name
                    if macroName and string.len(macroName) > 4 then
                        macroName = string.sub(macroName, 1, 3) .. '...'
                    end
                    self.macroButtons[displayIndex].macroText:SetText(macroName or '')
                    self.macroButtons[displayIndex]:SetScript('OnClick', function()
                        self.selectedMacroIndex = this.macroIndex
                        local mName, mTexture, mBody = GetMacroInfo(this.macroIndex)
                        self.selectedMacroLabel:SetText(mName)
                        self.editBoxText:SetText(mBody)
                        selectedMacroIcon:SetTexture(mTexture)
                        selectedMacroIcon:Show()
                        for j = 1, 18 do
                            self.macroButtons[j]:SetChecked(false)
                        end
                        this:SetChecked(true)
                    end)
                    self.macroButtons[displayIndex]:Show()
                    displayIndex = displayIndex + 1
                end
            end
        end
        for i = displayIndex, 18 do
            self.macroButtons[i]:SetNormalTexture('')
            self.macroButtons[i].normalTex:SetTexture('Interface\\Buttons\\White8x8')
            self.macroButtons[i].normalTex:SetVertexColor(0, 0, 0, 0.5)
            self.macroButtons[i].normalTex:Show()
            self.macroButtons[i].macroText:SetText('')
            self.macroButtons[i].macroIndex = nil
            self.macroButtons[i]:SetScript('OnClick', function()
                this:SetChecked(false)
            end)
            self.macroButtons[i]:Show()
        end
    end

    macrosFrame.Tabs[1]:SetScript('OnClick', function()
        PlaySound('igCharacterInfoTab')
        if macrosFrame.selectedTab then
            macrosFrame.selectedTab:SetSelected(false)
        end
        macrosFrame.Tabs[1]:SetSelected(true)
        macrosFrame.selectedTab = macrosFrame.Tabs[1]
        macrosFrame.currentTab = 'general'
        macrosFrame.selectedMacroIndex = nil
        macrosFrame.selectedMacroLabel:SetText('None')
        macrosFrame.editBoxText:SetText('')
        selectedMacroIcon:Hide()
        macrosFrame:UpdateMacroButtons()
    end)

    macrosFrame.Tabs[2]:SetScript('OnClick', function()
        PlaySound('igCharacterInfoTab')
        if macrosFrame.selectedTab then
            macrosFrame.selectedTab:SetSelected(false)
        end
        macrosFrame.Tabs[2]:SetSelected(true)
        macrosFrame.selectedTab = macrosFrame.Tabs[2]
        macrosFrame.currentTab = 'character'
        macrosFrame.selectedMacroIndex = nil
        macrosFrame.selectedMacroLabel:SetText('None')
        macrosFrame.editBoxText:SetText('')
        selectedMacroIcon:Hide()
        macrosFrame:UpdateMacroButtons()
    end)

    macrosFrame:UpdateMacroButtons()

    -- callbacks
    local helpers = {}
    local callbacks = {}


    AU:NewCallbacks('macros', callbacks)
end)
