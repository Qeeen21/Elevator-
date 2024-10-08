local ESX = exports['es_extended']:getSharedObject()
local hasTextUi = false
local cfg = require 'config'

-- Access translations from config
local translations = cfg.translations

local function enterElevator(elevatorId)
    local options = {}
    
    local elevatorConfig = cfg.Elevators[elevatorId]
    if not elevatorConfig then
        print("Konfigurace výtahu nenalezena pro ID:", elevatorId)
        return
    end

    local floorNames = elevatorConfig.floorNames or {}
    
    -- Naplňte možnosti názvy pater z konfigurace výtahu
    for k, coord in ipairs(elevatorConfig.coords) do
        local floorName = floorNames[k] or ('Patro %s'):format(k)
        options[k] = {value = k, label = floorName}
    end

    local input = lib.inputDialog('Menu Výtahu', {
        { type = 'select', label = 'Vyberte Patro', options = options }
    }, {
        confirm = translations.confirm,  -- Use translated Confirm
        cancel = translations.cancel     -- Use translated Cancel
    })

    if not input then return end

    local selectedFloor = tonumber(input[1])
    if selectedFloor then
        local coords = elevatorConfig.coords[selectedFloor]
        if not coords then
            print("Koordináty nenalezeny pro vybrané patro:", selectedFloor)
            return
        end

        -- Check if the floor is restricted
        local restricted = elevatorConfig.restrictedFloors and elevatorConfig.restrictedFloors[selectedFloor]
        if restricted then
            local hasPermission = false
            if restricted.jobs then
                for _, jobName in pairs(restricted.jobs) do
                    if ESX.PlayerData.job.name == jobName then
                        hasPermission = true
                        break
                    end
                end
            end

            if not hasPermission then
                ESX.ShowNotification('Nemáte oprávnění přístup na toto patro.')
                return
            end
        end

        if cfg.EnableFadeOut then
            DoScreenFadeOut(800)
            while not IsScreenFadedOut() do Wait(0) end
            DoScreenFadeIn(800)
            SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, true)
        else
            SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, true)
        end
    end
end

local elevators, currentZone = {}, {}

local function onEnter(self)
    if cfg.Elevators[self.eleId] then
        currentZone[self.eleId] = cfg.Elevators[self.eleId].coords
    end
end

local function onExit(self)
    lib.hideTextUI()
    table.wipe(currentZone)
end

local function nearbyElevator(self)
    if cfg.Elevators[self.eleId] and not IsEntityDead(cache.ped) then
        if type(cfg.Elevators[self.eleId].jobs) == 'table' then 
            for _, jobName in pairs(cfg.Elevators[self.eleId].jobs) do
                if ESX.PlayerData.job.name == jobName then
                    if cfg.DrawMarker then
                        DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)
                    end

                    if self.isClosest and self.currentDistance < 1.2 then
                        if not hasTextUi then
                            hasTextUi = true
                            lib.showTextUI(('[E] - Vstup do %s'):format(cfg.Elevators[self.eleId].name))
                        end

                        if IsControlJustReleased(0, 38) then
                            lib.hideTextUI()
                            enterElevator(self.eleId)  -- Pass elevatorId here
                        end

                    elseif hasTextUi then
                        hasTextUi = false
                        lib.hideTextUI()
                    end
                end
            end
        elseif type(cfg.Elevators[self.eleId].jobs) == 'boolean' then
            if cfg.DrawMarker then
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)
            end
            
            if self.isClosest and self.currentDistance < 1.2 then
                if not hasTextUi then
                    hasTextUi = true
                    lib.showTextUI(('[E] - Vstup do %s'):format(cfg.Elevators[self.eleId].name))
                end

                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    enterElevator(self.eleId)  -- Pass elevatorId here
                end

            elseif hasTextUi then
                hasTextUi = false
                lib.hideTextUI()
            end
        end
    end
end

local function setupElevators()
    for k,v in pairs(cfg.Elevators) do
        for i = 1, #v.coords, 1 do
            elevators[i] = lib.points.new({
                coords = v.coords[i],
                distance = 6.0,
                eleId = k,
                onEnter = onEnter,
                onExit = onExit,
                nearby = nearbyElevator
            })
        end
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true

    if ESX.PlayerLoaded then
        setupElevators()
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

AddEventHandler('onResourceStart', function(name)
    if cache.resource == name then
        setupElevators()
    end
end)
