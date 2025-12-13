UNLOCKAURORA()

-- credit to shagu v1.0
if AU.lib.libcast then return end

local scanner = AU.lib.libtipscan:GetScanner('libcast')
local libspell = AU.lib.libspell
local libcast = {}
local player = UnitName('player')
local lastcasttex, lastrank
local cmatch = AU.lua.cmatch
local aimedshot = AU.tables['customcast']['AIMEDSHOT']
local multishot = AU.tables['customcast']['MULTISHOT']
local castframe = CreateFrame('Frame')

local validUnits = {}
validUnits['pet'] = true
validUnits['player'] = true
validUnits['target'] = true
validUnits['mouseover'] = true
validUnits['pettarget'] = true
validUnits['playertarget'] = true
validUnits['targettarget'] = true
validUnits['mouseovertarget'] = true
validUnits['targettargettarget'] = true
for i=1,4 do validUnits['party' .. i] = true end
for i=1,4 do validUnits['partypet' .. i] = true end
for i=1,40 do validUnits['raid' .. i] = true end
for i=1,40 do validUnits['raidpet' .. i] = true end
for i=1,4 do validUnits['party' .. i .. 'target'] = true end
for i=1,4 do validUnits['partypet' .. i .. 'target'] = true end
for i=1,40 do validUnits['raid' .. i .. 'target'] = true end
for i=1,40 do validUnits['raidpet' .. i .. 'target'] = true end
local events = {
    'CHAT_MSG_SPELL_SELF_DAMAGE', 'CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE',
    'CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF', 'CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE',
    'CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF', 'CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS',
    'CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS', 'CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE',
    'CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE', 'CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE',
    'CHAT_MSG_SPELL_PARTY_DAMAGE', 'CHAT_MSG_SPELL_PARTY_BUFF',
    'CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE', 'CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS',
    'CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE', 'CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS',
    'CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE', 'CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF',
    'SPELLCAST_START', 'SPELLCAST_STOP', 'SPELLCAST_FAILED', 'SPELLCAST_INTERRUPTED',
    'SPELLCAST_DELAYED', 'SPELLCAST_CHANNEL_START', 'SPELLCAST_CHANNEL_STOP', 'SPELLCAST_CHANNEL_UPDATE'
}

libcast.db = {[player] = {}}

UnitChannelInfo = function(unit)
    if not unit then return end
    unit = validUnits[unit] and UnitName(unit) or unit
    local db = libcast.db[unit]
    if db and db.cast and db.start + db.casttime / 1000 > GetTime() then
        if not db.channel then return end
        return db.cast, db.rank, '', db.icon, db.start * 1000, db.start * 1000 + db.casttime, nil
    elseif db then
        db.cast, db.rank, db.start, db.casttime, db.icon, db.channel = nil, nil, nil, nil, nil, nil
    end
end

UnitCastingInfo = function(unit)
    if not unit then return end
    unit = validUnits[unit] and UnitName(unit) or unit
    local db = libcast.db[unit]
    if db and db.cast and db.start + db.casttime / 1000 > GetTime() then
        if db.channel then return end
        return db.cast, db.rank or '', '', db.icon, db.start * 1000, db.start * 1000 + db.casttime, nil
    elseif db then
        db.cast, db.rank, db.start, db.casttime, db.icon, db.channel = nil, nil, nil, nil, nil, nil
    end
end

function libcast:GetChannelInfo(unit)
    if not unit then return end
    unit = validUnits[unit] and UnitName(unit) or unit
    local db = self.db[unit]
    if db and db.cast and db.start + db.casttime / 1000 > GetTime() then
        if not db.channel then return end
        return db.cast, db.rank, '', db.icon, db.start * 1000, db.start * 1000 + db.casttime, nil
    elseif db then
        db.cast, db.rank, db.start, db.casttime, db.icon, db.channel = nil, nil, nil, nil, nil, nil
    end
end

function libcast:GetCastingInfo(unit)
    if not unit then return end
    unit = validUnits[unit] and UnitName(unit) or unit
    local db = self.db[unit]
    if db and db.cast and db.start + db.casttime / 1000 > GetTime() then
        if db.channel then return end
        return db.cast, db.rank or '', '', db.icon, db.start * 1000, db.start * 1000 + db.casttime, nil
    elseif db then
        db.cast, db.rank, db.start, db.casttime, db.icon, db.channel = nil, nil, nil, nil, nil, nil
    end
end

function libcast:AddAction(mob, spell, channel)
    if not mob or not spell then return end
    spell = string.gsub(spell, '%.$', '')
    local spelldata = AU.tables['spells'][spell]
    -- debugprint('ADD: mob=' .. mob .. ' spell=' .. spell .. ' hasData=' .. tostring(spelldata ~= nil))
    if spelldata then
        if not self.db[mob] then self.db[mob] = {} end
        self.db[mob].cast = spell
        self.db[mob].rank = nil
        self.db[mob].start = GetTime()
        self.db[mob].casttime = spelldata.t
        self.db[mob].icon = spelldata.icon and 'Interface\\Icons\\' .. spelldata.icon or nil
        self.db[mob].channel = channel
        -- debugprint('ADDED TO DB: ' .. mob .. ' casting ' .. spell)
        return true
    end
