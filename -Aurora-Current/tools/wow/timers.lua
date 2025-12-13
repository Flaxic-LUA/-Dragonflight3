UNLOCKAURORA()

AU.timers.registry = {}
AU.timers.nextId = 1

-- timer operations
local pairs = pairs
local pcall = pcall
local GetTime = GetTime
local frame = CreateFrame'Frame'
local registry = AU.timers.registry

-- private
local function OnUpdate()
    local currentTime = GetTime()
    local hasTimers = false

    for id, timer in pairs(registry) do
        hasTimers = true
        if currentTime >= timer.endTime then
            -- pcall so one timer error doesn't break all
            -- TODO: proper error routing missing still
            local success, err = pcall(timer.func)
            if not success then
                -- debugprint('Timer error (ID ' .. id .. '): ' .. tostring(err))
            end

            if timer.repeating then
                -- use accurate timing alignment
                timer.endTime = math.floor(currentTime / timer.interval + 1) * timer.interval
            else
                registry[id] = nil
            end
        end
    end

    if not hasTimers then
        frame:SetScript('OnUpdate', nil)
    end
end

-- public

-- delay: executes function delay
-- delay (number) - seconds to wait
-- func (function) - function to execute
-- returns: timer id
function AU.timers.delay(delay, func)
    local id = AU.timers.nextId
    AU.timers.nextId = id + 1

    registry[id] = {
        endTime = GetTime() + delay,
        func = func,
        repeating = false
    }

    frame:SetScript('OnUpdate', OnUpdate)
    return id
end

-- every: executes function repeatedly at interval
-- interval (number) - seconds between executions
-- func (function) - function to execute
-- returns: timer id
function AU.timers.every(interval, func)
    local id = AU.timers.nextId
    AU.timers.nextId = id + 1

    local now = GetTime()
    local nextTick = math.floor(now / interval + 1) * interval

    registry[id] = {
        endTime = nextTick,
        interval = interval,
        func = func,
        repeating = true
    }

    frame:SetScript('OnUpdate', OnUpdate)
    return id
end

-- cancel: cancels timer by id
-- id (number) - timer id to cancel
-- returns: true if cancelled, false if not found
function AU.timers.cancel(id)
    if registry[id] then
        registry[id] = nil
        return true
    end
    return false
end
