local config = Config
local speedMultiplier = config.UseMPH and 2.23694 or 3.6
local seatbeltOn = false
local cruiseOn = false
local showAltitude = false
local showSeatbelt = false
local nos = 0
local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local nitroActive = 0
local harness = 0
local hp = 100
local armed = 0
local parachute = -1
local oxygen = 100
local engine = 0
local dev = false
local playerDead = false
local showMenu = false
local showCircleB = false
local showSquareB = false
local Menu = config.Menu
local CinematicHeight = 0.2
local w = 0
local isFrameworkHudShowing

DisplayRadar(false)

local function CinematicShow(bool)
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    if bool then
        for i = CinematicHeight, 0, -1.0 do
            Wait(10)
            w = i
        end
    else
        for i = 0, CinematicHeight, 1.0 do
            Wait(10)
            w = i
        end
    end
end

local function loadSettings(settings)
    for k,v in pairs(settings) do
        if k == 'isToggleMapShapeChecked' then
            Menu.isToggleMapShapeChecked = v
            SendNUIMessage({ test = true, event = k, toggle = v})
        elseif k == 'isCineamticModeChecked' then
            Menu.isCineamticModeChecked = v
            CinematicShow(v)
            SendNUIMessage({ test = true, event = k, toggle = v})
        elseif k == 'isChangeFPSChecked' then
            Menu[k] = v
            local val = v and 'Optimized' or 'Synced'
            SendNUIMessage({ test = true, event = k, toggle = val})
        else
            Menu[k] = v
            SendNUIMessage({ test = true, event = k, toggle = v})
        end
    end
	Framework.ShowNotification(_U('hud_settings_loaded'), "success", 3000)
    Wait(1000)
    TriggerEvent("JLRP-Hud:Client:LoadMap")
end

local function saveSettings()
    SetResourceKvp('hudSettings', json.encode(Menu))
end

local function hasHarness(items)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local _harness = false
    if items then
        for _, v in pairs(items) do
            if v.name == 'harness' then
                _harness = true
            end
        end
    end

    harness = _harness
end

RegisterNetEvent('JLRP-Framework:playerLoaded')
AddEventHandler('JLRP-Framework:playerLoaded', function(xPlayer, isNew, skin)
	Wait(2000)
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then loadSettings(json.decode(hudSettings)) end
	
	isFrameworkHudShowing = Framework.UI.HUD.IsShowing()
end)

RegisterNetEvent('JLRP-Framework:onPlayerLogout')
AddEventHandler('JLRP-Framework:onPlayerLogout', function()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000)
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then loadSettings(json.decode(hudSettings)) end
	
	if Framework.IsPlayerLoaded() then isFrameworkHudShowing = Framework.UI.HUD.IsShowing() end
end)

-- Callbacks & Events

RegisterNUICallback('closeMenu', function(_, cb)
    Wait(50)
    TriggerEvent("JLRP-Hud:Client:playCloseMenuSounds")
    showMenu = false
    SetNuiFocus(false, false)
    cb("ok")
end)

AddEventHandler("onKeyUp", function(key)
	if key == "y" then
		Wait(50)
		if showMenu then return end
		TriggerEvent("JLRP-Hud:Client:playOpenMenuSounds")
		SetNuiFocus(true, true)
		SendNUIMessage({ action = "open"})
		showMenu = true
	end
end)

-- Reset hud
local function restartHud()
    TriggerEvent("JLRP-Hud:Client:playResetHudSounds")
	Framework.ShowNotification(_U('hud_restart'), "error", 3000)
    if IsPedInAnyVehicle(PlayerPedId()) then
        Wait(2600)
        SendNUIMessage({ action = 'car', show = false })
        SendNUIMessage({ action = 'car', show = true })
    end
    Wait(2600)
    SendNUIMessage({ action = 'hudtick', show = false })
    SendNUIMessage({ action = 'hudtick', show = true })
    Wait(2600)
	Framework.ShowNotification(_U('hud_start'), "success", 3000)
end

RegisterNUICallback('restartHud', function(_, cb)
    Wait(50)
    restartHud()
    cb("ok")
end)

RegisterCommand('resethud', function(_, cb)
    Wait(50)
    restartHud()
    cb("ok")
end)

