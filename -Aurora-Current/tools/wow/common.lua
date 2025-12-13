UNLOCKAURORA()

function AU.common.KillFrame(frame)
    if not frame then return end

    if frame.UnregisterAllEvents then
        frame:UnregisterAllEvents()
    end

    if frame.Hide then
        frame:Hide()
    end

    if frame.GetScript and frame.SetScript then
        local scriptTypes = {
            "OnShow", "OnHide", "OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp",
            "OnClick", "OnDoubleClick", "OnDragStart", "OnDragStop", "OnUpdate",
            "OnEvent", "OnLoad", "OnSizeChanged", "OnValueChanged"
        }

        for _, scriptType in ipairs(scriptTypes) do
            local success = pcall(function() return frame:GetScript(scriptType) end)
            if success and frame:GetScript(scriptType) then
            frame:SetScript(scriptType, nil)
            end
        end
    end

    if frame.SetParent then
        frame:SetParent(UIParent)
    end

    if frame.ClearAllPoints then
        frame:ClearAllPoints()
    end

    if frame.SetAlpha then
        frame:SetAlpha(0)
    end

    if frame.EnableMouse then
        frame:EnableMouse(false)
    end

    if frame.EnableKeyboard then
        frame:EnableKeyboard(false)
    end
end
