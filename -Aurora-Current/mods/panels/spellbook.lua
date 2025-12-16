UNLOCKAURORA()

AU:NewDefaults('spellbook', {
    version = {value = '1.0'},
    enabled = {value = true},
    gui = {
        {indexRange = {1, 1}, tab = 'spellbook', subtab = 1},
    },

})

AU:NewModule('spellbook', 1, 'PLAYER_ENTERING_WORLD', function()
    AU.common.KillFrame(SpellBookFrame)

    local BUTTONS_PER_PAGE = 36
    local COLUMN_SPACING = 110
    local ROW_SPACING = 65

    local spellData = {}

    local spellbook = AU.ui.CreatePaperDollFrame("AU_SpellBookFrame", UIParent, 750, 530, 1)
    spellbook:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    spellbook:SetFrameStrata('MEDIUM')
    spellbook:SetFrameLevel(25)
    spellbook:EnableMouse(true)
    spellbook:SetScale(.9)
    AU.setups.spellbookBg = spellbook.Bg

    local leftPage = spellbook:CreateTexture(nil, "ARTWORK")
    leftPage:SetTexture(media['tex:panels:spellbook_right_page.blp'])
    leftPage:SetPoint("TOPLEFT", spellbook, "TOPLEFT", 10, -60)
    leftPage:SetPoint("BOTTOM", spellbook, "BOTTOM", -5, 10)
    leftPage:SetWidth(365)

    local rightPage = spellbook:CreateTexture(nil, "ARTWORK")
    rightPage:SetTexture(media['tex:panels:spellbook_left_page.blp'])
    rightPage:SetPoint("TOPRIGHT", spellbook, "TOPRIGHT", -10, -60)
    rightPage:SetPoint("BOTTOM", spellbook, "BOTTOM", 5, 10)
    rightPage:SetWidth(365)

    local topWood = spellbook:CreateTexture(nil, "BORDER")
    topWood:SetTexture(media['tex:panels:spellbook_top_wood.blp'])
    topWood:SetPoint("TOP", spellbook, "TOP", 0, -20)
    topWood:SetWidth(730)
    topWood:SetHeight(64)

    local classIcon = spellbook:CreateTexture(nil, "ARTWORK")
    classIcon:SetTexture(media['tex:interface:UI-Classes-Circles.tga'])
    local _, playerClass = UnitClass("player")
    local coords = AU.tables["classicons"][playerClass]
    if coords then
        classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    end
    classIcon:SetPoint("TOPLEFT", spellbook, "TOPLEFT", 0, 3)
    classIcon:SetWidth(52)
    classIcon:SetHeight(52)

    local title = spellbook:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetText("Spellbook")
    title:SetTextColor(1, 1, 1)
    title:SetPoint("TOP", spellbook, "TOP", 0, -6)

    local closeBtn = AU.ui.CreateRedButton(spellbook, "close", function() spellbook:Hide() end)
    closeBtn:SetPoint("TOPRIGHT", spellbook, "TOPRIGHT", 0, -1)

    spellbook:SetScript("OnShow", function()
        PlaySound("igSpellBookOpen")
        local btn = getglobal('AU_MicroButton_Spellbook')
        if btn then btn:SetButtonState('PUSHED', 1) end
    end)
    spellbook:SetScript("OnHide", function()
        PlaySound("igSpellBookClose")
        local btn = getglobal('AU_MicroButton_Spellbook')
        if btn then btn:SetButtonState('NORMAL') end
    end)

    local showPassiveCheckbox = AU.ui.Checkbox(spellbook, "Show Passive", 15, 15)
    showPassiveCheckbox:SetPoint("TOPRIGHT", spellbook, "TOPRIGHT", -30, -35)
    showPassiveCheckbox:SetChecked(true)
    showPassiveCheckbox:SetScript("OnClick", function()
        spellbook.currentPage = 1
        spellbook:UpdateSpellDisplay()
    end)

    local showRanksCheckbox = AU.ui.Checkbox(spellbook, "Show Spell Ranks", 15, 15)
    showRanksCheckbox:SetPoint("RIGHT", showPassiveCheckbox, "LEFT", -120, 0)
    showRanksCheckbox:SetChecked(false)
    showRanksCheckbox:SetScript("OnClick", function()
        spellbook.currentPage = 1
        spellbook:UpdateSpellDisplay()
    end)

    local bookmark = spellbook:CreateTexture(nil, "OVERLAY")
    bookmark:SetTexture(media['tex:panels:spellbook_bookmark.blp'])
    bookmark:SetPoint("TOPRIGHT", leftPage, "TOPRIGHT", 45, 0)
    bookmark:SetWidth(50)
    bookmark:SetHeight(512)

    AU.setups.spellbookLeftPage = leftPage
    AU.setups.spellbookRightPage = rightPage
    AU.setups.spellbookTopWood = topWood
    AU.setups.spellbookBookmark = bookmark

    spellbook.selectedTabIndex = 1
    spellbook.currentPage = 1
    spellbook.maxPages = 1
    spellbook.spellButtons = {}

    function spellbook:CollectSpells(tabIndex)
        spellData = {}
        if tabIndex then
            local name, texture, offset, numSpells = GetSpellTabInfo(tabIndex)
            for i = 1, numSpells do
                local spellIndex = offset + i
                local spellName, spellRank = GetSpellName(spellIndex, BOOKTYPE_SPELL)
                if spellName then
                    local variant = nil
                    local cleanName = spellName
                    local variantStart, variantEnd = string.find(spellName, "%((.-)%)")
                    if variantStart then
                        variant = string.sub(spellName, variantStart + 1, variantEnd - 1)
                        cleanName = string.sub(spellName, 1, variantStart - 2)
                    end
                    local variantRank = 3
                    if variant == "Minor" then
                        variantRank = 1
                    elseif variant == "Lesser" then
                        variantRank = 2
                    elseif variant == "Greater" then
                        variantRank = 4
                    elseif variant == "Major" then
                        variantRank = 5
                    end
                    local isRacial = spellRank and string.find(spellRank, "Racial")
                    table.insert(spellData, {
                        index = spellIndex,
                        name = cleanName,
                        rank = spellRank,
                        variant = variant,
                        variantRank = variantRank,
                        texture = GetSpellTexture(spellIndex, BOOKTYPE_SPELL),
                        isPassive = IsSpellPassive(spellIndex, BOOKTYPE_SPELL),
                        isRacial = isRacial,
                        tabIndex = tabIndex
                    })
                end
            end
        end
    end

    function spellbook:CreateSpellButton(parent)
        local container = CreateFrame("Frame", nil, parent)
        container:SetWidth(120)
        container:SetHeight(40)

        local iconBtn = CreateFrame("Button", nil, container)
        iconBtn:SetWidth(32)
        iconBtn:SetHeight(32)
        iconBtn:SetPoint("LEFT", container, "LEFT", 5, 0)
        container.iconBtn = iconBtn

        iconBtn.cooldown = CreateFrame('Model', nil, iconBtn, 'CooldownFrameTemplate')
        iconBtn.cooldown:SetAllPoints(iconBtn)

        local icon = iconBtn:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints(iconBtn)
        container.icon = icon

        local border = iconBtn:CreateTexture(nil, "ARTWORK")
        border:SetWidth(43)
        border:SetHeight(43)
        border:SetPoint("CENTER", iconBtn, "CENTER", -3, -2)
        container.border = border

        local highlight = iconBtn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetTexture(media['tex:panels:spellbook_highlight.blp'])
        highlight:SetWidth(43)
        highlight:SetHeight(43)
        highlight:SetPoint("CENTER", iconBtn, "CENTER", 0, 0)
        highlight:SetBlendMode("ADD")
        container.highlight = highlight

        local maxRankHighlight = iconBtn:CreateTexture(nil, "OVERLAY")
        maxRankHighlight:SetTexture(media['tex:panels:spellbook_highlight.blp'])
        maxRankHighlight:SetWidth(53)
        maxRankHighlight:SetHeight(53)
        maxRankHighlight:SetPoint("CENTER", iconBtn, "CENTER", 0, 0)
        maxRankHighlight:SetBlendMode("ADD")
        maxRankHighlight:SetAlpha(.3)
        maxRankHighlight:Hide()
        container.maxRankHighlight = maxRankHighlight

        local name = container:CreateFontString(nil, "OVERLAY")
        name:SetFont("Fonts\\FRIZQT__.TTF", 10)
        name:SetPoint("LEFT", iconBtn, "RIGHT", 5, 0)
        name:SetPoint("RIGHT", container, "RIGHT", -5, 0)
        name:SetJustifyH("LEFT")
        name:SetTextColor(0, 0, 0)
        container.name = name

        local passive = container:CreateFontString(nil, "OVERLAY")
        passive:SetFont("Fonts\\FRIZQT__.TTF", 8)
        passive:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, 0)
        passive:SetText("Passive")
        passive:SetTextColor(0.2, 0.2, 0.2)
        passive:Hide()
        container.passive = passive

        local racial = container:CreateFontString(nil, "OVERLAY")
        racial:SetFont("Fonts\\FRIZQT__.TTF", 8)
        racial:SetText("Racial")
        racial:SetTextColor(0.2, 0.2, 0.2)
        racial:Hide()
        container.racial = racial

        local rank = container:CreateFontString(nil, "OVERLAY")
        rank:SetFont("Fonts\\FRIZQT__.TTF", 8)
        rank:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, 0)
        rank:SetTextColor(0.2, 0.2, 0.2)
        rank:Hide()
        container.rank = rank

        iconBtn:SetScript("OnClick", function()
            if container.spellIndex then
                CastSpell(container.spellIndex, BOOKTYPE_SPELL)
            end
        end)

        iconBtn:SetScript("OnDragStart", function()
            if container.spellIndex then
                PickupSpell(container.spellIndex, BOOKTYPE_SPELL)
            end
        end)

        iconBtn:SetScript("OnEnter", function()
            if container.spellIndex then
                GameTooltip:SetOwner(iconBtn, 'ANCHOR_RIGHT')
                GameTooltip:SetSpell(container.spellIndex, BOOKTYPE_SPELL)
                GameTooltip:Show()
            end
        end)

        iconBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        iconBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        iconBtn:RegisterForDrag("LeftButton")

        return container
    end

    for i = 1, BUTTONS_PER_PAGE do
        local btn = spellbook:CreateSpellButton(spellbook)

        if i <= 18 then
            local leftRow = math.floor((i - 1) / 3)
            local leftCol = math.mod(i - 1, 3)
            btn:SetPoint("TOPLEFT", leftPage, "TOPLEFT", 15 + leftCol * COLUMN_SPACING, -35 - leftRow * ROW_SPACING)
        else
            local rightRow = math.floor((i - 19) / 3)
            local rightCol = math.mod(i - 19, 3)
            btn:SetPoint("TOPLEFT", rightPage, "TOPLEFT", 15 + rightCol * COLUMN_SPACING, -35 - rightRow * ROW_SPACING)
        end

        -- debugframe(btn)

        table.insert(spellbook.spellButtons, btn)
    end

    local pageText = AU.ui.Font(spellbook, 11, nil, {1, .82, 0}, 'RIGHT', 'NONE')
    pageText:SetPoint("BOTTOMRIGHT", rightPage, "BOTTOMRIGHT", -100, 18)
    spellbook.pageText = pageText

    local prevBtn, nextBtn

    function spellbook:UpdateSpellDisplay()
        spellbook:CollectSpells(spellbook.selectedTabIndex)

        local filteredSpells = {}
        for i, spell in ipairs(spellData) do
            if showPassiveCheckbox:GetChecked() or not spell.isPassive then
                table.insert(filteredSpells, spell)
            end
        end

        local maxRanks = {}
        for i, spell in ipairs(filteredSpells) do
            if not maxRanks[spell.name] or spell.variantRank > maxRanks[spell.name].variantRank or (spell.variantRank == maxRanks[spell.name].variantRank and spell.index > maxRanks[spell.name].index) then
                maxRanks[spell.name] = spell
            end
        end

        if not showRanksCheckbox:GetChecked() then
            filteredSpells = {}
            for name, spell in pairs(maxRanks) do
                table.insert(filteredSpells, spell)
            end
            table.sort(filteredSpells, function(a, b) return a.index < b.index end)
        end

        spellbook.maxPages = math.ceil(table.getn(filteredSpells) / 36)
        if spellbook.maxPages < 1 then spellbook.maxPages = 1 end

        local startIndex = (spellbook.currentPage - 1) * 36 + 1
        for i, btn in ipairs(spellbook.spellButtons) do
            local spell = filteredSpells[startIndex + i - 1]
            if spell then
                btn.icon:SetTexture(spell.texture)
                btn.name:SetText(spell.name)
                btn.spellIndex = spell.index

                local start, duration, enable = GetSpellCooldown(spell.index, BOOKTYPE_SPELL)
                if btn.iconBtn.cooldown and start and duration then
                    CooldownFrame_SetTimer(btn.iconBtn.cooldown, start, duration, enable)
                end
                local lastAnchor = btn.name
                if spell.isPassive then
                    btn.passive:Show()
                    lastAnchor = btn.passive
                    btn.border:SetTexture(media['tex:panels:spellbook_passives_border.blp'])
                else
                    btn.passive:Hide()
                    btn.border:SetTexture(media['tex:panels:spellbook_actives_border.blp'])
                end
                if spell.isRacial then
                    btn.racial:ClearAllPoints()
                    btn.racial:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, 0)
                    btn.racial:Show()
                    lastAnchor = btn.racial
                else
                    btn.racial:Hide()
                end
                btn.rank:ClearAllPoints()
                btn.rank:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, 0)
                if spell.variant then
                    btn.rank:SetText(spell.variant)
                    btn.rank:Show()
                elseif spell.rank and spell.rank ~= "" and spell.rank ~= "Passive" and spell.rank ~= "Racial" and spell.rank ~= "Racial Passive" then
                    btn.rank:SetText(spell.rank)
                    btn.rank:Show()
                else
                    btn.rank:Hide()
                end
                local tabName = GetSpellTabInfo(spellbook.selectedTabIndex)
                local isGeneralTab = tabName and string.find(tabName, "General")
                if showRanksCheckbox:GetChecked() and maxRanks[spell.name] and maxRanks[spell.name].index == spell.index and not isGeneralTab then
                    btn.maxRankHighlight:Show()
                else
                    btn.maxRankHighlight:Hide()
                end
                btn:Show()
            else
                btn:Hide()
            end
        end

        pageText:SetText("Page "..spellbook.currentPage.." / "..spellbook.maxPages)

        if spellbook.currentPage <= 1 then
            prevBtn:Disable()
        else
            prevBtn:Enable()
        end

        if spellbook.currentPage >= spellbook.maxPages then
            nextBtn:Disable()
        else
            nextBtn:Enable()
        end
    end

    function spellbook:CreateDynamicTabs()
        for i, tab in ipairs(spellbook.Tabs) do
            tab:Hide()
        end
        spellbook.Tabs = {}

        local numTabs = GetNumSpellTabs()
        for tabIndex = 1, numTabs do
            local name, texture, offset, numSpells = GetSpellTabInfo(tabIndex)
            if numSpells > 0 then
                local capturedIndex = tabIndex
                spellbook:AddTab(name, function()
                    spellbook.selectedTabIndex = capturedIndex
                    spellbook.currentPage = 1
                    spellbook:UpdateSpellDisplay()
                end, 80)
            end
        end

        if spellbook.Tabs[1] then
            spellbook.Tabs[1]:SetSelected(true)
            spellbook.selectedTab = spellbook.Tabs[1]
            spellbook.selectedTabIndex = 1
        end
    end

    prevBtn = AU.ui.PageButton(spellbook, 27, 27, nil, 'west')
    prevBtn:SetPoint("BOTTOMRIGHT", rightPage, "BOTTOMRIGHT", -60, 10)
    prevBtn:SetScript("OnClick", function()
        if spellbook.currentPage > 1 then
            spellbook.currentPage = spellbook.currentPage - 1
            spellbook:UpdateSpellDisplay()
        end
    end)

    nextBtn = AU.ui.PageButton(spellbook, 27, 27, nil, 'east')
    nextBtn:SetPoint("BOTTOMRIGHT", rightPage, "BOTTOMRIGHT", -20, 10)
    nextBtn:SetScript("OnClick", function()
        if spellbook.currentPage < spellbook.maxPages then
            spellbook.currentPage = spellbook.currentPage + 1
            spellbook:UpdateSpellDisplay()
        end
    end)

    spellbook:CreateDynamicTabs()
    spellbook:UpdateSpellDisplay()
    spellbook:Hide()

    spellbook:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    spellbook:SetScript('OnEvent', function()
        if event == 'SPELL_UPDATE_COOLDOWN' then
            for i, btn in ipairs(spellbook.spellButtons) do
                if btn.spellIndex and btn:IsShown() then
                    local start, duration, enable = GetSpellCooldown(btn.spellIndex, BOOKTYPE_SPELL)
                    if btn.iconBtn.cooldown then
                        CooldownFrame_SetTimer(btn.iconBtn.cooldown, start, duration, enable)
                    end
                end
            end
        end
    end)

    _G.ToggleSpellBook = function(bookType)
        local gameMenu = getglobal('AU_GameMenuFrame')
        if gameMenu and gameMenu:IsVisible() then
            return
        end
        if spellbook:IsShown() then
            spellbook:Hide()
        else
            spellbook:Show()
        end
    end

    table.insert(UISpecialFrames, spellbook:GetName())

    -- callbacks
    local helpers = {}
    local callbacks = {}


    AU:NewCallbacks('spellbook', callbacks)
end)
