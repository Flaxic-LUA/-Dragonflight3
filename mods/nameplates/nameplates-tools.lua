UNLOCKDRAGONFLIGHT()

-- local WorldFrame = WorldFrame
-- local getn = table.getn

-- local plates = {
--     registry = {},
--     lastChildCount = 0
-- }

-- local validationPrinted = false

-- -- private
-- function plates:IsNamePlate(frame)
--     if not validationPrinted then
--         --debugprint("[VALIDATE] IsNamePlate called - checking frame")
--         validationPrinted = true
--     end

--     if frame:GetObjectType() ~= "Button" then return nil end

--     local region = frame:GetRegions()
--     if not region then return nil end
--     if not region.GetObjectType then return nil end
--     if not region.GetTexture then return nil end

--     if region:GetObjectType() ~= "Texture" then return nil end
--     return region:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" or nil
-- end

-- function plates:HideBlizzardElements(frame)
--     --debugprint("[HIDE] Hiding Blizzard elements")

--     if frame.original.healthbar then frame.original.healthbar:Hide() end
--     if frame.original.border then frame.original.border:Hide() end
--     if frame.original.glow then frame.original.glow:Hide() end
--     if frame.original.elite then frame.original.elite:Hide() end
--     if frame.original.raidicon then frame.original.raidicon:Hide() end
--     if frame.original.name then frame.original.name:Hide() end
--     if frame.original.level then frame.original.level:Hide() end
-- end

-- function plates:UpdateHealthbar(frame) -- v1.0
--     -- PERFORMANCE
--     -- Localize table references to avoid repeated hash table lookups in OnUpdate loop
--     -- Without: frame.original.healthbar = 2 GETTABLE opcodes (frame->original, original->healthbar) per access
--     -- With: blizzHP = 1 GETLOCAL opcode (stack register access) per access
--     -- OnUpdate runs ~60fps, 3 accesses/frame = 360 GETTABLE ops/sec vs 180 GETLOCAL ops/sec per nameplate
--     -- GETTABLE: ~50-100 CPU cycles (hash lookup + metatable check), GETLOCAL: ~5 cycles (stack offset)
--     local blizzHP = frame.original.healthbar
--     local ourHP = frame.custom.healthbar
--     local origLevel = frame.original.level
--     -- /PERFORMANCE

--     frame.custom.frame:SetScript("OnUpdate", function()
--         -- THROTTLE UPDATES
--         -- Only update custom healthbar when value changes to reduce CPU usage
--         -- Without: SetMinMaxValues + SetValue called every frame (~60fps) even if health unchanged
--         -- With: Only called when health value differs from lastValue (damage/healing events)
--         -- Saves ~4 function calls per nameplate per frame when health static
--         if blizzHP then
--             local value = blizzHP:GetValue()

--             if value ~= frame.custom.lastValue then
--                 local min, max = blizzHP:GetMinMaxValues()
--                 ourHP:SetMinMaxValues(min, max)
--                 ourHP:SetValue(value)
--                 frame.custom.lastValue = value
--                 --debugprint("[THROTTLE] Health changed: "..value.." (was: "..frame.custom.lastValue..")")
--             end
--         end
--         -- /THROTTLE UPDATES

--         -- LEVEL HIDE
--         if origLevel then
--             --origLevel:Hide() -- use SetWidth instead - more efficient, no function calls
--             origLevel:SetWidth(0.001)
--         end
--         -- /LEVEL HIDE

--     end)
--     --debugprint("[UPDATE] Healthbar update loop set")
-- end

-- function plates:CreateNameplate(frame) -- v1.0
--     --debugprint("[CREATE] Creating custom nameplate")

--     local overlay = CreateFrame("Button", nil, frame)
--     overlay:SetAllPoints(frame)

--     -- PLATE CLICKS
--     -- pass through method: triggers Blizzard's mouseover glow, using pfuis approach for now
--     -- didnt try to find workaround tho.
--     -- overlay:EnableMouse(0)
--     overlay:EnableMouse(1)
--     overlay:SetScript("OnClick", function() frame:Click() end)
--     --debugprint("[CREATE] Created custom frame")
--     -- /PLATE CLICKS

--     local ourHP = CreateFrame("StatusBar", nil, overlay)
--     ourHP:SetPoint("CENTER", overlay, "CENTER", 0, 0) -- changing Y axis requires another frame to detect the click
--     ourHP:SetWidth(40)
--     ourHP:SetHeight(5)
--     ourHP:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")

