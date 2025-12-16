UNLOCKAURORA()

AU:NewDefaults('keybinds', {
    version = {value = '1.0'},
    enabled = {value = true},
})

AU:NewModule('keybinds', 1, function()
    local skinned = false

    local function SkinKeyBindingFrame()
        if skinned or not KeyBindingFrame then return end
        skinned = true

        local regions = {KeyBindingFrame:GetRegions()}
        for i = 1, table.getn(regions) do
            local region = regions[i]
            if region:GetObjectType() == 'Texture' then
                local texture = region:GetTexture()
                if texture and (string.find(texture, 'KeyBindingFrame') or string.find(texture, 'UI-Character-') or string.find(texture, 'ClassTrainer') or string.find(texture, 'PaperDollInfoFrame')) then
                    region:Hide()
                end
            end
        end
        if KeyBindingFrameCloseButton then KeyBindingFrameCloseButton:Hide() end

        local customBg = AU.ui.CreatePaperDollFrame('AU_KeyBindingCustomBg', KeyBindingFrame, 384, 512, 2)
        customBg:SetPoint('TOPLEFT', KeyBindingFrame, 'TOPLEFT', 0, -8)
        customBg:SetPoint('BOTTOMRIGHT', KeyBindingFrame, 'BOTTOMRIGHT', -32, 10)
        customBg:SetFrameLevel(KeyBindingFrame:GetFrameLevel() - 1)
        customBg.Bg:SetDrawLayer('BACKGROUND', -5)
        AU.setups.keybindingBg = customBg.Bg
        if AU.profile and AU.profile.UIParent and AU.profile.UIParent.keybindingBgAlpha then
            customBg.Bg:SetAlpha(AU.profile.UIParent.keybindingBgAlpha)
        end
        if AU.profile and AU.profile.UIParent and AU.profile.UIParent.keybindingScale then
            customBg:SetScale(AU.profile.UIParent.keybindingScale)
            KeyBindingFrame:SetScale(AU.profile.UIParent.keybindingScale)
        end

        local closeButton = AU.ui.CreateRedButton(customBg, 'close', function() HideUIPanel(KeyBindingFrame) end)
        closeButton:SetPoint('TOPRIGHT', customBg, 'TOPRIGHT', 0, -1)
        closeButton:SetSize(20, 20)
        closeButton:SetFrameLevel(customBg:GetFrameLevel() + 3)

        tinsert(UISpecialFrames, 'AU_KeyBindingCustomBg')
    end

    local frame = CreateFrame('Frame')
    frame:RegisterEvent('ADDON_LOADED')
    frame:SetScript('OnEvent', function()
        if arg1 == 'Blizzard_BindingUI' then
            SkinKeyBindingFrame()
        end
    end)

    if KeyBindingFrame then
        SkinKeyBindingFrame()
    end

    -- callbacks
    local helpers = {}
    local callbacks = {}
    AU:NewCallbacks('keybinds', callbacks)
end)
