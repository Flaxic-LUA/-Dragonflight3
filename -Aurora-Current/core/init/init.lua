UNLOCKAURORA()

local init = {eventGroups = {}, pendingEvents = {}}

AU.others.dbversion = 1

AU.others.blacklist = {
    'DragonflightReloaded',
    'MatrixMaps',
}

AU.others.blacklistFound = false

-- private
function init:DetectServer()
    local buildInfo = GetBuildInfo()
    local realmName = GetRealmName()
    if buildInfo > '1.12' and buildInfo < '2.0' then
        if realmName == 'Nordanaar' or realmName == 'Ambershire' or realmName == "Tel'Abim" then
            return 'turtle'
        end
    end
    return 'vanilla'
end

function init:ApplyDefaults(profileName)
    AU_GlobalDB.profiles[profileName] = AU_GlobalDB.profiles[profileName] or {}
    for module, defaults in pairs(AU.defaults) do
        AU_GlobalDB.profiles[profileName][module] = AU_GlobalDB.profiles[profileName][module] or {}
        for option, data in pairs(defaults) do
            if AU_GlobalDB.profiles[profileName][module][option] == nil then
                AU_GlobalDB.profiles[profileName][module][option] = data.value
            end
        end
    end
end

function init:LoadProfile(profileName)
    if not AU_GlobalDB.profiles[profileName] then return end
    for module, data in pairs(AU_GlobalDB.profiles[profileName]) do
        AU_GlobalDB[module] = data
    end
end

function init:CheckBlacklist()
    AU.others.blacklistedAddonsFound = {}
    for _, addonName in pairs(AU.others.blacklist) do
        if IsAddOnLoaded(addonName) then
            table.insert(AU.others.blacklistedAddonsFound, addonName)
            AU.ui.StaticPopup_Show(
                'Blacklisted addon detected: ' .. addonName .. '\n\nContinue loading Aurora?',
                'Continue',
                function()
                    init:ApplyDefaults()
                    if init:CheckVersions() then return end
                    init:ExecModules(true)
                end,
                'Cancel',
                function()
                end
            )
            return true
        end
    end
    return false
end

function init:CheckVersions()
    AU_GlobalDB.meta = AU_GlobalDB.meta or {}
    -- first run protection
    AU_GlobalDB.meta.dbversion = AU_GlobalDB.meta.dbversion or AU.others.dbversion

    local function ReloadModules()
        init:ApplyDefaults()
        for name, callback in pairs(AU.callbacks) do
            local mod, opt = AU.lua.match(name, '(.*)%.(.*)')
            callback(AU_GlobalDB[mod][opt])
        end
        init:ExecModules(true)
    end

    if AU_GlobalDB.meta.dbversion ~= AU.others.dbversion then
        AU.ui.StaticPopup_Show(
            'DB version mismatch.\n\nReset all settings?',
            'Reset',
            function()
                _G.AU_GlobalDB = {}
                _G.AU_GlobalDB.meta = {}
                _G.AU_GlobalDB.meta.dbversion = AU.others.dbversion
                ReloadModules()
            end,
            'Cancel',
            function()
            end
        )
        return true
    end

    local mismatchModules = {}
    for module, defaults in pairs(AU.defaults) do
        if defaults.version then
            local expected = defaults.version.value
            if not AU_GlobalDB[module] or not AU_GlobalDB[module].version or AU_GlobalDB[module].version ~= expected then
                table.insert(mismatchModules, module)
            end
        end
    end

    if table.getn(mismatchModules) > 0 then
        local msg = 'Module version mismatch:\n'
        for _, mod in pairs(mismatchModules) do
            msg = msg .. '- ' .. mod .. '\n'
        end
        msg = msg .. '\nReset all?'

        AU.ui.StaticPopup_Show(msg,
            'Reset',
            function()
                for _, mod in pairs(mismatchModules) do
                    AU_GlobalDB[mod] = {}
                end
                ReloadModules()
            end,
            'Cancel',
            function()
            end
        )
        return true
    end

    return false
end

function init:Finalize()
    AU:UnregisterAllEvents()
    init.pendingEvents = {}
end

function init:ExecModules(forceImmediate)
    local sorted = {}
    for name, module in pairs(AU.modules) do
        if AU_GlobalDB[name].enabled then
            table.insert(sorted, {name=name, module=module})
        end
    end
    table.sort(sorted, function(a, b) return a.module.priority < b.module.priority end)

    if forceImmediate then
        for _, entry in pairs(sorted) do
            entry.module.func()
        end
        init:Finalize()
        return
    end

    for _, entry in pairs(sorted) do
        local module = entry.module
        if module.event then
            init.eventGroups[module.event] = init.eventGroups[module.event] or {}
            table.insert(init.eventGroups[module.event], {name=entry.name, func=module.func})
            init.pendingEvents[module.event] = true
        else
            module.func()
        end
    end

    for event, _ in pairs(init.eventGroups) do
        AU:RegisterEvent(event)
    end

    if not next(init.pendingEvents) then
        init:Finalize()
    end
