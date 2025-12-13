UNLOCKAURORA()

-- Defaults gui structure: {tab = 'tabname', subtab = 'subtabname', 'category1', 'category2', ...}
-- Named keys (tab, subtab) define panel location, array elements define categories within that panel
-- Each category groups related settings with a header, settings use category + indexInCategory for ordering

AU:NewDefaults('gui-extrapanels3', {
    enabled = {value = true},
    version = {value = '1.0'},
    gui = {
        {tab = 'template', subtab = 'mainbar', categories = 'General'},
    },

    templateprint = {value = true, metadata = {element = 'checkbox', category = 'General', indexInCategory = 1, description = 'template print description'}},



    -- examples:
    -- animationTexture = {value = 'Aura1', metadata = {element = 'dropdown', category = 'Animation', indexInCategory = 2, description = 'Animation texture style', options = {'Aura1', 'Aura2', 'Aura3', 'Aura4', 'Glow1', 'Glow2', 'Shock1', 'Shock2', 'Shock3'}, dependency = {key = 'minimapAnimation', state = true}}},
    -- customPlayerArrow = {value = true, metadata = {element = 'checkbox', category = 'Arrow', indexInCategory = 1, description = 'Use Dragonflight\'s custom player arrow', dependency = {key = 'showMinimap', state = true}}},
    -- playerArrowScale = {value = 1, metadata = {element = 'slider', category = 'Arrow', indexInCategory = 3, description = 'Size of the player arrow', min = 0.5, max = 2, stepSize = 0.1, dependency = {key = 'showMinimap', state = true}}},
    -- playerArrowColor = {value = {1, 1, 1}, metadata = {element = 'colorpicker', category = 'Arrow', indexInCategory = 4, description = 'Color of the player arrow', dependency = {key = 'customPlayerArrow', state = true}}},

})

