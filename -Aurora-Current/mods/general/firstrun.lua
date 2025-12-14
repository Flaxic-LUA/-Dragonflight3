UNLOCKAURORA()

AU:NewDefaults('firstrun', {
    enabled = {value = true},
    version = {value = '1.0'},
    gui = {
        {tab = 'firstrun', subtab = 'mainbar', categories = 'General'},
    },
})

AU:NewModule('firstrun', 1, function()
    local charName = UnitName('player')
    local realmName = GetRealmName()
    local charKey = charName .. '-' .. realmName

    AU_GlobalDB.meta.installShown = AU_GlobalDB.meta.installShown or {}

    if not AU_GlobalDB.meta.installShown[charKey] then
        local installFrame = AU.ui.CreatePaperDollFrame('AU_InstallPanel', UIParent, 350, 250, 2)
        installFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)

        local title = AU.ui.Font(installFrame, 16, 'Welcome to '..info.addonNameColor, {1, 1, 1}, 'CENTER')
        title:SetPoint('TOP', installFrame, 'TOP', 0, -30)

        local warning = AU.ui.Font(installFrame, 12, 'This is an |cffff0000ALPHA build|r. Expect bugs.\n\nGuzruul.', {1, 1, 1}, 'CENTER')
        warning:SetPoint('CENTER', installFrame, 'CENTER', 0, 0)

        local function ApplyProfile(profileName)
            local profile = AU.tables.profiles[profileName]
            if profile then
                for option, value in pairs(profile) do
                    if option == 'framePositions' then
                        AU.profile['editmode']['framePositions'] = value
                        for name, pos in pairs(value) do
                            local frame = getglobal(name)
                            if frame then
                                frame:ClearAllPoints()
                                if pos.parent and pos.rx and pos.ry then
                                    local parent = getglobal(pos.parent)
                                    if parent then
                                        frame:SetPoint('CENTER', parent, 'CENTER', pos.rx, pos.ry)
                                    end
                                elseif pos.x and pos.y then
                                    frame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', pos.x, pos.y)
                                end
                            end
                        end
                    else
                        for module, _ in pairs(AU.defaults) do
                            if AU.defaults[module][option] and AU.callbacks[module .. '.' .. option] then
                                AU:SetConfig(module, option, value)
                            end
                        end
                    end
                end
            end
        end

        -- local auroraBtn = AU.ui.Button(installFrame, 'Aurora', 100, 30)
        -- auroraBtn:SetPoint('BOTTOM', installFrame, 'BOTTOM', -55, 60)
        -- auroraBtn:SetScript('OnClick', function()
        --     ApplyProfile('Aurora')
        -- end)

        -- local dragonflightBtn = AU.ui.Button(installFrame, 'Dragonflight', 100, 30)
        -- dragonflightBtn:SetPoint('BOTTOM', installFrame, 'BOTTOM', 55, 60)
        -- dragonflightBtn:SetScript('OnClick', function()
        --     ApplyProfile('Dragonflight')
        -- end)

        local okBtn = AU.ui.Button(installFrame, 'OK', 100, 30)
        okBtn:SetPoint('BOTTOM', installFrame, 'BOTTOM', 0, 20)
        okBtn:SetScript('OnClick', function()
            AU_GlobalDB.meta.installShown[charKey] = true
            installFrame:Hide()
        end)
    end

    -- callbacks
    local callbacks = {}

    AU:NewCallbacks('firstrun', callbacks)
end)