RegisterNUICallback('resetStorage', function(_, cb)
    Wait(50)
    TriggerEvent("JLRP-Hud:Client:resetStorage")
    cb("ok")
end)

RegisterNetEvent("JLRP-Hud:Client:resetStorage", function()
    Wait(50)
    if Menu.isResetSoundsChecked then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "airwrench", 0.1)
    end
    Framework.TriggerServerCallback('JLRP-Hud:Server:getMenu', function(menu)
		loadSettings(menu)
		SetResourceKvp('hudSettings', json.encode(menu))
	end)
end)

-- Notifications
RegisterNUICallback('openMenuSounds', function(_, cb)
    Wait(50)
    Menu.isOpenMenuSoundsChecked = not Menu.isOpenMenuSoundsChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNetEvent("JLRP-Hud:Client:playOpenMenuSounds", function()
    Wait(50)
    if not Menu.isOpenMenuSoundsChecked then return end
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "monkeyopening", 0.5)
end)

RegisterNetEvent("JLRP-Hud:Client:playCloseMenuSounds", function()
    Wait(50)
    if not Menu.isOpenMenuSoundsChecked then return end
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "catclosing", 0.05)
end)

RegisterNUICallback('resetHudSounds', function(_, cb)
    Wait(50)
    Menu.isResetSoundsChecked = not Menu.isResetSoundsChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNetEvent("JLRP-Hud:Client:playResetHudSounds", function()
    Wait(50)
    if not Menu.isResetSoundsChecked then return end
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "airwrench", 0.1)
end)

RegisterNUICallback('checklistSounds', function(_, cb)
    Wait(50)
    TriggerEvent("JLRP-Hud:Client:checklistSounds")
    cb("ok")
end)

RegisterNetEvent("JLRP-Hud:Client:checklistSounds", function()
    Wait(50)
    Menu.isListSoundsChecked = not Menu.isListSoundsChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
end)

RegisterNetEvent("JLRP-Hud:Client:playHudChecklistSound", function()
    Wait(50)
    if not Menu.isListSoundsChecked then return end
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "shiftyclick", 0.5)
end)