--     local bg = ourHP:CreateTexture(nil, "BACKGROUND")
--     bg:SetAllPoints(ourHP)
--     bg:SetTexture("Interface\\Buttons\\WHITE8X8")
--     bg:SetVertexColor(0, 0, 0, 0.5)

--     --debugprint("[CREATE] Created custom healthbar")

--     frame.custom = {
--         frame = overlay,
--         healthbar = ourHP,
--         lastValue = -1
--     }
-- end

-- function plates:ExtractElements(frame)
--     --debugprint("[EXTRACT] Starting element extraction")

--     local children = { frame:GetChildren() }
--     --debugprint("[EXTRACT] Children count: "..getn(children))

--     local healthbar = children[1]
--     --debugprint("[EXTRACT] Got healthbar: "..(healthbar and "OK" or "NIL"))

--     local regions = { frame:GetRegions() }
--     --debugprint("[EXTRACT] Got regions count: "..getn(regions))

--     -- debug all regions
--     for i = 1, getn(regions) do
--         local objType = regions[i]:GetObjectType()
--         --debugprint("[EXTRACT] Region["..i.."] type: "..objType)
--     end

--     -- find fontstrings
--     local nameFontString, levelFontString
--     for i = 1, getn(regions) do
--         if regions[i]:GetObjectType() == "FontString" then
--             if not nameFontString then
--                 nameFontString = regions[i]
--             else
--                 levelFontString = regions[i]
--             end
--         end
--     end

--     -- store original elements
--     frame.original = {
--         healthbar = healthbar,
--         border = regions[1],
--         glow = regions[2],
--         elite = regions[5],
--         raidicon = regions[6],
--         name = nameFontString,
--         level = levelFontString
--     }

--     --debugprint("[EXTRACT] Stored healthbar: "..(frame.original.healthbar and "OK" or "NIL"))
--     --debugprint("[EXTRACT] Stored border: "..(frame.original.border and "OK" or "NIL"))
--     --debugprint("[EXTRACT] Stored glow: "..(frame.original.glow and "OK" or "NIL"))
--     --debugprint("[EXTRACT] Stored elite: "..(frame.original.elite and "OK" or "NIL"))
--     --debugprint("[EXTRACT] Stored raidicon: "..(frame.original.raidicon and "OK" or "NIL"))
--     --debugprint("[EXTRACT] Stored name: "..(frame.original.name and "OK" or "NIL"))
--     --debugprint("[EXTRACT] Stored level: "..(frame.original.level and "OK" or "NIL"))

--     -- read initial data
--     if nameFontString then
--         local name = nameFontString:GetText()
--         if name then
--             --debugprint("[EXTRACT] Nameplate name: "..name)
--         else
--             --debugprint("[EXTRACT] Name text is nil")
--         end
--     else
--         --debugprint("[EXTRACT] No name fontstring found")
--     end

--     if healthbar then
--         local r, g, b = healthbar:GetStatusBarColor()
--         --debugprint("[EXTRACT] Healthbar color: "..r..", "..g..", "..b)
--     end
-- end

-- function plates:SetupNamePlate(frame)
--     --debugprint("[SETUP] Starting nameplate setup")
--     plates:ExtractElements(frame)
--     plates:CreateNameplate(frame)
--     plates:HideBlizzardElements(frame)
--     plates:UpdateHealthbar(frame)
--     --debugprint("[SETUP] Setup complete")
-- end

-- function plates:ScanNamePlates()
--     local count = WorldFrame:GetNumChildren()

--     if count > plates.lastChildCount then
--         --debugprint("[SCAN] WorldFrame children increased from "..plates.lastChildCount.." to "..count)
--         local children = { WorldFrame:GetChildren() }

--         for i = plates.lastChildCount + 1, count do
--             local frame = children[i]
--             --debugprint("[SCAN] Checking child "..i.." type: "..frame:GetObjectType())

--             if plates:IsNamePlate(frame) and not plates.registry[frame] then
--                 --debugprint("[SCAN] Valid nameplate found!")
--                 plates.registry[frame] = true
--                 plates:SetupNamePlate(frame)
--             end
--         end

--         plates.lastChildCount = count
--     end
-- end

-- -- public
-- function DF.lib.InitNamePlates()
--     local scanner = CreateFrame("Frame")
--     scanner:SetScript("OnUpdate", function()
--         plates:ScanNamePlates()
--     end)
-- end

-- -- expose
-- DF.setups.plates = plates

-- -- test area
-- local testFrame = CreateFrame('Frame')
-- testFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
-- testFrame:SetScript('OnEvent', function()
--     DF.lib.InitNamePlates()
--     --debugprint("Nameplate scanner initialized")
-- end)