end

function init:InitAU()
    AU.others.server = init:DetectServer()

    local charName = UnitName('player')
    local realmName = GetRealmName()
    local charKey = charName .. '-' .. realmName

    AU_GlobalDB.meta = AU_GlobalDB.meta or {}
    AU_GlobalDB.profiles = AU_GlobalDB.profiles or {}
    AU_GlobalDB.meta.characterProfiles = AU_GlobalDB.meta.characterProfiles or {}

    if init:CheckBlacklist() then return end

    local profileName = AU_GlobalDB.meta.characterProfiles[charKey] or charKey
    if not AU_GlobalDB.profiles[profileName] then
        init:ApplyDefaults(profileName)
        AU_GlobalDB.meta.characterProfiles[charKey] = profileName
    end

    init:LoadProfile(profileName)
    AU_GlobalDB.meta.activeProfile = profileName
    AU.others.currentProfile = profileName

    if init:CheckVersions() then return end
    init:ExecModules(false)
end

-- public
function AU:NewDefaults(module, defaults)
    AU.defaults[module] = defaults
end

function AU:NewModule(module, priority, event, func)
    assert(module, 'Module name required')
    assert(priority, 'Priority required')
    assert(event, 'Event or function required')

    -- if func is passed, its an event module
    if func then
        AU.modules[module] = {priority=priority, event=event, func=func}
    -- else its a normal module
    else
        AU.modules[module] = {priority=priority, func=event}
    end
end

function AU:NewCallbacks(module, callbacks)
    for option, callback in pairs(callbacks) do
        AU.callbacks[module .. '.' .. option] = callback
        -- trigger all callbacks with current value
        if AU_GlobalDB[module] and AU_GlobalDB[module][option] ~= nil then
            callback(AU_GlobalDB[module][option])
        end
    end
end

function AU:SetConfig(module, option, value)
    AU_GlobalDB[module][option] = value
    if AU.others.currentProfile then
        AU_GlobalDB.profiles[AU.others.currentProfile][module][option] = value
    end
    AU.callbacks[module .. '.' .. option](value)
end

function AU:CreateProfile(name)
    AU_GlobalDB.profiles = AU_GlobalDB.profiles or {}
    AU_GlobalDB.profiles[name] = {}
    for module, defaults in pairs(AU.defaults) do
        AU_GlobalDB.profiles[name][module] = {}
        for option, data in pairs(defaults) do
            AU_GlobalDB.profiles[name][module][option] = data.value
        end
    end
    AU_GlobalDB.meta = AU_GlobalDB.meta or {}
    AU_GlobalDB.meta.profileMeta = AU_GlobalDB.meta.profileMeta or {}
    AU_GlobalDB.meta.profileMeta[name] = {
        created = date('%Y-%m-%d %H:%M'),
        modified = date('%Y-%m-%d %H:%M'),
        description = ''
    }
end

function AU:DeleteProfile(name)
    AU_GlobalDB.profiles = AU_GlobalDB.profiles or {}
    AU_GlobalDB.profiles[name] = nil
end

function AU:SwitchProfile(name)
    AU_GlobalDB.profiles = AU_GlobalDB.profiles or {}

    for module, data in pairs(AU_GlobalDB.profiles[name]) do
        AU_GlobalDB[module] = data
    end

    AU_GlobalDB.meta = AU_GlobalDB.meta or {}
    AU_GlobalDB.meta.activeProfile = name
    AU.others.currentProfile = name

    for callbackName, callback in pairs(AU.callbacks) do
        local mod, opt = AU.lua.match(callbackName, '(.*)%.(.*)')
        if AU_GlobalDB[mod] and AU_GlobalDB[mod][opt] ~= nil then
            callback(AU_GlobalDB[mod][opt])
        end
    end
end

-- updates/events
AU:RegisterEvent'VARIABLES_LOADED'
AU:SetScript('OnEvent', function()
    if event == 'VARIABLES_LOADED' then
        init:InitAU()
        print('Welcome to '.. info.addonNameColor .. ', use /au help for more.')
        return
    end

    local modules = init.eventGroups[event]
    if modules then
        for _, module in pairs(modules) do
            module.func()
        end
        AU:UnregisterEvent(event)
        init.pendingEvents[event] = nil
        if not next(init.pendingEvents) then
            init:Finalize()
        end
    end
end)
