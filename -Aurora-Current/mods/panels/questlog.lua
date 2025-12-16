UNLOCKAURORA()

AU:NewDefaults('questlog', {
    version = {value = '1.0'},
    enabled = {value = true},

})

AU:NewModule('questlog', 1, function()
    local regions = {QuestLogFrame:GetRegions()}
    for i = 1, table.getn(regions) do
        local region = regions[i]
        if region:GetObjectType() == 'Texture' then
            local texture = region:GetTexture()
            if texture and string.find(texture, 'QuestLog') then
                region:Hide()
            end
        end
    end
    QuestLogFrameCloseButton:Hide()

    local customBg = AU.ui.CreatePaperDollFrame('AU_QuestLogCustomBg', QuestLogFrame, 384, 400, 1)
    customBg:SetPoint('TOPLEFT', QuestLogFrame, 'TOPLEFT', 12, -12)
    customBg:SetPoint('BOTTOMRIGHT', QuestLogFrame, 'BOTTOMRIGHT', -91, 50)
    customBg:SetFrameLevel(QuestLogFrame:GetFrameLevel() - 1)

    tinsert(UISpecialFrames, 'AU_QuestLogCustomBg')

    local topWood = customBg:CreateTexture(nil, 'BORDER')
    topWood:SetTexture(media['tex:panels:spellbook_top_wood.blp'])
    topWood:SetPoint('TOPLEFT', customBg, 'TOPLEFT', 0, -10)
    topWood:SetPoint('RIGHT', customBg, 'RIGHT', 0, -60)
    topWood:SetSize(customBg:GetWidth()-10, 64)

    local bookIcon = customBg:CreateTexture(nil, 'ARTWORK')
    bookIcon:SetTexture('Interface\\QuestFrame\\UI-QuestLog-BookIcon')
    bookIcon:SetPoint('TOPLEFT', customBg, 'TOPLEFT', -3, 6)
    bookIcon:SetSize(56, 56)

    local leftBg = customBg:CreateTexture(nil, 'ARTWORK')
    leftBg:SetTexture(media['tex:panels:questlog_left_bg.blp'])
    leftBg:SetPoint('TOPLEFT', customBg, 'TOPLEFT', 1, -60)
    leftBg:SetPoint('BOTTOMRIGHT', customBg, 'BOTTOMRIGHT', -340, -310)

    local rightBg = customBg:CreateTexture(nil, 'ARTWORK')
    rightBg:SetTexture(media['tex:panels:questlog_right_bg.blp'])
    rightBg:SetPoint('TOPLEFT', customBg, 'TOPLEFT', 330, -60)
    rightBg:SetPoint('BOTTOMRIGHT', customBg, 'BOTTOMRIGHT', -25, -173)

    local bookmark = customBg:CreateTexture(nil, 'OVERLAY')
    bookmark:SetTexture(media['tex:panels:spellbook_bookmark.blp'])
    bookmark:SetPoint('TOP', customBg, 'TOP', 7, -55)
    bookmark:SetSize(50, 400)

    local closeButton = AU.ui.CreateRedButton(QuestLogFrame, 'close', function() QuestLogFrame:Hide() end)
    closeButton:SetPoint('TOPRIGHT', customBg, 'TOPRIGHT', 0, -1)
    closeButton:SetSize(20, 20)

    -- callbacks
    local helpers = {}
    local callbacks = {}

    AU:NewCallbacks('questlog', callbacks)
end)