end

function libcast:RemoveAction(mob, spell)
    if self.db[mob] and (AU.tables['interrupts'][spell] or spell == 'INTERRUPT') then
        self.db[mob].cast, self.db[mob].rank, self.db[mob].start = nil, nil, nil
        self.db[mob].casttime, self.db[mob].icon, self.db[mob].channel = nil, nil, nil
    end
end

for _, e in ipairs(events) do castframe:RegisterEvent(e) end

castframe:SetScript('OnEvent', function()
    if event == 'SPELLCAST_START' then
        local icon = AU.tables['spells'][arg1] and AU.tables['spells'][arg1].icon and 'Interface\\Icons\\' .. AU.tables['spells'][arg1].icon or lastcasttex
        libcast.db[player].cast, libcast.db[player].rank = arg1, lastrank
        libcast.db[player].start, libcast.db[player].casttime = GetTime(), arg2
        libcast.db[player].icon, libcast.db[player].channel = icon, nil
        if not AU.tables['spells'][arg1] or not AU.tables['spells'][arg1].icon or not AU.tables['spells'][arg1].t then
            AU.tables['spells'][arg1] = AU.tables['spells'][arg1] or {}
            AU.tables['spells'][arg1].icon = AU.tables['spells'][arg1].icon or icon
            AU.tables['spells'][arg1].t = AU.tables['spells'][arg1].t or arg2
        end
        lastcasttex = nil
    elseif event == 'SPELLCAST_STOP' or event == 'SPELLCAST_FAILED' or event == 'SPELLCAST_INTERRUPTED' then
        lastrank = nil
        if libcast.db[player] and not libcast.db[player].channel then
            libcast.db[player].cast, libcast.db[player].rank, libcast.db[player].start = nil, nil, nil
            libcast.db[player].casttime, libcast.db[player].icon, libcast.db[player].channel = nil, nil, nil
        end
    elseif event == 'SPELLCAST_DELAYED' then
        if libcast.db[player].cast then
            libcast.db[player].start = libcast.db[player].start + arg1 / 1000
        end
    elseif event == 'SPELLCAST_CHANNEL_START' then
        local icon = AU.tables['spells'][arg2] and AU.tables['spells'][arg2].icon and 'Interface\\Icons\\' .. AU.tables['spells'][arg2].icon or lastcasttex
        libcast.db[player].cast, libcast.db[player].rank = arg2, lastrank
        libcast.db[player].start, libcast.db[player].casttime = GetTime(), arg1
        libcast.db[player].icon, libcast.db[player].channel = icon, true
        lastcasttex = nil
    elseif event == 'SPELLCAST_CHANNEL_STOP' then
        lastrank = nil
        if libcast.db[player] and libcast.db[player].channel then
            libcast.db[player].cast, libcast.db[player].rank, libcast.db[player].start = nil, nil, nil
            libcast.db[player].casttime, libcast.db[player].icon, libcast.db[player].channel = nil, nil, nil
        end
    elseif event == 'SPELLCAST_CHANNEL_UPDATE' then
        if libcast.db[player].cast then
            libcast.db[player].start = -libcast.db[player].casttime / 1000 + GetTime() + arg1 / 1000
        end
    elseif arg1 then
        if string.find(arg1, 'begins to cast') or string.find(arg1, 'begins to perform') then
            -- debugprint('CAST EVENT: ' .. arg1)
            -- debugprint('PATTERN: ' .. (SPELLCASTOTHERSTART or 'nil'))
            local _, _, testmob, testspell = string.find(arg1 .. '.', '(.+) begins to cast (.+)%.')
            -- debugprint('DIRECT FIND: mob=' .. (testmob or 'nil') .. ' spell=' .. (testspell or 'nil'))
        end
        local mob, spell
        local castPattern = string.gsub(SPELLCASTOTHERSTART, '%%s', '(.+)')
        local performPattern = string.gsub(SPELLPERFORMOTHERSTART, '%%s', '(.+)')
        mob, spell = cmatch(arg1 .. '.', castPattern)
        if libcast:AddAction(mob, spell) then return end
        mob, spell = cmatch(arg1 .. '.', performPattern)
        if libcast:AddAction(mob, spell) then return end
        mob, spell = cmatch(arg1, AURAADDEDOTHERHELPFUL)
        if libcast:RemoveAction(mob, spell) then return end
        mob, spell = cmatch(arg1, AURAADDEDOTHERHARMFUL)
        if libcast:RemoveAction(mob, spell) then return end
        spell, mob = cmatch(arg1, SPELLLOGSELFOTHER)
        if libcast:RemoveAction(mob, spell) then return end
        spell, mob = cmatch(arg1, SPELLLOGCRITSELFOTHER)
        if libcast:RemoveAction(mob, spell) then return end
        _, spell, mob = cmatch(arg1, SPELLLOGOTHEROTHER)
        if libcast:RemoveAction(mob, spell) then return end
        _, spell, mob = cmatch(arg1, SPELLLOGCRITOTHEROTHER)
        if libcast:RemoveAction(mob, spell) then return end
        mob, _ = cmatch(arg1, SPELLINTERRUPTSELFOTHER)
        if libcast:RemoveAction(mob, 'INTERRUPT') then return end
        _, mob, _ = cmatch(arg1, SPELLINTERRUPTOTHEROTHER)
        if libcast:RemoveAction(mob, 'INTERRUPT') then return end
    end
end)