RegisterNUICallback('showOutMap', function(_, cb)
    Wait(50)
    Menu.isOutMapChecked = not Menu.isOutMapChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showOutCompass', function(_, cb)
    Wait(50)
    Menu.isOutCompassChecked = not Menu.isOutCompassChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showFollowCompass', function(_, cb)
	Wait(50)
    Menu.isCompassFollowChecked = not Menu.isCompassFollowChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showMapNotif', function(_, cb)
    Wait(50)
    Menu.isMapNotifChecked = not Menu.isMapNotifChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showFuelAlert', function(_, cb)
    Wait(50)
    Menu.isLowFuelChecked = not Menu.isLowFuelChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showCinematicNotif', function(_, cb)
    Wait(50)
    Menu.isCinematicNotifChecked = not Menu.isCinematicNotifChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

-- Status
RegisterNUICallback('dynamicHealth', function(_, cb)
    Wait(50)
    TriggerEvent("JLRP-Hud:Client:ToggleHealth")
    cb("ok")
end)

RegisterNetEvent("JLRP-Hud:Client:ToggleHealth", function()
    Wait(50)
    Menu.isDynamicHealthChecked = not Menu.isDynamicHealthChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
end)

RegisterNUICallback('dynamicArmor', function(_, cb)
    Wait(50)
    Menu.isDynamicArmorChecked = not Menu.isDynamicArmorChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('dynamicHunger', function(_, cb)
    Wait(50)
    Menu.isDynamicHungerChecked = not Menu.isDynamicHungerChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('dynamicThirst', function(_, cb)
    Wait(50)
    Menu.isDynamicThirstChecked = not Menu.isDynamicThirstChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('dynamicStress', function(_, cb)
    Wait(50)
    Menu.isDynamicStressChecked = not Menu.isDynamicStressChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('dynamicOxygen', function(_, cb)
    Wait(50)
    Menu.isDynamicOxygenChecked = not Menu.isDynamicOxygenChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

-- Vehicle
RegisterNUICallback('changeFPS', function(_, cb)
    Wait(50)
    Menu.isChangeFPSChecked = not Menu.isChangeFPSChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('HideMap', function(_, cb)
    Wait(50)
    Menu.isHideMapChecked = not Menu.isHideMapChecked
    DisplayRadar(not Menu.isHideMapChecked)
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNetEvent("JLRP-Hud:Client:LoadMap", function()
    Wait(50)
    -- Credit to Dalrae for the solve.
    local defaultAspectRatio = 1920/1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX/resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.008
    end
    if Menu.isToggleMapShapeChecked == "square" then
        RequestStreamedTextureDict("squaremap", false)
        if not HasStreamedTextureDictLoaded("squaremap") then
            Wait(150)
        end
        if Menu.isMapNotifChecked then
			Framework.ShowNotification(_U('load_square_map'), "info", 3000)
        end
        SetMinimapClipType(0)
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
        AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
        -- 0.0 = nav symbol and icons left
        -- 0.1638 = nav symbol and icons stretched
        -- 0.216 = nav symbol and icons raised up
        SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)

        -- icons within map
        SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)

        -- -0.01 = map pulled left
        -- 0.025 = map raised up
        -- 0.262 = map stretched
        -- 0.315 = map shorten
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetRadarBigmapEnabled(true, false)
        SetMinimapClipType(0)
        Wait(50)
        SetRadarBigmapEnabled(false, false)
        if Menu.isToggleMapBordersChecked then
            showCircleB = false
            showSquareB = true
        end
        Wait(1200)
        if Menu.isMapNotifChecked then
			Framework.ShowNotification(_U('loaded_square_map'), "info", 3000)
        end
    elseif Menu.isToggleMapShapeChecked == "circle" then
        RequestStreamedTextureDict("circlemap", false)
        if not HasStreamedTextureDictLoaded("circlemap") then
            Wait(150)
        end
        if Menu.isMapNotifChecked then
			Framework.ShowNotification(_U('load_circle_map'), "info", 3000)
        end
        SetMinimapClipType(1)
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
        AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "circlemap", "radarmasksm")
        -- -0.0100 = nav symbol and icons left
        -- 0.180 = nav symbol and icons stretched
        -- 0.258 = nav symbol and icons raised up
        SetMinimapComponentPosition("minimap", "L", "B", -0.0100 + minimapOffset, -0.030, 0.180, 0.258)

        -- icons within map
        SetMinimapComponentPosition("minimap_mask", "L", "B", 0.200 + minimapOffset, 0.0, 0.065, 0.20)

        -- -0.00 = map pulled left
        -- 0.015 = map raised up
        -- 0.252 = map stretched
        -- 0.338 = map shorten
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.015, 0.252, 0.338)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetMinimapClipType(1)
        SetRadarBigmapEnabled(true, false)
        Wait(50)
        SetRadarBigmapEnabled(false, false)
        if Menu.isToggleMapBordersChecked then
            showSquareB = false
            showCircleB = true
        end
        Wait(1200)
        if Menu.isMapNotifChecked then
			Framework.ShowNotification(_U('loaded_circle_map'), "info", 3000)
        end
    end
end)

RegisterNUICallback('ToggleMapShape', function(_, cb)
    Wait(50)
    if not Menu.isHideMapChecked then
        Menu.isToggleMapShapeChecked = Menu.isToggleMapShapeChecked == "circle" and "square" or "circle"
        Wait(50)
        TriggerEvent("JLRP-Hud:Client:LoadMap")
    end
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('ToggleMapBorders', function(_, cb)
    Wait(50)
    Menu.isToggleMapBordersChecked = not Menu.isToggleMapBordersChecked
    if Menu.isToggleMapBordersChecked then
        if Menu.isToggleMapShapeChecked == "square" then
            showSquareB = true
        else
            showCircleB = true
        end
    else
        showSquareB = false
        showCircleB = false
    end
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('dynamicEngine', function(_, cb)
    Wait(50)
    Menu.isDynamicEngineChecked = not Menu.isDynamicEngineChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('dynamicNitro', function(_, cb)
    Wait(50)
    Menu.isDynamicNitroChecked = not Menu.isDynamicNitroChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

-- Compass
RegisterNUICallback('showCompassBase', function(_, cb)
	Wait(50)
    Menu.isCompassShowChecked = not Menu.isCompassShowChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showStreetsNames', function(_, cb)
	Wait(50)
    Menu.isShowStreetsChecked = not Menu.isShowStreetsChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showPointerIndex', function(_, cb)
	Wait(50)
    Menu.isPointerShowChecked = not Menu.isPointerShowChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('showDegreesNum', function(_, cb)
	Wait(50)
    Menu.isDegreesShowChecked = not Menu.isDegreesShowChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('changeCompassFPS', function(_, cb)
	Wait(50)
    Menu.isChangeCompassFPSChecked = not Menu.isChangeCompassFPSChecked
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNUICallback('cinematicMode', function(_, cb)
    Wait(50)
    if Menu.isCineamticModeChecked then
        CinematicShow(false)
        Menu.isCineamticModeChecked = false
        if Menu.isCinematicNotifChecked then
			Framework.ShowNotification(_U('cinematic_off'), "error", 3000)
        end
        DisplayRadar(1)
		--SetTimecycleModifier("default")
		if Framework.GetConfig().EnableHud then
			isFrameworkHudShowing = Framework.UI.HUD.IsShowing()
			if isFrameworkHudShowing then
				Framework.UI.HUD.SetDisplay(1.0)
			end
		end
    else
        CinematicShow(true)
        Menu.isCineamticModeChecked = true
        if Menu.isCinematicNotifChecked then
			Framework.ShowNotification(_U('cinematic_on'), "success", 3000)
        end
		--SetTimecycleModifier("cinema")
		if Framework.GetConfig().EnableHud then
			if isFrameworkHudShowing then
				isFrameworkHudShowing = false
				Framework.UI.HUD.SetDisplay(0.0)
			end
		end
    end
    TriggerEvent("JLRP-Hud:Client:playHudChecklistSound")
    saveSettings()
    cb("ok")
end)

RegisterNetEvent("JLRP-Hud:Client:EngineHealth", function(newEngine)
    engine = newEngine
end)

RegisterNetEvent('JLRP-Hud:Client:ToggleAirHud', function()
    showAltitude = not showAltitude
end)

RegisterNetEvent("JLRP-Framework:updateStatus")
AddEventHandler("JLRP-Framework:updateStatus", function(newHunger, newThirst, newStress, newDrunk) -- Triggered in JLRP-Framework
	if newHunger ~= nil then hunger = newHunger end
	if newThirst ~= nil then thirst = newThirst end
	if newStress ~= nil then stress = newStress end
end)

RegisterNetEvent('JLRP-Hud:Client:ToggleShowSeatbelt', function()
    showSeatbelt = not showSeatbelt
end)

RegisterNetEvent('JLRP-Config:Seatbelt:Client:ToggleSeatbelt', function() -- Triggered in JLRP-Config
    seatbeltOn = not seatbeltOn
end)

RegisterNetEvent('JLRP-Config:Cruise:Client:ToggleCruise', function(state) -- Triggered in JLRP-Config
    if state ~= nil then
		cruiseOn = state
	else
		cruiseOn = not cruiseOn
	end
end)

RegisterNetEvent('JLRP-Hud:Client:UpdateNitrous', function(_, nitroLevel, bool)
    nos = nitroLevel
    nitroActive = bool
end)

RegisterNetEvent('JLRP-Hud:Client:UpdateHarness', function(harnessHp)
    hp = harnessHp
end)

RegisterCommand('+engine', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return end
    if GetIsVehicleEngineRunning(vehicle) then
		Framework.ShowNotification(_U('engine_off'), "error", 3000)
    else
		Framework.ShowNotification(_U('engine_on'), "success", 3000)
    end
    SetVehicleEngineOn(vehicle, not GetIsVehicleEngineRunning(vehicle), false, true)
end)

RegisterKeyMapping('+engine', 'Toggle Engine', 'keyboard', 'G')

local function IsWhitelistedWeaponArmed(weapon)
    if weapon then
        for _, v in pairs(config.WhitelistedWeaponArmed) do
            if weapon == v then
                return true
            end
        end
    end
    return false
end

local prevPlayerStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local function updatePlayerHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevPlayerStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevPlayerStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'hudtick',
            show = data[1],
            dynamicHealth = data[2],
            dynamicArmor = data[3],
            dynamicHunger = data[4],
            dynamicThirst = data[5],
            dynamicStress = data[6],
            dynamicOxygen = data[7],
            dynamicEngine = data[8],
            dynamicNitro = data[9],
            health = data[10],
            playerDead = data[11],
            armor = data[12],
            thirst = data[13],
            hunger = data[14],
            stress = data[15],
            voice = data[16],
            radio = data[17],
            talking = data[18],
            armed = data[19],
            oxygen = data[20],
            parachute = data[21],
            nos = data[22],
            cruise = data[23],
            nitroActive = data[24],
            harness = data[25],
            hp = data[26],
            speed = data[27],
            engine = data[28],
            cinematic = data[29],
            dev = data[30],
        })
    end
end

local prevVehicleStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local function updateVehicleHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevVehicleStats[k] ~= v then shouldUpdate = true break end
    end
    prevVehicleStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'car',
            show = data[1],
            isPaused = data[2],
            seatbelt = data[3],
            speed = data[4],
            fuel = data[5],
            altitude = data[6],
            showAltitude = data[7],
            showSeatbelt = data[8],
            showSquareB = data[9],
            showCircleB = data[10],
        })
    end
end

local lastFuelUpdate = 0
local lastFuelCheck = {}

local function getFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(GetVehicleFuelLevel(vehicle))
    end
    return lastFuelCheck
end

RegisterNetEvent('JLRP-Framework:playerLoaded')
AddEventHandler('JLRP-Framework:playerLoaded', function(xPlayer, isNew, skin)
	Framework.PlayerLoaded = true
	Framework.PlayerData = xPlayer
end)

RegisterNetEvent('JLRP-Framework:onPlayerSpawn')
AddEventHandler('JLRP-Framework:onPlayerSpawn', function(xPlayer, isNew, skin)
	Framework.PlayerData = Framework.GetPlayerData()
end)
-- HUD Update loop

CreateThread(function()
	while not Framework.IsPlayerLoaded() do SendNUIMessage({ action = 'hudtick', show = false }) Wait(1000) end

    local wasInVehicle = false
    while true do
        if Menu.isChangeFPSChecked then
            Wait(500)
        else
            Wait(50)
        end
        --if LocalPlayer.state.isLoggedIn then
            local show = true
            local player = PlayerPedId()
            local playerId = PlayerId()
            local weapon = GetSelectedPedWeapon(player)
            -- Player hud
            if not IsWhitelistedWeaponArmed(weapon) then
                if weapon ~= `WEAPON_UNARMED` then
                    armed = true
                else
                    armed = false
                end
            end
            playerDead = IsEntityDead(player) or Framework.PlayerData.metadata.inlaststand or Framework.PlayerData.metadata.dead or false
            parachute = GetPedParachuteState(player)
            -- Stamina
            if not IsEntityInWater(player) then
                oxygen = 100 - GetPlayerSprintStaminaRemaining(playerId)
            end
            -- Oxygen
            if IsEntityInWater(player) then
                oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
            end
            -- Player hud
            local talking = NetworkIsPlayerTalking(playerId)
            local voice = 0
            if LocalPlayer.state['proximity'] then
                voice = LocalPlayer.state['proximity'].distance
            end
            if IsPauseMenuActive() then
                show = false
			end
            local vehicle = GetVehiclePedIsIn(player)
            if not (IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle)) then
            updatePlayerHud({
                show,
                Menu.isDynamicHealthChecked,
                Menu.isDynamicArmorChecked,
                Menu.isDynamicHungerChecked,
                Menu.isDynamicThirstChecked,
                Menu.isDynamicStressChecked,
                Menu.isDynamicOxygenChecked,
                Menu.isDynamicEngineChecked,
                Menu.isDynamicNitroChecked,
                GetEntityHealth(player) - 100,
                playerDead,
                GetPedArmour(player),
                thirst,
                hunger,
                stress,
                voice,
                LocalPlayer.state['radioChannel'],
                talking,
                armed,
                oxygen,
                parachute,
                -1,
                cruiseOn,
                nitroActive,
                harness,
                hp,
                math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                -1,
                Menu.isCineamticModeChecked,
                dev,
            })
            end
            -- Vehicle hud
            if IsPedInAnyHeli(player) or IsPedInAnyPlane(player) then
                showAltitude = true
                showSeatbelt = false
            end
            if IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle) then
                if not wasInVehicle then
                    DisplayRadar(true)
                end
                wasInVehicle = true
                updatePlayerHud({
                    show,
                    Menu.isDynamicHealthChecked,
                    Menu.isDynamicArmorChecked,
                    Menu.isDynamicHungerChecked,
                    Menu.isDynamicThirstChecked,
                    Menu.isDynamicStressChecked,
                    Menu.isDynamicOxygenChecked,
                    Menu.isDynamicEngineChecked,
                    Menu.isDynamicNitroChecked,
                    GetEntityHealth(player) - 100,
                    playerDead,
                    GetPedArmour(player),
                    thirst,
                    hunger,
                    stress,
                    voice,
                    LocalPlayer.state['radioChannel'],
                    talking,
                    armed,
                    oxygen,
                    GetPedParachuteState(player),
                    nos,
                    cruiseOn,
                    nitroActive,
                    harness,
                    hp,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    (GetVehicleEngineHealth(vehicle) / 10),
                    Menu.isCineamticModeChecked,
                    dev,
                })
                updateVehicleHud({
                    show,
                    IsPauseMenuActive(),
                    seatbeltOn,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    getFuelLevel(vehicle),
                    math.ceil(GetEntityCoords(player).z * 0.5),
                    showAltitude,
                    showSeatbelt,
                    showSquareB,
                    showCircleB,
                })
                showAltitude = false
                showSeatbelt = true
            else
                if wasInVehicle then
                    wasInVehicle = false
                    SendNUIMessage({
                        action = 'car',
                        show = false,
                        seatbelt = false,
                        cruise = false,
                    })
                    seatbeltOn = false
                    cruiseOn = false
                    harness = false
                end
                DisplayRadar(Menu.isOutMapChecked)
            end
        --else
        --    SendNUIMessage({
        --        action = 'hudtick',
        --        show = false
        --    })
        --end
    end
end)

-- Low fuel
CreateThread(function()
    while true do
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped, false) and not IsThisModelABicycle(GetEntityModel(GetVehiclePedIsIn(ped, false))) then
			if GetVehicleFuelLevel(GetVehiclePedIsIn(ped, false)) <= 20 then -- At 20% Fuel Left
				if Menu.isLowFuelChecked then
					TriggerServerEvent("InteractSound_SV:PlayOnSource", "pager", 0.10)
					Framework.ShowNotification(_U('low_fuel'), "error", 3000)
					Wait(60000) -- repeats every 1 min until empty
					end
                end
            end
        Wait(10000)
    end
end)

-- Money HUD

RegisterNetEvent('JLRP-Hud:Client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = amount
        })
    else
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = amount
        })
    end
end)

