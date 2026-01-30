------------------------------------------------
-- UTIL / NOTIFY
------------------------------------------------
local function notify(msg)
    TriggerEvent("chat:addMessage", {
        color = { 0, 200, 255 },
        args = { "[Fixit]", msg }
    })
end

------------------------------------------------
-- VEHICLE REPAIR SEQUENCE
------------------------------------------------
local function repairVehicleSequence(driver, vehicle, towVeh, towBlip)
    BringVehicleToHalt(towVeh, 3.0, 3000, false)
    Wait(2000)

    TaskLeaveVehicle(driver, towVeh, 0)
    local timeout = 0
    while IsPedInVehicle(driver, towVeh, false) and timeout < 25 do
        Wait(1000)
        timeout = timeout + 1
    end
	
    local vehCoords = GetEntityCoords(vehicle)
    local vehHeading = GetEntityHeading(vehicle)

    local forwardX = vehCoords.x + math.sin(math.rad(vehHeading)) * -3.0
    local forwardY = vehCoords.y + math.sin(math.rad(vehHeading)) * -0.5
    local forwardZ = vehCoords.z

    TaskGoStraightToCoord(
        driver,
        forwardX,
        forwardY,
        forwardZ,
        1.2,
        8000,
        vehHeading,
        0.5
    )

    Wait(20000)

    TaskTurnPedToFaceEntity(driver, vehicle, 1500)
    Wait(1500)

    SetVehicleDoorOpen(vehicle, 4, false, false)
    Wait(2000)

    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do Wait(0) end
    TaskPlayAnim(driver, "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)

    notify("🔧 Mechanic is repairing your vehicle...")

    local startPos = GetEntityCoords(vehicle)
    local elapsed = 0
    while elapsed < 30000 do
        Wait(500)
        elapsed = elapsed + 500

        if #(GetEntityCoords(vehicle) - startPos) > 5.0 then
            notify("❌ Repair cancelled (vehicle moved)")
            ClearPedTasks(driver)
            SetVehicleDoorShut(vehicle, 4, false)
            return
        end
    end

    ClearPedTasks(driver)
    SetVehicleFixed(vehicle)
    SetVehicleEngineHealth(vehicle, 1000.0)  					-- You can adjust this if you don't want the engine fully repaired!
    Wait(5000)
    SetVehicleBodyHealth(vehicle, 1000.0)						-- You can remove this or adjust it if you want!
    SetVehicleUndriveable(vehicle, false)
    SetVehicleDoorShut(vehicle, 4, false)

    notify("✅ Your vehicle has been repaired!")
	
	if DoesBlipExist(towBlip) then RemoveBlip(towBlip) end
end

------------------------------------------------
-- SPAWN NPC & TRUCK
------------------------------------------------
local function spawnTowTruck()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)

    local targetVeh = GetVehiclePedIsIn(ped, false)
    if targetVeh == 0 or not DoesEntityExist(targetVeh) then
        targetVeh = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 8.0, 0, 70)
    end

    if targetVeh == 0 then
        notify("❌ No vehicle to repair")
        return
    end

    local offset = vector3(
        math.random(Config.MinSpawnDistance, Config.MaxSpawnDistance) * (math.random(0,1) == 1 and 1 or -1),
        math.random(Config.MinSpawnDistance, Config.MaxSpawnDistance) * (math.random(0,1) == 1 and 1 or -1),
        0.0
    )

    local found, roadPos, roadHeading = GetClosestVehicleNodeWithHeading(
        playerCoords.x + offset.x,
        playerCoords.y + offset.y,
        playerCoords.z,
        1, 3.0, 0
    )

    notify("🔧 Mechanic has been notified...")
    Wait(15000)

    local spawnCoords = found and roadPos or (playerCoords + vector3(30.0, 0.0, 0.0))
    local heading = found and roadHeading or 0.0

    local vehicleModel = GetHashKey(Config.TowTruckModel)
    local pedModel = GetHashKey(Config.DriverPed)

    RequestModel(vehicleModel)
    RequestModel(pedModel)
    while not HasModelLoaded(vehicleModel) or not HasModelLoaded(pedModel) do Wait(0) end

    local towVeh = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, true)
    SetVehicleOnGroundProperly(towVeh)
    SetEntityAsMissionEntity(towVeh, true, true)
    SetVehicleHasBeenOwnedByPlayer(towVeh, true)

    local netId = NetworkGetNetworkIdFromEntity(towVeh)
    SetNetworkIdExistsOnAllMachines(netId, true)

    local towBlip = AddBlipForEntity(towVeh)
    SetBlipSprite(towBlip, 544)
    SetBlipColour(towBlip, 38)
    SetBlipScale(towBlip, 0.8)
    SetBlipAsShortRange(towBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Tow Truck")
    EndTextCommandSetBlipName(towBlip)

    local driver = CreatePedInsideVehicle(towVeh, 26, pedModel, -1, true, true)
    SetEntityAsMissionEntity(driver, true, true)
    SetBlockingOfNonTemporaryEvents(driver, true)
    SetPedKeepTask(driver, true)

    SetPedFleeAttributes(driver, 0, false)
    SetPedCombatAttributes(driver, 17, true)
    SetPedCombatAttributes(driver, 46, true)

    local vehCoords = GetEntityCoords(targetVeh)
    TaskVehicleDriveToCoordLongrange(
        driver,
        towVeh,
        vehCoords.x,
        vehCoords.y,
        vehCoords.z,
        Config.DriveSpeed,
        786603,
        8.0
    )

    notify("🚚 Mechanic en route, stay in your vehicle!")

    CreateThread(function()
        local arrived = false
        local elapsed = 0

        while not arrived and elapsed < 800000 do							-- Adjusting this too low will make everything in here stop working!
            Wait(500)
            elapsed = elapsed + 500

            if #(GetEntityCoords(towVeh) - GetEntityCoords(targetVeh)) <= 18.0 then
                arrived = true
            end
        end

        if arrived then
            SetVehicleEngineOn(towVeh, false, true, true)
            repairVehicleSequence(driver, targetVeh, towVeh, towBlip)

            TaskEnterVehicle(driver, towVeh, -1, -1, 1.0, 1, 0)
            Wait(3000)
            TaskVehicleDriveWander(driver, towVeh, Config.DriveSpeed, 786603)

            CreateThread(function()
                Wait(20000)
                if DoesEntityExist(driver) then DeleteEntity(driver) end
                if DoesEntityExist(towVeh) then DeleteEntity(towVeh) end
                if DoesBlipExist(towBlip) then RemoveBlip(towBlip) end
            end)
        else
            notify("❌ Tow truck could not reach you in time")
            if DoesEntityExist(driver) then DeleteEntity(driver) end
            if DoesEntityExist(towVeh) then DeleteEntity(towVeh) end
            if DoesBlipExist(towBlip) then RemoveBlip(towBlip) end
        end
    end)
end

------------------------------------------------
-- REGISTER CHAT COMMAND
------------------------------------------------
RegisterCommand("fixit", function()
    spawnTowTruck()
end, false)