AU:NewModule('gui-extrapanels3', 2, function()
    -- Aurora Module System Flow:
    -- ApplyDefaults() populates AU_GlobalDB[module][option] with default values from AU.defaults
    -- ExecModules() loads modules by calling each enabled module's func() based on priority
    -- Module's func() creates UI/features and calls NewCallbacks() as its last step
    -- NewCallbacks() registers callbacks and immediately executes them with current AU_GlobalDB values to initialize module state
    -- GUI changes trigger SetConfig() which updates AU_GlobalDB then re-executes the callback with new value
    local setup = AU.setups.guiBase
    if not setup then return end


    local profilePanel = setup.panels['profiles']

    local leftFrame = CreateFrame('Frame', nil, profilePanel)
    leftFrame:SetPoint('TOPLEFT', profilePanel, 'TOPLEFT', 0, 0)
    leftFrame:SetPoint('BOTTOMRIGHT', profilePanel, 'BOTTOM', -2, 0)

    local rightFrame = CreateFrame('Frame', nil, profilePanel)
    rightFrame:SetPoint('TOPRIGHT', profilePanel, 'TOPRIGHT', 0, 0)
    rightFrame:SetPoint('BOTTOMLEFT', profilePanel, 'BOTTOM', 2, 0)

    -- LEFT PANEL: Profile Management
    local leftHeader = AU.ui.Font(leftFrame, 12, 'Profile Management', {1, 0.82, 0})
    leftHeader:SetPoint('TOPLEFT', leftFrame, 'TOPLEFT', 10, -10)
    leftHeader:SetJustifyH('LEFT')

    local profileScroll = AU.ui.Scrollframe(leftFrame, leftFrame:GetWidth() - 20, leftFrame:GetHeight() - 150)
    profileScroll:SetPoint('TOPLEFT', leftHeader, 'BOTTOMLEFT', 0, -10)

    local profileUI = {selectedProfile = nil}

    function profileUI:RefreshProfileList()
        AU_GlobalDB.profiles = AU_GlobalDB.profiles or {}
        local profiles = {}
        for name, _ in pairs(AU_GlobalDB.profiles) do
            table.insert(profiles, name)
        end
        table.sort(profiles)

        for i = 1, table.getn(profileScroll.content.buttons or {}) do
            profileScroll.content.buttons[i]:Hide()
        end
        profileScroll.content.buttons = {}

        for i = 1, table.getn(profiles) do
            local profileName = profiles[i]
            local profileBtn = AU.ui.Button(profileScroll.content, profileName, profileScroll:GetWidth() - 10, 32)
            profileBtn:SetPoint('TOPLEFT', profileScroll.content, 'TOPLEFT', 5, -((i - 1) * 36))

            if AU_GlobalDB['gui-generator'] and AU_GlobalDB['gui-generator'].guifont then
                local fontPath = media[AU_GlobalDB['gui-generator'].guifont]
                if fontPath then
                    local _, size, flags = profileBtn.text:GetFont()
                    profileBtn.text:SetFont(fontPath, size, flags)
                end
            end

            profileBtn:SetScript('OnClick', function()
                profileUI.selectedProfile = profileName
                profileUI:UpdateRightPanel(profileName)
                if profileUI.selectedProfile ~= AU_GlobalDB.meta.activeProfile then
                    AU:SwitchProfile(profileUI.selectedProfile)
                    profileUI:RefreshProfileList()
                end
            end)
            if profileName == AU_GlobalDB.meta.activeProfile then
                profileBtn:SetBackdropBorderColor(0, 0.8, 1, 1)
            end
            table.insert(profileScroll.content.buttons, profileBtn)
        end
        profileScroll.content:SetHeight(table.getn(profiles) * 36)
        profileScroll.updateScrollBar()
    end

    profileUI:RefreshProfileList()

    local inputDialog = AU.ui.Frame(UIParent, 300, 120, 0.9, true)
    inputDialog:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    inputDialog:SetFrameStrata('DIALOG')
    inputDialog:Hide()

    local inputLabel = AU.ui.Font(inputDialog, 12, 'Enter Profile Name:', {1, 0.82, 0})
    inputLabel:SetPoint('TOP', inputDialog, 'TOP', 0, -15)

    local inputBox = AU.ui.Editbox(inputDialog, 260, 30, 50)
    inputBox:SetPoint('TOP', inputLabel, 'BOTTOM', 0, -10)
    inputBox:SetScript('OnEscapePressed', function()
        inputBox:SetText('')
        inputDialog:Hide()
    end)
    inputBox:SetScript('OnEnterPressed', function()
        inputOkBtn:Click()
    end)

    local inputOkBtn = AU.ui.Button(inputDialog, 'OK', 120, 28)
    inputOkBtn:SetPoint('BOTTOMLEFT', inputDialog, 'BOTTOMLEFT', 15, 10)
    inputOkBtn:SetScript('OnClick', function()
        local text = inputBox:GetText()
        if text and text ~= '' then
            if inputDialog.mode == 'new' then
                AU:CreateProfile(text)
            elseif inputDialog.mode == 'copy' and profileUI.selectedProfile then
                AU:CreateProfile(text)
                AU_GlobalDB.profiles[text] = AU_GlobalDB.profiles[profileUI.selectedProfile]
            elseif inputDialog.mode == 'rename' and profileUI.selectedProfile then
                AU_GlobalDB.profiles[text] = AU_GlobalDB.profiles[profileUI.selectedProfile]
                AU_GlobalDB.profiles[profileUI.selectedProfile] = nil
                if AU_GlobalDB.meta.activeProfile == profileUI.selectedProfile then
                    AU_GlobalDB.meta.activeProfile = text
                    AU.others.currentProfile = text
                end
                local charName = UnitName('player')
                local realmName = GetRealmName()
                local charKey = charName .. '-' .. realmName
                if AU_GlobalDB.meta.characterProfiles and AU_GlobalDB.meta.characterProfiles[charKey] == profileUI.selectedProfile then
                    AU_GlobalDB.meta.characterProfiles[charKey] = text
                end
                profileUI.selectedProfile = text
            end
            profileUI:RefreshProfileList()
            inputBox:SetText('')
            inputDialog:Hide()
        end
    end)

    local inputCancelBtn = AU.ui.Button(inputDialog, 'Cancel', 120, 28)
    inputCancelBtn:SetPoint('BOTTOMRIGHT', inputDialog, 'BOTTOMRIGHT', -15, 10)
    inputCancelBtn:SetScript('OnClick', function()
        inputBox:SetText('')
        inputDialog:Hide()
    end)

    local btnWidth = (leftFrame:GetWidth() - 30) / 2
    local newBtn = AU.ui.Button(leftFrame, 'New', btnWidth, 28)
    newBtn:SetPoint('BOTTOMLEFT', leftFrame, 'BOTTOMLEFT', 10, 40)
    newBtn:SetScript('OnClick', function()
        inputDialog.mode = 'new'
        inputLabel:SetText('Enter Profile Name:')
        inputDialog:Show()
        inputBox:SetFocus()
    end)

    local copyBtn = AU.ui.Button(leftFrame, 'Copy', btnWidth, 28)
    copyBtn:SetPoint('BOTTOMRIGHT', leftFrame, 'BOTTOMRIGHT', -10, 40)
    copyBtn:SetScript('OnClick', function()
        if not profileUI.selectedProfile then return end
        inputDialog.mode = 'copy'
        inputLabel:SetText('Copy ' .. profileUI.selectedProfile .. ' to:')
        inputDialog:Show()
        inputBox:SetFocus()
    end)

    local renameBtn = AU.ui.Button(leftFrame, 'Rename', btnWidth, 28)
    renameBtn:SetPoint('BOTTOMLEFT', leftFrame, 'BOTTOMLEFT', 10, 8)
    renameBtn:SetScript('OnClick', function()
        if not profileUI.selectedProfile then return end
        inputDialog.mode = 'rename'
        inputLabel:SetText('Rename ' .. profileUI.selectedProfile .. ' to:')
        inputBox:SetText(profileUI.selectedProfile)
        inputDialog:Show()
        inputBox:SetFocus()
    end)

    local deleteBtn = AU.ui.Button(leftFrame, 'Delete', btnWidth, 28)
    deleteBtn:SetPoint('BOTTOMRIGHT', leftFrame, 'BOTTOMRIGHT', -10, 8)
    deleteBtn:SetScript('OnClick', function()
        if not profileUI.selectedProfile then return end
        AU.ui.StaticPopup_Show(
            'Delete profile: ' .. profileUI.selectedProfile .. '?',
            'Delete',
            function()
                AU:DeleteProfile(profileUI.selectedProfile)
                profileUI.selectedProfile = nil
                profileUI:RefreshProfileList()
            end,
            'Cancel',
            function() end
        )
    end)

    -- RIGHT PANEL: Profile Details
    local rightHeader = AU.ui.Font(rightFrame, 12, 'Profile Details', {1, 0.82, 0})
    rightHeader:SetPoint('TOPLEFT', rightFrame, 'TOPLEFT', 10, -10)
    rightHeader:SetJustifyH('LEFT')

    local profileName = AU.ui.Font(rightFrame, 14, 'Default', {0, 0.8, 1})
    profileName:SetPoint('TOPLEFT', rightHeader, 'BOTTOMLEFT', 0, -15)
    profileName:SetJustifyH('LEFT')

    local divider1 = AU.ui.Frame(rightFrame, rightFrame:GetWidth() - 20, 1, 0.3)
    divider1:SetPoint('TOPLEFT', profileName, 'BOTTOMLEFT', 0, -8)

    local createdLabel = AU.ui.Font(rightFrame, 10, 'Created:', {0.6, 0.6, 0.6})
    createdLabel:SetPoint('TOPLEFT', divider1, 'BOTTOMLEFT', 0, -12)
    createdLabel:SetJustifyH('LEFT')

    local createdValue = AU.ui.Font(rightFrame, 11, '2024-01-15 14:30', {1, 1, 1})
    createdValue:SetPoint('TOPLEFT', createdLabel, 'BOTTOMLEFT', 0, -4)
    createdValue:SetJustifyH('LEFT')

    local modifiedLabel = AU.ui.Font(rightFrame, 10, 'Last Modified:', {0.6, 0.6, 0.6})
    modifiedLabel:SetPoint('TOPLEFT', createdValue, 'BOTTOMLEFT', 0, -10)
    modifiedLabel:SetJustifyH('LEFT')

    local modifiedValue = AU.ui.Font(rightFrame, 11, '2024-01-20 09:15', {1, 1, 1})
    modifiedValue:SetPoint('TOPLEFT', modifiedLabel, 'BOTTOMLEFT', 0, -4)
    modifiedValue:SetJustifyH('LEFT')

    local divider2 = AU.ui.Frame(rightFrame, rightFrame:GetWidth() - 20, 1, 0.3)
    divider2:SetPoint('TOPLEFT', modifiedValue, 'BOTTOMLEFT', 0, -12)

    local descLabel = AU.ui.Font(rightFrame, 10, 'Description:', {0.6, 0.6, 0.6})
    descLabel:SetPoint('TOPLEFT', divider2, 'BOTTOMLEFT', 0, -12)
    descLabel:SetJustifyH('LEFT')

    profileUI.descBox = AU.ui.Editbox(rightFrame, rightFrame:GetWidth() - 20, 60, 200)
    profileUI.descBox:SetPoint('TOPLEFT', descLabel, 'BOTTOMLEFT', 0, -6)
    profileUI.descBox:SetText('My default Aurora profile')
    profileUI.descBox:SetScript('OnEscapePressed', function()
        profileUI.descBox:ClearFocus()
    end)
    profileUI.descBox:SetScript('OnEnterPressed', function()
        profileUI.descBox:ClearFocus()
    end)
    profileUI.profileName = profileName
    profileUI.createdValue = createdValue
    profileUI.modifiedValue = modifiedValue

    function profileUI:UpdateRightPanel(name)
        AU_GlobalDB.meta.profileMeta = AU_GlobalDB.meta.profileMeta or {}
        local meta = AU_GlobalDB.meta.profileMeta[name] or {}

        self.profileName:SetText(name)
        self.createdValue:SetText(meta.created or 'Unknown')
        self.modifiedValue:SetText(meta.modified or 'Unknown')
        self.descBox:SetText(meta.description or '')
    end

    profileUI.descBox:SetScript('OnTextChanged', function()
        if profileUI.selectedProfile then
            AU_GlobalDB.meta.profileMeta = AU_GlobalDB.meta.profileMeta or {}
            AU_GlobalDB.meta.profileMeta[profileUI.selectedProfile] = AU_GlobalDB.meta.profileMeta[profileUI.selectedProfile] or {}
            AU_GlobalDB.meta.profileMeta[profileUI.selectedProfile].description = profileUI.descBox:GetText()
            AU_GlobalDB.meta.profileMeta[profileUI.selectedProfile].modified = date('%Y-%m-%d %H:%M')
        end
    end)

    if AU_GlobalDB.meta.activeProfile then
        profileUI:UpdateRightPanel(AU_GlobalDB.meta.activeProfile)
    end

    local divider3 = AU.ui.Frame(rightFrame, rightFrame:GetWidth() - 20, 1, 0.3)
    divider3:SetPoint('TOPLEFT', profileUI.descBox, 'BOTTOMLEFT', 0, -12)

    local actionsLabel = AU.ui.Font(rightFrame, 10, 'Quick Actions:', {0.6, 0.6, 0.6})
    actionsLabel:SetPoint('TOPLEFT', divider3, 'BOTTOMLEFT', 0, -12)
    actionsLabel:SetJustifyH('LEFT')

    local importBtn = AU.ui.Button(rightFrame, 'Import Profile', rightFrame:GetWidth() - 20, 28)
    importBtn:SetPoint('TOPLEFT', actionsLabel, 'BOTTOMLEFT', 0, -8)
    importBtn:EnableMouse(false)
    importBtn:SetAlpha(0.5)

    local exportBtn = AU.ui.Button(rightFrame, 'Export Profile', rightFrame:GetWidth() - 20, 28)
    exportBtn:SetPoint('TOPLEFT', importBtn, 'BOTTOMLEFT', 0, -6)
    exportBtn:EnableMouse(false)
    exportBtn:SetAlpha(0.5)

    local resetBtn = AU.ui.Button(rightFrame, 'Reset to Defaults', rightFrame:GetWidth() - 20, 28)
    resetBtn:SetPoint('TOPLEFT', exportBtn, 'BOTTOMLEFT', 0, -6)
    resetBtn:EnableMouse(false)
    resetBtn:SetAlpha(0.5)

    local divider4 = AU.ui.Frame(rightFrame, rightFrame:GetWidth() - 20, 1, 0.3)
    divider4:SetPoint('TOPLEFT', resetBtn, 'BOTTOMLEFT', 0, -12)

    local statsLabel = AU.ui.Font(rightFrame, 10, 'Statistics:', {0.6, 0.6, 0.6})
    statsLabel:SetPoint('TOPLEFT', divider4, 'BOTTOMLEFT', 0, -12)
    statsLabel:SetJustifyH('LEFT')

    local modulesText = AU.ui.Font(rightFrame, 11, 'Enabled Modules: N/A', {1, 1, 1})
    modulesText:SetPoint('TOPLEFT', statsLabel, 'BOTTOMLEFT', 0, -6)
    modulesText:SetJustifyH('LEFT')

    local settingsText = AU.ui.Font(rightFrame, 11, 'Custom Settings: N/A', {1, 1, 1})
    settingsText:SetPoint('TOPLEFT', modulesText, 'BOTTOMLEFT', 0, -4)
    settingsText:SetJustifyH('LEFT')

    function profileUI:Serialize(tbl, spacing)
        spacing = spacing or ''
        local str = spacing .. '{\n'
        for k, v in pairs(tbl) do
            if type(v) == 'table' then
                str = str .. spacing .. '  ["' .. k .. '"] = ' .. self:Serialize(v, spacing .. '  ') .. ',\n'
            elseif type(v) == 'string' then
                local escaped = string.gsub(v, '\\', '\\\\')
                escaped = string.gsub(escaped, '"', '\\"')
                str = str .. spacing .. '  ["' .. k .. '"] = "' .. escaped .. '",\n'
            elseif type(v) == 'number' then
                str = str .. spacing .. '  ["' .. k .. '"] = ' .. v .. ',\n'
            end
        end
        str = str .. spacing .. '}'
        return str
    end

    function profileUI:Compress(input)
        if type(input) ~= 'string' then return nil end
        local len = string.len(input)
        if len <= 1 then return 'u' .. input end

        local dict = {}
        for i = 0, 255 do
            local ic, iic = strchar(i), strchar(i, 0)
            dict[ic] = iic
        end
        local a, b = 0, 1
        local result = {'c'}
        local resultlen = 1
        local n = 2
        local word = ''

        for i = 1, len do
            local c = strsub(input, i, i)
            local wc = word .. c
            if not dict[wc] then
                local write = dict[word]
                if not write then return nil end
                result[n] = write
                resultlen = resultlen + string.len(write)
                n = n + 1
                if len <= resultlen then return 'u' .. input end
                if a >= 256 then
                    a, b = 0, b + 1
                    if b >= 256 then
                        dict = {}
                        b = 1
                    end
                end
                dict[wc] = strchar(a, b)
                a = a + 1
                word = c
            else
                word = wc
            end
        end
        result[n] = dict[word]
        resultlen = resultlen + string.len(result[n])
        n = n + 1
        if len <= resultlen then return 'u' .. input end
        return table.concat(result)
    end

    function profileUI:Decompress(input)
        if type(input) ~= 'string' or string.len(input) < 1 then return nil end

        local control = strsub(input, 1, 1)
        if control == 'u' then return strsub(input, 2) end
        if control ~= 'c' then return nil end

        input = strsub(input, 2)
        local len = string.len(input)
        if len < 2 then return nil end

        local dict = {}
        for i = 0, 255 do
            local ic, iic = strchar(i), strchar(i, 0)
            dict[iic] = ic
        end

        local a, b = 0, 1
        local result = {}
        local n = 1
        local last = strsub(input, 1, 2)
        result[n] = dict[last]
        n = n + 1

        for i = 3, len, 2 do
            local code = strsub(input, i, i + 1)
            local lastStr = dict[last]
            if not lastStr then return nil end
            local toAdd = dict[code]
            if toAdd then
                result[n] = toAdd
                n = n + 1
                local str = lastStr .. strsub(toAdd, 1, 1)
                if a >= 256 then
                    a, b = 0, b + 1
                    if b >= 256 then
                        dict = {}
                        b = 1
                    end
                end
                dict[strchar(a, b)] = str
                a = a + 1
            else
                local str = lastStr .. strsub(lastStr, 1, 1)
                result[n] = str
                n = n + 1
                if a >= 256 then
                    a, b = 0, b + 1
                    if b >= 256 then
                        dict = {}
                        b = 1
                    end
                end
                dict[strchar(a, b)] = str
                a = a + 1
            end
            last = code
        end
        return table.concat(result)
    end

    function profileUI:Encode(to_encode)
        local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        local bit_pattern = ''
        local encoded = ''
        local trailing = ''

        for i = 1, string.len(to_encode) do
            local remaining = tonumber(string.byte(string.sub(to_encode, i, i)))
            local bin_bits = ''
            for j = 7, 0, -1 do
                local current_power = math.pow(2, j)
                if remaining >= current_power then
                    bin_bits = bin_bits .. '1'
                    remaining = remaining - current_power
                else
                    bin_bits = bin_bits .. '0'
                end
            end
            bit_pattern = bit_pattern .. bin_bits
        end

        if math.mod(string.len(bit_pattern), 3) == 2 then
            trailing = '=='
            bit_pattern = bit_pattern .. '0000000000000000'
        elseif math.mod(string.len(bit_pattern), 3) == 1 then
            trailing = '='
            bit_pattern = bit_pattern .. '00000000'
        end

        for i = 1, string.len(bit_pattern), 6 do
            local byte = string.sub(bit_pattern, i, i + 5)
            local offset = tonumber(tonumber(byte, 2))
            encoded = encoded .. string.sub(index_table, offset + 1, offset + 1)
        end

        return string.sub(encoded, 1, -1 - string.len(trailing)) .. trailing
    end

    function profileUI:Decode(to_decode)
        local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        to_decode = string.gsub(to_decode, '\n', '')
        to_decode = string.gsub(to_decode, ' ', '')
        local padded = string.gsub(to_decode, '%s', '')
        local unpadded = string.gsub(padded, '=', '')
        local bit_pattern = ''
        local decoded = ''

        for i = 1, string.len(unpadded) do
            local char = string.sub(to_decode, i, i)
            local offset = string.find(index_table, char)
            if not offset then return nil end

            local remaining = tonumber(offset - 1)
            local bin_bits = ''
            for j = 7, 0, -1 do
                local current_power = math.pow(2, j)
                if remaining >= current_power then
                    bin_bits = bin_bits .. '1'
                    remaining = remaining - current_power
                else
                    bin_bits = bin_bits .. '0'
                end
            end
            bit_pattern = bit_pattern .. string.sub(bin_bits, 3)
        end

        for i = 1, string.len(bit_pattern), 8 do
            local byte = string.sub(bit_pattern, i, i + 7)
            decoded = decoded .. strchar(tonumber(byte, 2))
        end

        local padding_length = string.len(padded) - string.len(unpadded)
        if padding_length == 1 or padding_length == 2 then
            decoded = string.sub(decoded, 1, -2)
        end

        return decoded
    end

    function profileUI:ExportProfile(name)
        if not AU_GlobalDB.profiles[name] then return nil end
        local serialized = self:Serialize(AU_GlobalDB.profiles[name])
        local compressed = self:Compress(serialized)
        if not compressed then return nil end
        local encoded = self:Encode(compressed)
        return encoded
    end

    function profileUI:ImportProfile(encoded)
        local compressed = self:Decode(encoded)
        if not compressed then return nil end
        local serialized = self:Decompress(compressed)
        if not serialized then return nil end
        local func, err = loadstring('return ' .. serialized)
        if not func then return nil end
        local success, profile = pcall(func)
        if not success or not profile then return nil end
        assert(type(profile) == 'table', 'Invalid profile structure')
        return profile
    end

    local exportDialog = AU.ui.Frame(UIParent, 580, 420, 0.9, true)
    exportDialog:Hide()
    exportDialog:SetPoint('CENTER', 0, 0)
    exportDialog:SetMovable(true)
    exportDialog:EnableMouse(true)
    exportDialog:RegisterForDrag('LeftButton')
    exportDialog:SetScript('OnDragStart', function() exportDialog:StartMoving() end)
    exportDialog:SetScript('OnDragStop', function() exportDialog:StopMovingOrSizing() end)
    exportDialog:SetFrameStrata('DIALOG')
    table.insert(UISpecialFrames, 'AuroraExportDialog')

    local exportLabel = AU.ui.Font(exportDialog, 12, 'Export Profile', {1, 0.82, 0})
    exportLabel:SetPoint('TOP', exportDialog, 'TOP', 0, -10)

    local exportScroll = CreateFrame('ScrollFrame', 'AuroraExportScroll', exportDialog)
    exportScroll:SetPoint('TOPLEFT', exportDialog, 'TOPLEFT', 10, -30)
    exportScroll:SetPoint('BOTTOMRIGHT', exportDialog, 'BOTTOMRIGHT', -10, 50)
    exportScroll:SetWidth(560)
    exportScroll:SetHeight(340)

    local exportScrollBg = AU.ui.Frame(exportScroll, 560, 340, 0.3)
    exportScrollBg:SetAllPoints(exportScroll)

    local exportBox = CreateFrame('EditBox', 'AuroraExportEditBox', exportScroll)
    exportBox:SetMultiLine(true)
    exportBox:SetWidth(540)
    exportBox:SetHeight(340)
    exportBox:SetMaxLetters(0)
    exportBox:SetTextInsets(10, 10, 10, 10)
    exportBox:SetFontObject(GameFontHighlight)
    exportBox:SetAutoFocus(false)
    exportBox:SetJustifyH('LEFT')
    exportBox:SetScript('OnEscapePressed', function() exportBox:ClearFocus() exportDialog:Hide() end)
    exportBox:SetScript('OnTextChanged', function()
        exportScroll:UpdateScrollChildRect()
    end)
    exportScroll:SetScrollChild(exportBox)

    local exportCloseBtn = AU.ui.Button(exportDialog, 'Close', 560, 28)
    exportCloseBtn:SetPoint('BOTTOM', exportDialog, 'BOTTOM', 0, 10)
    exportCloseBtn:SetScript('OnClick', function()
        exportDialog:Hide()
    end)

    exportBtn:SetScript('OnClick', function()
        if not profileUI.selectedProfile then return end
        local encoded = profileUI:ExportProfile(profileUI.selectedProfile)
        if encoded then
            exportBox:SetText(encoded)
            exportBox:HighlightText()
            exportDialog:Show()
            exportBox:SetFocus()
        end
    end)

    local importDialog = AU.ui.Frame(UIParent, 580, 480, 0.9, true)
    importDialog:Hide()
    importDialog:SetPoint('CENTER', 0, 0)
    importDialog:SetMovable(true)
    importDialog:EnableMouse(true)
    importDialog:RegisterForDrag('LeftButton')
    importDialog:SetScript('OnDragStart', function() importDialog:StartMoving() end)
    importDialog:SetScript('OnDragStop', function() importDialog:StopMovingOrSizing() end)
    importDialog:SetFrameStrata('DIALOG')
    table.insert(UISpecialFrames, 'AuroraImportDialog')

    local importLabel = AU.ui.Font(importDialog, 12, 'Import Profile', {1, 0.82, 0})
    importLabel:SetPoint('TOP', importDialog, 'TOP', 0, -10)

    local importScroll = CreateFrame('ScrollFrame', 'AuroraImportScroll', importDialog)
    importScroll:SetPoint('TOPLEFT', importDialog, 'TOPLEFT', 10, -30)
    importScroll:SetPoint('TOPRIGHT', importDialog, 'TOPRIGHT', -10, -30)
    importScroll:SetHeight(300)
    importScroll:SetWidth(560)

    local importScrollBg = AU.ui.Frame(importScroll, 560, 300, 0.3)
    importScrollBg:SetAllPoints(importScroll)

    local importBox = CreateFrame('EditBox', 'AuroraImportEditBox', importScroll)
    importBox:SetMultiLine(true)
    importBox:SetWidth(540)
    importBox:SetHeight(300)
    importBox:SetMaxLetters(0)
    importBox:SetTextInsets(10, 10, 10, 10)
    importBox:SetFontObject(GameFontHighlight)
    importBox:SetAutoFocus(false)
    importBox:SetJustifyH('LEFT')
    importBox:SetScript('OnEscapePressed', function() importBox:ClearFocus() end)
    importBox:SetScript('OnTextChanged', function()
        importScroll:UpdateScrollChildRect()
    end)
    importScroll:SetScrollChild(importBox)

    local importNameLabel = AU.ui.Font(importDialog, 11, 'Profile Name:', {0.6, 0.6, 0.6})
    importNameLabel:SetPoint('TOPLEFT', importScroll, 'BOTTOMLEFT', 0, -15)

    local importNameBox = AU.ui.Editbox(importDialog, 560, 30, 50)
    importNameBox:SetPoint('TOPLEFT', importNameLabel, 'BOTTOMLEFT', 0, -5)
    importNameBox:SetScript('OnEscapePressed', function()
        importDialog:Hide()
    end)

    local importOkBtn = AU.ui.Button(importDialog, 'Import', 270, 28)
    importOkBtn:SetPoint('BOTTOMLEFT', importDialog, 'BOTTOMLEFT', 10, 10)
    importOkBtn:SetScript('OnClick', function()
        local encoded = importBox:GetText()
        local name = importNameBox:GetText()
        if not encoded or encoded == '' then return end
        if not name or name == '' then return end
        local profile = profileUI:ImportProfile(encoded)
        if profile then
            AU:CreateProfile(name)
            AU_GlobalDB.profiles[name] = profile
            profileUI:RefreshProfileList()
            importBox:SetText('')
            importNameBox:SetText('')
            importDialog:Hide()
        end
    end)

    local importCancelBtn = AU.ui.Button(importDialog, 'Cancel', 270, 28)
    importCancelBtn:SetPoint('BOTTOMRIGHT', importDialog, 'BOTTOMRIGHT', -10, 10)
    importCancelBtn:SetScript('OnClick', function()
        importBox:SetText('')
        importNameBox:SetText('')
        importDialog:Hide()
    end)

    importBtn:SetScript('OnClick', function()
        importDialog:Show()
        importBox:SetFocus()
    end)

    -- callbacks
    local callbacks = {}
    local callbackHelper = {definesomethinginheredirectly}

    callbacks.templateprint = function(value)
    end

    AU:NewCallbacks('gui-extrapanels3', callbacks)
end)