-- Harness Check
--[[
CreateThread(function()
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            hasHarness(Framework.PlayerData.items)
        end
    end
end)
]]
-- Stress Gain

CreateThread(function() -- Speeding
	while not Framework.IsPlayerLoaded() and not Framework.PlayerData.metadata do Wait(1000) end
	if Framework.PlayerData.metadata.stress then
		stress = Framework.PlayerData.metadata.stress
	else
		stress = 0
	end
    while true do
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped, false) then
            local stressSpeed = 0
            local veh = GetVehiclePedIsIn(ped, false)
            local vehClass = GetVehicleClass(veh)
            local speed = GetEntitySpeed(veh) * speedMultiplier
            
            if vehClass ~= 13 and vehClass ~= 14 and vehClass ~= 15 and vehClass ~= 16 and vehClass ~= 21 then
                if vehClass == 8 then --for motocrycles since they don't have seatbelts therefore config.MinimumSpeedUnbuckled must not be affected
                    stressSpeed = config.MinimumSpeed
                else
                    stressSpeed = seatbeltOn and config.MinimumSpeed or config.MinimumSpeedUnbuckled
                end
                if speed >= stressSpeed then
                    TriggerServerEvent('JLRP-Framework:addStress', math.random(1, 5))
					Framework.ShowNotification(_U('stress_gain'), 'error', 1500)
                    Wait(15000)
                end
            end
		end
		Wait(10000)
    end
