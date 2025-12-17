UNLOCKAURORA()

AU:NewDefaults('help', {
    version = {value = '1.0'},
    enabled = {value = true},
})

AU:NewModule('help', 1, function()
    local regions = {HelpFrame:GetRegions()}
    for i = 1, table.getn(regions) do
        local region = regions[i]
        if region:GetObjectType() == 'Texture' then
            region:Hide()
        end
    end

    HelpFrameHeader:Hide()
    HelpFrameCloseButton:Hide()

    local customBg = AU.ui.CreatePaperDollFrame('AU_HelpCustomBg', HelpFrame, 640, 512, 2)
    customBg:SetPoint('TOPLEFT', HelpFrame, 'TOPLEFT', 0, 0)
    customBg:SetPoint('BOTTOMRIGHT', HelpFrame, 'BOTTOMRIGHT', -50, 15)
    customBg:SetFrameLevel(HelpFrame:GetFrameLevel() + 1)
    AU.setups.helpBg = customBg.Bg

    local helpBg = customBg:CreateTexture(nil, 'BORDER')
    helpBg:SetTexture('Interface\\Buttons\\WHITE8X8')
    helpBg:SetPoint('TOPLEFT', customBg, 'TOPLEFT', 3, -20)
    helpBg:SetPoint('BOTTOMRIGHT', customBg, 'BOTTOMRIGHT', -3, 3)
    helpBg:SetVertexColor(0, 0, 0, .3)

    local closeButton = AU.ui.CreateRedButton(customBg, 'close', function() HideUIPanel(HelpFrame) end)
    closeButton:SetPoint('TOPRIGHT', customBg, 'TOPRIGHT', 0, -1)
    closeButton:SetSize(20, 20)
    closeButton:SetFrameLevel(customBg:GetFrameLevel() + 3)

    tinsert(UISpecialFrames, 'AU_HelpCustomBg')

    -- callbacks
    local callbacks = {}
    AU:NewCallbacks('help', callbacks)
end)
