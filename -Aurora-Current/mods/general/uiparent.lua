UNLOCKAURORA()

-- Defaults gui structure: {tab = 'tabname', subtab = 'subtabname', 'category1', 'category2', ...}
-- Named keys (tab, subtab) define panel location, array elements define categories within that panel
-- Each category groups related settings with a header, settings use category + indexInCategory for ordering

AU:NewDefaults('UIParent', {
    enabled = {value = true},
    version = {value = '1.0'},
    gui = {
        {tab = 'general', subtab = 'uiparent', 'General', 'UI Scale'},
    },

    characterBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 1, description = 'Character frame background transparency', min = 0, max = 1, stepSize = 0.1}},
    questlogBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 2, description = 'Quest log background transparency', min = 0, max = 1, stepSize = 0.1}},
    socialBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 3, description = 'Social frame background transparency', min = 0, max = 1, stepSize = 0.1}},
    helpBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 4, description = 'Help frame background transparency', min = 0, max = 1, stepSize = 0.1}},
    gamemenuBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 5, description = 'Game menu background transparency', min = 0, max = 1, stepSize = 0.1}},
    spellbookBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 6, description = 'Spellbook background transparency', min = 0, max = 1, stepSize = 0.1}},
    talentsBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 7, description = 'Talents background transparency', min = 0, max = 1, stepSize = 0.1}},
    keybindingBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 8, description = 'Keybinding frame background transparency', min = 0, max = 1, stepSize = 0.1}},
    macroBgAlpha = {value = 1, metadata = {element = 'slider', category = 'General', indexInCategory = 9, description = 'Macro frame background transparency', min = 0, max = 1, stepSize = 0.1}},

    characterScale = {value = 1, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 1, description = 'Character frame scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    questlogScale = {value = 1, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 2, description = 'Quest log scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    socialScale = {value = 1, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 3, description = 'Social frame scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    helpScale = {value = 1, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 4, description = 'Help frame scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    gamemenuScale = {value = 0.9, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 5, description = 'Game menu scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    spellbookScale = {value = 0.9, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 6, description = 'Spellbook scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    talentsScale = {value = 0.9, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 7, description = 'Talents scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    keybindingScale = {value = 1, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 8, description = 'Keybinding frame scale', min = 0.5, max = 1.5, stepSize = 0.05}},
    macroScale = {value = 1, metadata = {element = 'slider', category = 'UI Scale', indexInCategory = 9, description = 'Macro frame scale', min = 0.5, max = 1.5, stepSize = 0.05}},

})

AU:NewModule('UIParent', 2, 'PLAYER_ENTERING_WORLD', function()
    -- callbacks
    local callbacks = {}

    callbacks.characterBgAlpha = function(value)
        if AU.setups and AU.setups.characterBg then
            AU.setups.characterBg:SetAlpha(value)
        end
    end

    callbacks.questlogBgAlpha = function(value)
        if AU.setups then
            if AU.setups.questlogBg then AU.setups.questlogBg:SetAlpha(value) end
            if AU.setups.questlogTopWood then AU.setups.questlogTopWood:SetAlpha(value) end
            if AU.setups.questlogLeftBg then AU.setups.questlogLeftBg:SetAlpha(value) end
            if AU.setups.questlogRightBg then AU.setups.questlogRightBg:SetAlpha(value) end
            if AU.setups.questlogBookmark then AU.setups.questlogBookmark:SetAlpha(value) end
        end
    end

    callbacks.socialBgAlpha = function(value)
        if AU.setups and AU.setups.socialBg then
            AU.setups.socialBg:SetAlpha(value)
        end
    end

    callbacks.helpBgAlpha = function(value)
        if AU.setups and AU.setups.helpBg then
            AU.setups.helpBg:SetAlpha(value)
        end
    end

    callbacks.gamemenuBgAlpha = function(value)
        if AU.setups and AU.setups.gamemenuBg then
            AU.setups.gamemenuBg:SetAlpha(value)
        end
    end

    callbacks.spellbookBgAlpha = function(value)
        if AU.setups then
            if AU.setups.spellbookBg then AU.setups.spellbookBg:SetAlpha(value) end
            if AU.setups.spellbookLeftPage then AU.setups.spellbookLeftPage:SetAlpha(value) end
            if AU.setups.spellbookRightPage then AU.setups.spellbookRightPage:SetAlpha(value) end
            if AU.setups.spellbookTopWood then AU.setups.spellbookTopWood:SetAlpha(value) end
            if AU.setups.spellbookBookmark then AU.setups.spellbookBookmark:SetAlpha(value) end
        end
    end

    callbacks.talentsBgAlpha = function(value)
        if AU.setups then
            if AU.setups.talentsBg then AU.setups.talentsBg:SetAlpha(value) end
            if AU.setups.talentsTreeFrames then
                for i = 1, 3 do
                    local tree = AU.setups.talentsTreeFrames[i]
                    if tree then
                        if tree.bgTopLeft then tree.bgTopLeft:SetAlpha(value * 0.7) end
                        if tree.bgTopRight then tree.bgTopRight:SetAlpha(value * 0.7) end
                        if tree.bgBottomLeft then tree.bgBottomLeft:SetAlpha(value * 0.7) end
                        if tree.bgBottomRight then tree.bgBottomRight:SetAlpha(value * 0.7) end
                    end
                end
            end
        end
    end

    callbacks.keybindingBgAlpha = function(value)
        if AU.setups and AU.setups.keybindingBg then
            AU.setups.keybindingBg:SetAlpha(value)
        end
    end

    callbacks.macroBgAlpha = function(value)
        if AU.setups and AU.setups.macroBg then
            AU.setups.macroBg:SetAlpha(value)
        end
    end

    callbacks.characterScale = function(value)
        local customBg = getglobal('AU_CharacterCustomBg')
        if customBg then customBg:SetScale(value) end
        if CharacterFrame then CharacterFrame:SetScale(value) end
        if CharacterModelFrame then
            CharacterModelFrame:SetScale(1 + (value - 1) * 0.5)
            CharacterModelFrame:ClearAllPoints()
            CharacterModelFrame:SetPoint('CENTER', PaperDollFrame, 'CENTER', 0, 60)
        end
        if CharacterModelFrameRotateLeftButton then
            CharacterModelFrameRotateLeftButton:ClearAllPoints()
            CharacterModelFrameRotateLeftButton:SetPoint('TOPLEFT', CharacterHeadSlot, 'TOPRIGHT', 0, 0)
        end
        if AU.setups and AU.setups.characterBgTexture then
            AU.setups.characterBgTexture:ClearAllPoints()
            AU.setups.characterBgTexture:SetPoint('TOP', CharacterModelFrameRotateLeftButton, 'TOP', 0, 3)
            AU.setups.characterBgTexture:SetPoint('LEFT', CharacterBackSlot, 'RIGHT', 0, 0)
            AU.setups.characterBgTexture:SetPoint('RIGHT', CharacterFeetSlot, 'LEFT', 0, 0)
            AU.setups.characterBgTexture:SetPoint('BOTTOM', CharacterMainHandSlot, 'TOP', 0, 3)
        end
    end

    callbacks.questlogScale = function(value)
        local customBg = getglobal('AU_QuestLogCustomBg')
        if customBg then customBg:SetScale(value) end
        if QuestLogFrame then QuestLogFrame:SetScale(value) end
    end

    callbacks.socialScale = function(value)
        local customBg = getglobal('AU_FriendsCustomBg')
        if customBg then customBg:SetScale(value) end
        if FriendsFrame then FriendsFrame:SetScale(value) end
    end

    callbacks.helpScale = function(value)
        local customBg = getglobal('AU_HelpCustomBg')
        if customBg then customBg:SetScale(value) end
        if HelpFrame then HelpFrame:SetScale(value) end
    end

    callbacks.gamemenuScale = function(value)
        local frame = getglobal('AU_GameMenuFrame')
        if frame then frame:SetScale(value) end
    end

    callbacks.spellbookScale = function(value)
        local frame = getglobal('AU_SpellBookFrame')
        if frame then frame:SetScale(value) end
    end

    callbacks.talentsScale = function(value)
        local frame = getglobal('AU_TalentFrame')
        if frame then frame:SetScale(value) end
    end

    callbacks.keybindingScale = function(value)
        local customBg = getglobal('AU_KeyBindingCustomBg')
        if customBg then customBg:SetScale(value) end
        if KeyBindingFrame then KeyBindingFrame:SetScale(value) end
    end

    callbacks.macroScale = function(value)
        local customBg = getglobal('AU_MacroCustomBg')
        if customBg then customBg:SetScale(value) end
        if MacroFrame then MacroFrame:SetScale(value) end
    end

    AU:NewCallbacks('UIParent', callbacks)
end)
