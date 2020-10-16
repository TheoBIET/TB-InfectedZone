--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
------------     Pour commencer n'oubliez pas de remercier íʍƊɑѵƊɑѵ#9351 pour ce script  ---------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Placez ici les zones que vous souhaitez infecter
-- Pour changer le rayon de la zone, allez au ligne 44, 107 et 153 tout ce que vous mettrez ici sera doublé, c'est un cercle donc 50 résulte d'un diamètre de 100 (Je ne connais pas l'unité de mesure)
local zones = {
    {
        title = "~p~Zone infectée",
        colour = 40,                -- Pour configurer la couleur blips jetez un oeil à https://wiki.rage.mp/index.php?title=Blips
        id = 84,                    -- Pour configurer l'ID du blips jetez un oeil à https://wiki.rage.mp/index.php?title=Blips
        x = -231.04,    
        y = -387.12,
        z = 30.4
    }
}

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-------                                 Création d'un blip sur la Map 	   						--------------
-------     Vous pouvez commenter cette section si vous ne souhaitez pas afficher de blips      --------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    Citizen.Wait(0)

    local bool = true

    if bool then

        for k, v in pairs(zones) do
            zoneblip = AddBlipForRadius(v.x, v.y, v.z, 2500.0)
            SetBlipHighDetail(blip, true)
            SetBlipColour(zoneblip, 437)
            SetBlipAlpha(zoneblip, 90)
        end

        for _, info in pairs(zones) do
            info.blip = AddBlipForCoord(info.x, info.y, info.z)
            SetBlipSprite(info.blip, info.id)
            SetBlipDisplay(info.blip, 4)
            SetBlipScale(info.blip, 0.7)
            SetBlipColour(info.blip, info.colour)
            SetBlipAsShortRange(info.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(info.title)
            EndTextCommandSetBlipName(info.blip)
        end
        bool = false
    end
end)

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
----------------   Récupération de la distance vous séparant de l'une des zones  -----------------------------
----------------           (Vous n'avez probablement pas besoin d'y toucher      -----------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Citizen.Wait(0) end

    while true do
        local playerPed = GetPlayerPed(-1)
        local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
        local minDistance = 100000
        for i = 1, #zones, 1 do
            dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
            if dist < minDistance then
                minDistance = dist
                closestZone = i
            end
        end
        Citizen.Wait(15000)
    end
end)

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
------------------	Envoi d'une notification à l'entrée/sortie de la zone infectée		  --------------------
------------------        	Activation / Désactivation des effets à l'écran    	    	  --------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Citizen.Wait(0) end

    while true do
        Citizen.Wait(0)
        local player = GetPlayerPed(-1)
        local x, y, z = table.unpack(GetEntityCoords(player, true))
        local dist = Vdist(zones[closestZone].x, zones[closestZone].y,
                           zones[closestZone].z, x, y, z)

        if dist <= 2500.0 then
            StartScreenEffect('DeathFailNeutralIn', 0, true)
            if not notifIn then
                TriggerEvent("pNotify:SendNotification", {
                    text = "<b style='color:#fff'>Attention, vous êtes dans un zone infectée.</b>",
                    type = "error",
                    timeout = (3000),
                    layout = "bottomcenter",
                    queue = "global"
                })
                notifIn = true
                notifOut = false
            end
        else
            StopScreenEffect('DeathFailNeutralIn', 0, true)
            if not notifOut then
                TriggerEvent("pNotify:SendNotification", {
                    text = "<b style='color:#fff'>Vous sortez de la zone d'infection.</b>",
                    type = "success",
                    timeout = (3000),
                    layout = "bottomcenter",
                    queue = "global"
                })
                notifOut = true
                notifIn = false
            end
        end
    end
end)

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------	Verifie si vous portez un masque et augmente le taux de radiation en conséquence	  ------------
--------	                        Si vous êtes en dehors de la zone	                          ------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Citizen.Wait(0) end

    while true do
        Citizen.Wait(0)
        local player = GetPlayerPed(-1)
        local x, y, z = table.unpack(GetEntityCoords(player, true))
        local dist = Vdist(zones[closestZone].x, zones[closestZone].y,
                           zones[closestZone].z, x, y, z)

        if dist <= 2500.0 then
            local maskIndex = GetPedDrawableVariation(player, 1)
            local source = _source
            -- Vérifie si vous portez un masque à gaz (Les numéros correspondent aux ID des masques, en l'occurence ce sont des masques à gaz, mais cela peut varier selon les serveurs et les tenues moddées présentes)              
            if maskIndex == 129 or maskIndex == 130 or maskIndex == 166 then
                Citizen.Wait(10000)
                -- Quantité de résistance à la radiation à retirer toutes les 10 secondes avec un masque                           
                TriggerEvent('esx_status:remove', 'bionaz', 10000)
            else
                Citizen.Wait(10000)
                -- Quantité de résistance à la radiation à retirer toutes les 10 secondes sans masque 
                TriggerEvent('esx_status:remove', 'bionaz', 5000)
            end
        else 
            TriggerEvent('esx_status:getStatus', 'bionaz', function(status)
                while status.val < 1000000 do
                    Citizen.Wait(10000)
                    TriggerEvent('esx_status:add', 'bionaz', 5000)
                end
			end)
        end
    end
end)