libcast.customcast = {}

libcast.customcast[string.lower(aimedshot)] = function(begin, duration)
    if begin then
        duration = duration or 3000
        for i = 1, 32 do
            local buff = UnitBuff('player', i)
            if buff == 'Interface\\Icons\\Racial_Troll_Berserk' then
                local berserk = (UnitHealth('player') / UnitHealthMax('player')) >= 0.40 and (1.30 - (UnitHealth('player') / UnitHealthMax('player'))) / 3 or 0.3
                duration = duration / (1 + berserk)
            elseif buff == 'Interface\\Icons\\Ability_Hunter_RunningShot' then
                duration = duration / 1.4
            elseif buff == 'Interface\\Icons\\Ability_Warrior_InnerRage' then
                duration = duration / 1.3
            elseif buff == 'Interface\\Icons\\Inv_Trinket_Naxxramas04' then
                duration = duration / 1.2
            end
        end
        local _, _, lag = GetNetStats()
        libcast.db[player].cast, libcast.db[player].rank = aimedshot, lastrank
        libcast.db[player].start, libcast.db[player].casttime = GetTime() + lag / 1000, duration
        libcast.db[player].icon, libcast.db[player].channel = 'Interface\\Icons\\Inv_spear_07', nil
    else
        libcast.db[player].cast, libcast.db[player].rank, libcast.db[player].start = nil, nil, nil
        libcast.db[player].casttime, libcast.db[player].icon, libcast.db[player].channel = nil, nil, nil
    end
end

libcast.customcast[string.lower(multishot)] = function(begin, duration)
    if begin then
        duration = duration or 500
        for i = 1, 32 do
            local buff = UnitBuff('player', i)
            if buff == 'Interface\\Icons\\Racial_Troll_Berserk' then
                local berserk = (UnitHealth('player') / UnitHealthMax('player')) >= 0.40 and (1.30 - (UnitHealth('player') / UnitHealthMax('player'))) / 3 or 0.3
                duration = duration / (1 + berserk)
            elseif buff == 'Interface\\Icons\\Ability_Hunter_RunningShot' then
                duration = duration / 1.4
            elseif buff == 'Interface\\Icons\\Ability_Warrior_InnerRage' then
                duration = duration / 1.3
            elseif buff == 'Interface\\Icons\\Inv_Trinket_Naxxramas04' then
                duration = duration / 1.2
            end
        end
        local _, _, lag = GetNetStats()
        libcast.db[player].cast, libcast.db[player].rank = multishot, lastrank
        libcast.db[player].start, libcast.db[player].casttime = GetTime() + lag / 1000, duration
        libcast.db[player].icon, libcast.db[player].channel = 'Interface\\Icons\\Ability_upgrademoonglaive', nil
    else
        libcast.db[player].cast, libcast.db[player].rank, libcast.db[player].start = nil, nil, nil
        libcast.db[player].casttime, libcast.db[player].icon, libcast.db[player].channel = nil, nil, nil
    end
end

function libcast:CastCustom(id, bookType, rawSpellName, rank, texture, castingTime)
    if not id or not rawSpellName or not castingTime then return end
    lastrank, lastcasttex = rank, texture
    local func = self.customcast[string.lower(rawSpellName)]
    if not func then return end
    if GetSpellCooldown(id, bookType) == 0 or self:GetCastingInfo(player) then return end
    func(true)
end

AU.hooks.HookSecureFunc('UseContainerItem', function(id, index)
    lastcasttex = GetContainerItemInfo(id, index)
end)

AU.hooks.HookSecureFunc('CastSpell', function(id, bookType)
    local name, rank, icon, castTime, _, _, spellId, book = libspell:GetSpellInfo(id, bookType)
    libcast:CastCustom(spellId, book, name, rank, icon, castTime)
end)

AU.hooks.HookSecureFunc('CastSpellByName', function(spellCasted, target)
    local name, rank, icon, castTime, _, _, spellId, book = libspell:GetSpellInfo(spellCasted)
    libcast:CastCustom(spellId, book, name, rank, icon, castTime)
end)

AU.hooks.HookSecureFunc('UseAction', function(slot, target, button)
    if GetActionText(slot) or not IsCurrentAction(slot) then return end
    scanner:SetAction(slot)
    local rawSpellName, rank = scanner:GetLine(1)
    if not rawSpellName then return end
    local name, srank, icon, castTime, _, _, spellId, book = libspell:GetSpellInfo(rawSpellName .. (rank and ('(' .. rank .. ')') or ''))
    libcast:CastCustom(spellId, book, name, srank, icon, castTime)
end)

AU.lib.libcast = libcast
