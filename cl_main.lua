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
        colour = 40, -- Pour configurer la couleur blips jetez un oeil à https://wiki.rage.mp/index.php?title=Blips
        id = 84, -- Pour configurer l'ID du blips jetez un oeil à https://wiki.rage.mp/index.php?title=Blips
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
------------------  	Envoi d'une notification à l'entrée/sortie de la zone infectée    --------------------
------------------        	Activation / Désactivation des effets à l'écran    	    	  --------------------
------------------        	    Gestion de la résistance si masque ou non   	    	  --------------------
------------------        	        Animation "toux" si pas de masque            	      --------------------
------------------        	    Récupération de la résistance en sortie de zone     	  --------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Citizen.Wait(0) end

    while true do
        Citizen.Wait(0)
        local player = GetPlayerPed(-1)
        local x, y, z = table.unpack(GetEntityCoords(player, true))
        -----------------------------------------------------------------------------------------------------------
        -- Récupération de la distance vous séparant de la zone (Vous n'avez probablement pas besoin d'y toucher)--
        -----------------------------------------------------------------------------------------------------------
        local minDistance = 100000
        for i = 1, #zones, 1 do
            dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
            if dist < minDistance then
                minDistance = dist
                closestZone = i
            end
        end
        -----------------------------------------------------------------------------------------------------------
        -----------------------------------------------------------------------------------------------------------
        -----------------------------------------------------------------------------------------------------------
        local dist = Vdist(zones[closestZone].x, zones[closestZone].y,
                           zones[closestZone].z, x, y, z)
        local seconds = 1000
        if dist <= 2500.0 then
            if not notifIn then
                StartScreenEffect('DeathFailNeutralIn', 0, true)
                ESX.ShowNotification(
                    "~r~Attention, vous entrez dans une zone infectée, n'y laisser pas votre peau")
                ESX.ShowNotification("HRP: Vous risquez la mort RP")
                notifIn = true
                notifOut = false
            end
            local maskIndex = GetPedDrawableVariation(player, 1)
            -- Vérifie si vous portez un masque à gaz (Les numéros correspondent aux ID des masques, en l'occurence ce sont des masques à gaz, mais cela peut varier selon les serveurs et les tenues moddées présentes)              
            if maskIndex == 129 or maskIndex == 130 or maskIndex == 166 then
                -- Quantité de résistance à la radiation à retirer toutes les 10 secondes avec un masque                       
                TriggerEvent('esx_status:remove', 'bionaz', 10000) -- Je retire 10000 de résistance sur 1 million toutes les 10 secondes (~16 minutes)
                Citizen.Wait((seconds * 10))
            else
                -- Si la personne n'a pas de masque, alors elle toussera et perdra plus de résistance
                RequestAnimDict("timetable@gardener@smoking_joint")
                while not HasAnimDictLoaded("timetable@gardener@smoking_joint") do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(player, "timetable@gardener@smoking_joint",
                             "idle_cough", 8.0, 8.0, -1, 50, 0, false, false,
                             false)
                Citizen.Wait((seconds * 5))
                ClearPedTasks(player)
                -- Quantité de résistance à la radiation à retirer toutes les 10 secondes sans masque 
                TriggerEvent('esx_status:remove', 'bionaz', 20000) -- Je retire 20000 de résistance sur 1 million toutes les 10 secondes (~8 minutes)
                Citizen.Wait((seconds * 5))
            end
        else
            StopScreenEffect('DeathFailNeutralIn', 0, true)
            ClearPedTasks(player)
            if not notifOut then
                ESX.ShowNotification("~g~Vous sortez de la zone infectée")
                notifOut = true
                notifIn = false
            end
            -- Une fois la personne sortie de la zone infectée, celle-ci récupère peu à peu sa résistance aux radiations
            Citizen.Wait((seconds * 3))
            ClearPedTasks(player)
            TriggerEvent('esx_status:add', 'bionaz', 3000) -- Je rajoute 10000 de résistance sur 1 million toutes les 3 secondes (~5 minutes)
        end
    end
end)

