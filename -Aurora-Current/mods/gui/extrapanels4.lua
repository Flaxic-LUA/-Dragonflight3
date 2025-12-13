UNLOCKAURORA()

-- Defaults gui structure: {tab = 'tabname', subtab = 'subtabname', 'category1', 'category2', ...}
-- Named keys (tab, subtab) define panel location, array elements define categories within that panel
-- Each category groups related settings with a header, settings use category + indexInCategory for ordering

AU:NewDefaults('gui-extrapanels4', {
    enabled = {value = true},
    version = {value = '1.0'},
    gui = {
        {tab = 'gui-extrapanels4', subtab = 'mainbar', categories = 'General'},
    },

    templateprint = {value = true, metadata = {element = 'checkbox', category = 'General', indexInCategory = 1, description = 'gui-extrapanels4 print description'}},



    -- examples:
    -- animationTexture = {value = 'Aura1', metadata = {element = 'dropdown', category = 'Animation', indexInCategory = 2, description = 'Animation texture style', options = {'Aura1', 'Aura2', 'Aura3', 'Aura4', 'Glow1', 'Glow2', 'Shock1', 'Shock2', 'Shock3'}, dependency = {key = 'minimapAnimation', state = true}}},
    -- customPlayerArrow = {value = true, metadata = {element = 'checkbox', category = 'Arrow', indexInCategory = 1, description = 'Use Dragonflight\'s custom player arrow', dependency = {key = 'showMinimap', state = true}}},
    -- playerArrowScale = {value = 1, metadata = {element = 'slider', category = 'Arrow', indexInCategory = 3, description = 'Size of the player arrow', min = 0.5, max = 2, stepSize = 0.1, dependency = {key = 'showMinimap', state = true}}},
    -- playerArrowColor = {value = {1, 1, 1}, metadata = {element = 'colorpicker', category = 'Arrow', indexInCategory = 4, description = 'Color of the player arrow', dependency = {key = 'customPlayerArrow', state = true}}},

})

AU:NewModule('gui-extrapanels4', 1, function()
    -- Aurora Module System Flow:
    -- ApplyDefaults() populates AU_GlobalDB[module][option] with default values from AU.defaults
    -- ExecModules() loads modules by calling each enabled module's func() based on priority
    -- Module's func() creates UI/features and calls NewCallbacks() as its last step
    -- NewCallbacks() registers callbacks and immediately executes them with current AU_GlobalDB values to initialize module state
    -- GUI changes trigger SetConfig() which updates AU_GlobalDB then re-executes the callback with new value
    local setup = AU.setups.guiBase
    if not setup then return end


    local devPanel = setup.panels['development']
    if not devPanel then return end

    local font = media[AU_GlobalDB['gui-generator'].guifont] or 'Fonts\\FRIZQT__.TTF'

    local title = devPanel:CreateFontString(nil, 'OVERLAY')
    title:SetFont(font, 18, 'OUTLINE')
    title:SetText('ALPHA BUILD WARNING')
    title:SetTextColor(1, 0, 0)
    title:SetPoint('TOP', devPanel, 'TOP', -55, -40)

    local subtitle = devPanel:CreateFontString(nil, 'OVERLAY')
    subtitle:SetFont(font, 14, 'OUTLINE')
    subtitle:SetText('This is an early development version')
    subtitle:SetTextColor(1, 0.5, 0)
    subtitle:SetPoint('TOP', title, 'BOTTOM', 0, -20)

    local line1 = devPanel:CreateFontString(nil, 'OVERLAY')
    line1:SetFont(font, 12)
    line1:SetText('Features are incomplete, buggy, or missing')
    line1:SetTextColor(1, 1, 1)
    line1:SetPoint('TOP', subtitle, 'BOTTOM', 0, -40)

    local line2 = devPanel:CreateFontString(nil, 'OVERLAY')
    line2:SetFont(font, 12)
    line2:SetText('Do NOT rely on everything working correctly')
    line2:SetTextColor(1, 1, 1)
    line2:SetPoint('TOP', line1, 'BOTTOM', 0, -10)

    local line3 = devPanel:CreateFontString(nil, 'OVERLAY')
    line3:SetFont(font, 12)
    line3:SetText('Settings may reset between updates')
    line3:SetTextColor(1, 1, 1)
    line3:SetPoint('TOP', line2, 'BOTTOM', 0, -10)

    local divider = AU.ui.Frame(devPanel, 400, 2, 0.5)
    divider:SetPoint('TOP', line3, 'BOTTOM', 0, -30)

    local bugTitle = devPanel:CreateFontString(nil, 'OVERLAY')
    bugTitle:SetFont(font, 14, 'OUTLINE')
    bugTitle:SetText('Found a Bug?')
    bugTitle:SetTextColor(1, 0.82, 0)
    bugTitle:SetPoint('TOP', divider, 'BOTTOM', 0, -30)

    local bug1 = devPanel:CreateFontString(nil, 'OVERLAY')
    bug1:SetFont(font, 11)
    bug1:SetText('Please report bugs with detailed reproduction steps')
    bug1:SetTextColor(0.8, 0.8, 0.8)
    bug1:SetPoint('TOP', bugTitle, 'BOTTOM', 0, -15)

    local bug2 = devPanel:CreateFontString(nil, 'OVERLAY')
    bug2:SetFont(font, 11)
    bug2:SetText('Include: What you did, what happened, what you expected')
    bug2:SetTextColor(0.8, 0.8, 0.8)
    bug2:SetPoint('TOP', bug1, 'BOTTOM', 0, -8)

    local bug3 = devPanel:CreateFontString(nil, 'OVERLAY')
    bug3:SetFont(font, 11)
    bug3:SetText('Screenshots and error messages are very helpful')
    bug3:SetTextColor(0.8, 0.8, 0.8)
    bug3:SetPoint('TOP', bug2, 'BOTTOM', 0, -8)

    local divider2 = AU.ui.Frame(devPanel, 400, 2, 0.5)
    divider2:SetPoint('TOP', bug3, 'BOTTOM', 0, -30)

    local thanks = devPanel:CreateFontString(nil, 'OVERLAY')
    thanks:SetFont(font, 13)
    thanks:SetText('Thank you for testing Aurora!')
    thanks:SetTextColor(0, 0.8, 1)
    thanks:SetPoint('TOP', divider2, 'BOTTOM', 0, -30)

    local footer = devPanel:CreateFontString(nil, 'OVERLAY')
    footer:SetFont(font, 10)
    footer:SetText('Your feedback helps make Aurora better')
    footer:SetTextColor(0.6, 0.6, 0.6)
    footer:SetPoint('TOP', thanks, 'BOTTOM', 0, -10)


    -- callbacks
    local callbacks = {}
    local callbackHelper = {definesomethinginheredirectly}

    callbacks.templateprint = function(value)
    end

    AU:NewCallbacks('gui-extrapanels4', callbacks)
end)
