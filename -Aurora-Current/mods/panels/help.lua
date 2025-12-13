UNLOCKAURORA()

AU:NewDefaults('help', {
    version = {value = '1.0'},
    enabled = {value = true},
    gui = {
        {indexRange = {1, 1}, tab = 'help', subtab = 1},
    },

    helpprint = {value = true, metadata = {element = 'checkbox', category = 'General', index = 1, description = 'help print description'}},




})

AU:NewModule('help', 1, function()
    local frame = AU.ui.CreatePaperDollFrame('AU_HelpFrame', UIParent, 600, 500, 2)
    frame:SetPoint('CENTER', 0, 0)
    frame:Hide()

    local closeButton = AU.ui.CreateRedButton(frame, 'close', function() frame:Hide() end)
    closeButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, -1)

    local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    title:SetText('Help')
    title:SetTextColor(1, 1, 1)
    title:SetPoint('TOP', frame, 'TOP', 0, -5)

    local contentFrame = CreateFrame('Frame', nil, frame)
    contentFrame:SetPoint('TOPLEFT', frame, 'TOPLEFT', 25, -65)
    contentFrame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -25, 10)

    local helpTitle = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    helpTitle:SetFont('Fonts\\FRIZQT__.TTF', 16, 'OUTLINE')
    helpTitle:SetPoint('TOPLEFT', contentFrame, 'TOPLEFT', 0, 0)
    helpTitle:SetWidth(550)
    helpTitle:SetJustifyH('LEFT')
    helpTitle:SetTextColor(1, 0.82, 0)
    helpTitle:SetText('Petition a Game Master')

    local text1 = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    text1:SetPoint('TOPLEFT', helpTitle, 'BOTTOMLEFT', 0, -3)
    text1:SetWidth(550)
    text1:SetJustifyH('LEFT')
    text1:SetTextColor(1, 1, 1)
    text1:SetText("Game Masters are normally available to assist 24 hours a day. Game Masters will be able to assist you no matter which character you are currently playing on.  Keep in mind that there are some issues that Game Masters will |cffffd200NOT|r be able to assist you with.  They include, but are |cffffd200NOT|r limited to the following:")

    local issue1Header = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    issue1Header:SetPoint('TOPLEFT', text1, 'BOTTOMLEFT', 10, -10)
    issue1Header:SetWidth(540)
    issue1Header:SetJustifyH('LEFT')
    issue1Header:SetTextColor(1, 0.82, 0)
    issue1Header:SetText('Game Hints')

    local issue1 = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    issue1:SetPoint('TOPLEFT', issue1Header, 'BOTTOMLEFT', 0, 0)
    issue1:SetWidth(540)
    issue1:SetJustifyH('LEFT')
    issue1:SetTextColor(1, 1, 1)
    issue1:SetText("When it comes to quests, Non-Player Characters (NPCs), item information, location information, or anything that would provide information about something that the player could possibly find out through exploration and/or interaction with the world, including interaction with other players.")

    local issue2Header = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    issue2Header:SetPoint('TOPLEFT', issue1, 'BOTTOMLEFT', 0, -10)
    issue2Header:SetWidth(540)
    issue2Header:SetJustifyH('LEFT')
    issue2Header:SetTextColor(1, 0.82, 0)
    issue2Header:SetText('Meta-Game Hints')

    local issue2 = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    issue2:SetPoint('TOPLEFT', issue2Header, 'BOTTOMLEFT', 0, 0)
    issue2:SetWidth(540)
    issue2:SetJustifyH('LEFT')
    issue2:SetTextColor(1, 1, 1)
    issue2:SetText("This includes information about:  an upcoming patch (what, when, how), upcoming content additions, game play changes, and future rule changes.")

    local issue3Header = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    issue3Header:SetPoint('TOPLEFT', issue2, 'BOTTOMLEFT', 0, -10)
    issue3Header:SetWidth(540)
    issue3Header:SetJustifyH('LEFT')
    issue3Header:SetTextColor(1, 0.82, 0)
    issue3Header:SetText('PvP')

    local issue3 = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    issue3:SetPoint('TOPLEFT', issue3Header, 'BOTTOMLEFT', 0, 0)
    issue3:SetWidth(540)
    issue3:SetJustifyH('LEFT')
    issue3:SetTextColor(1, 1, 1)
    issue3:SetText("Most PVP issues can be resolved through the PVP game mechanics. GM's will not be able to assist in many cases.  The exceptions to this rule are any behaviors that fall under the World of Warcraft Harassment Policy.  For special rules designated for PvP activity, please go to:")

    local pvpUrl = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    pvpUrl:SetPoint('TOP', issue3, 'BOTTOM', 0, -10)
    pvpUrl:SetWidth(550)
    pvpUrl:SetJustifyH('CENTER')
    pvpUrl:SetTextColor(1, 0.82, 0)
    pvpUrl:SetText('|cffffd200http://www.worldofwarcraft.com/policy/pvp.shtml|r')

    local text2 = contentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    text2:SetPoint('TOPLEFT', pvpUrl, 'BOTTOMLEFT', 0, -25)
    text2:SetWidth(550)
    text2:SetJustifyH('LEFT')
    text2:SetTextColor(1, 1, 1)
    text2:SetText("Additionally, we encourage all players to first utilize the forums and the website to pursue information about their respective issues at |cffffd200www.worldofwarcraft.com|r , and request that specific attention be paid to our game policies at |cffffd200www.worldofwarcraft.com/policy/|r .")

    local gmButton = AU.ui.Button(contentFrame, 'Issues that GMs can assist with', 250, 22)
    gmButton:SetPoint('TOP', text2, 'BOTTOM', 0, -40)

    frame.helpElements = {
        helpTitle = helpTitle,
        text1 = text1,
        issue1Header = issue1Header,
        issue1 = issue1,
        issue2Header = issue2Header,
        issue2 = issue2,
        issue3Header = issue3Header,
        issue3 = issue3,
        pvpUrl = pvpUrl,
        text2 = text2,
        gmButton = gmButton,
        contentFrame = contentFrame,
        frame = frame
    }

    table.insert(UISpecialFrames, frame:GetName())
    AU.common.KillFrame(HelpFrame)

    -- AU.mixin.ModifyHelpFrame(frame)

    frame:SetScript('OnShow', function()
        PlaySound('igCharacterInfoOpen')
        local btn = getglobal('AU_MicroButton_Help')
        if btn then btn:SetButtonState('PUSHED', 1) end
    end)
    frame:SetScript('OnHide', function()
        PlaySound('igCharacterInfoClose')
        local btn = getglobal('AU_MicroButton_Help')
        if btn then btn:SetButtonState('NORMAL') end
    end)

    _G.ToggleHelpFrame = function()
        local gameMenu = getglobal('AU_GameMenuFrame')
        if gameMenu and gameMenu:IsVisible() then
            return
        end
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
    -- callbacks
    local helpers = {}
    local callbacks = {}

    callbacks.helpprint = function(value)
        if value then
            -- print('help print from AU!')
        end
    end

    AU:NewCallbacks('help', callbacks)
end)
