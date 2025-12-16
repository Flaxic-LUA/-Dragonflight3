UNLOCKAURORA()

AU:NewDefaults('characterframe', {
    enabled = {value = true},
    version = {value = '1.0'},
})

AU:NewModule('characterframe', 1,'PLAYER_ENTERING_WORLD',function()
    local frames = {PaperDollFrame, PetPaperDollFrame, SkillFrame, ReputationFrame, HonorFrame}

    for _, frame in frames do
        if frame then
            local regions = {frame:GetRegions()}
            for i = 1, table.getn(regions) do
                local region = regions[i]
                if region:GetObjectType() == 'Texture' then
                    local texture = region:GetTexture()
                    if texture and (string.find(texture, 'UI-Character-') or string.find(texture, 'PaperDoll')) then
                        region:Hide()
                    end
                end
            end
        end
    end

    CharacterFrameTab1:Hide()
    CharacterFrameTab2:Hide()
    CharacterFrameTab3:Hide()
    CharacterFrameTab4:Hide()
    CharacterFrameTab5:Hide()
    CharacterFrameCloseButton:Hide()

    local customBg = AU.ui.CreatePaperDollFrame('AU_CharacterCustomBg', CharacterFrame, 384, 512, 1)
    customBg:SetPoint('TOPLEFT', CharacterFrame, 'TOPLEFT', 12, -12)
    customBg:SetPoint('BOTTOMRIGHT', CharacterFrame, 'BOTTOMRIGHT', -32, 75)
    customBg:SetFrameLevel(CharacterFrame:GetFrameLevel() + 1)
    customBg.Bg:SetDrawLayer('BACKGROUND', -1)
    CharacterFramePortrait:SetParent(customBg)
    CharacterFramePortrait:SetDrawLayer('BACKGROUND', 0)

    local characterBg = customBg:CreateTexture(nil, 'OVERLAY')
    characterBg:SetTexture('Interface\\Buttons\\WHITE8X8')
    characterBg:SetPoint('TOPLEFT', customBg, 'TOPLEFT', 55, -60)
    characterBg:SetPoint('BOTTOMRIGHT', customBg, 'BOTTOMRIGHT', -55, 60)
    characterBg:SetVertexColor(0, 0, 0, .3)
    characterBg:Show()

    local closeButton = AU.ui.CreateRedButton(CharacterFrame, 'close', function() CharacterFrame:Hide() end)
    closeButton:SetPoint('TOPRIGHT', customBg, 'TOPRIGHT', 0, -1)
    closeButton:SetSize(20, 20)

    customBg:AddTab('Character', function()
        characterBg:Show()
        CharacterFrame_ShowSubFrame('PaperDollFrame')
        PanelTemplates_SetTab(CharacterFrame, 1)
    end, 70)

    if HasPetUI() then
        customBg:AddTab('Pet', function()
            characterBg:Hide()
            CharacterFrame_ShowSubFrame('PetPaperDollFrame')
            PanelTemplates_SetTab(CharacterFrame, 2)
        end, 60)
    end

    customBg:AddTab('Reputation', function()
        characterBg:Hide()
        CharacterFrame_ShowSubFrame('ReputationFrame')
        PanelTemplates_SetTab(CharacterFrame, 3)
    end, 75)

    customBg:AddTab('Skills', function()
        characterBg:Hide()
        CharacterFrame_ShowSubFrame('SkillFrame')
        PanelTemplates_SetTab(CharacterFrame, 4)
    end, 60)

    customBg:AddTab('Honor', function()
        characterBg:Hide()
        CharacterFrame_ShowSubFrame('HonorFrame')
        PanelTemplates_SetTab(CharacterFrame, 5)
    end, 60)

    tinsert(UISpecialFrames, 'AU_CharacterCustomBg')

    -- callbacks
    local callbacks = {}
    local callbackHelper = {definesomethinginheredirectly}

    AU:NewCallbacks('characterframe', callbacks)
end)