end)

local function IsWhitelistedWeaponStress(weapon)
    if weapon then
        for _, v in pairs(config.WhitelistedWeaponStress) do
            if weapon == v then
                return true
            end
        end
    end
    return false
end

CreateThread(function() -- Shooting
    while true do
		local ped = PlayerPedId()
		local weapon = GetSelectedPedWeapon(ped)
		if weapon ~= `WEAPON_UNARMED` then
			if IsPedShooting(ped) and not IsWhitelistedWeaponStress(weapon) then
				if math.random() < config.StressChance then
					TriggerServerEvent('JLRP-Framework:addStress', math.random(1, 3))
					Framework.ShowNotification(_U('stress_gain'), 'error', 1500)
					Wait(2000)
				end
			end
		else
			Wait(1000)
		end
        Wait(0)
    end
end)

-- Stress Screen Effects

local function GetBlurIntensity(stresslevel)
    for _, v in pairs(config.Intensity['blur']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local effectInterval = GetEffectInterval(stress)
        if stress >= 100 then
            local BlurIntensity = GetBlurIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = FallRepeat * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)

            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(1000)
            for _ = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stress >= config.MinimumStress then
            local BlurIntensity = GetBlurIntensity(stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)

-- Minimap update
CreateThread(function()
    while true do
        SetRadarBigmapEnabled(false, false)
        --SetRadarZoom(1000)
        Wait(1000)
    end
end)

