SLASH_LOAD1 = '/load'
SlashCmdList['LOAD'] = function(addon)
    if addon == '' then
        print('Usage: /load ADDONNAME')
        return
    end
    local _, _, _, _, _, reason = GetAddOnInfo(addon)
    if reason ~= 'MISSING' then
        EnableAddOn(addon)
        ReloadUI()
    else
        print('Addon \'' .. addon .. '\' not found.')
    end
end

SLASH_UNLOAD1 = '/unload'
SlashCmdList['UNLOAD'] = function(addon)
    if addon == '' then
        print('Usage: /unload ADDONNAME')
        return
    end
    local _, _, _, _, _, reason = GetAddOnInfo(addon)
    if reason ~= 'MISSING' then
        DisableAddOn(addon)
        ReloadUI()
    else
        print('Addon \'' .. addon .. '\' not found.')
    end
end