local function BlackBars()
    DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
    DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
end

CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    if not HasScaleformMovieLoaded(minimap) then
        RequestScaleformMovie(minimap)
        while not HasScaleformMovieLoaded(minimap) do
            Wait(1)
        end
    end
    while true do
        if w > 0 then
            BlackBars()
            DisplayRadar(0)
            SendNUIMessage({
                action = 'hudtick',
                show = false,
            })
            SendNUIMessage({
                action = 'car',
                show = false,
            })
        end
        Wait(0)
    end
end)

-- Compass
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num + 0.5 * mult)
end

local prevBaseplateStats = { nil, nil, nil, nil, nil, nil, nil}

local function updateBaseplateHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevBaseplateStats[k] ~= v then shouldUpdate = true break end
    end
    prevBaseplateStats = data
    if shouldUpdate then
        SendNUIMessage ({
            action = 'baseplate',
            show = data[1],
            street1 = data[2],
            street2 = data[3],
            showCompass = data[4],
            showStreets = data[5],
            showPointer = data[6],
            showDegrees = data[7],
        })
    end
end

local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}

local function getCrossroads(player)
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(player)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = { GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2) }
    end
    return lastCrossroadCheck
end

-- Compass Update loop

CreateThread(function()
	local lastHeading = 1
    local heading
	while true do
        if Menu.isChangeCompassFPSChecked then
            Wait(50)
        else
            Wait(0)
        end
        local show = true
        local player = PlayerPedId()
        local camRot = GetGameplayCamRot(0)
        if Menu.isCompassFollowChecked then
            heading = tostring(round(360.0 - ((camRot.z + 360.0) % 360.0)))
        else
            heading = tostring(round(360.0 - GetEntityHeading(player)))
        end
		if heading == '360' then
			heading = '0'
		end
		if heading ~= lastHeading then
			if IsPedInAnyVehicle(player) then
				local crossroads = getCrossroads(player)
				SendNUIMessage ({
					action = 'update',
					value = heading
				})
				updateBaseplateHud({
					show,
					crossroads[1],
					crossroads[2],
					Menu.isCompassShowChecked,
					Menu.isShowStreetsChecked,
					Menu.isPointerShowChecked,
					Menu.isDegreesShowChecked
				})
			else
				if Menu.isOutCompassChecked then
					SendNUIMessage ({
						action = 'update',
						value = heading
					})
					SendNUIMessage ({
						action = 'baseplate',
						show = true,
						showCompass = true,
					})
				else
					SendNUIMessage ({
						action = 'baseplate',
						show = false,
					})
				end
			end
		end
		lastHeading = heading
	end
end)
