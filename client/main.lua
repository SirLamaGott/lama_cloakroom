local CurrentActionData = {}
local LastZone, CurrentAction, CurrentActionMsg
local HasLoadCloth, HasAlreadyEnteredMarker = false, false

function OpenMainMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_outfit', {
		css      = 'umkleide',
    	title    = 'Outfit',
    	align    = 'top-left',
    	elements = {
			{label = 'Outfit wechseln', name = 'change_outfit'},
			{label = 'Outfit löschen', name = 'delete_outfit'}
		},
    }, function(data, menu)
	menu.close()

    if data.current.value == 'change_outfit' then
    	ESX.TriggerServerCallback('lama_cloackroom:getPlayerDressing', function(dressing)
        	local elements = {}

			--[[
        	for i=1, #dressing, 1 do
        		table.insert(elements, {label = dressing[i], value = i})
        	end --]]
			for i=1, #dressing, 1 do
				elements[#elements + 1] = {
					title = dressing[i],
					value = i
				}
			end

        	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'switch_outfit', { 
				css      = 'umkleide',
            	title    = 'Outfit Wechseln',
            	align    = 'top-left',
            	elements = elements,
            }, function(data, menu)
            	TriggerEvent('skinchanger:getSkin', function(skin)
            		ESX.TriggerServerCallback('lama_cloackroom:getPlayerOutfit', function(clothes)
                		TriggerEvent('skinchanger:loadClothes', skin, clothes)
                		TriggerEvent('esx_skin:setLastSkin', skin)

                		TriggerEvent('skinchanger:getSkin', function(skin)
                			TriggerServerEvent('esx_skin:save', skin)
                		end)
				  
						ESX.ShowNotification('Kleidung geändert.')
						HasLoadCloth = true
                	end, data.current.value)
              	end)
            end, function(data, menu)
            menu.close()
			  
			CurrentAction     = 'main_action'
			CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
			CurrentActionData = {}
    		end)	
        end)
    end
	  
	if data.current.value == 'delete_outfit' then
		ESX.TriggerServerCallback('lama_cloackroom:getPlayerDressing', function(dressing)
			local elements = {}

			--[[
			for i=1, #dressing, 1 do
				table.insert(elements, {label = dressing[i], value = i})
			end --]]

			for i=1, #dressing, 1 do
				elements[#elements + 1] = {
					title = dressing[i],
					value = i
				}
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove_outfit', {
				css      = 'umkleide',
            	title    = 'Outfit Löschen',
            	align    = 'top-left',
            	elements = elements,
            }, function(data, menu)
			menu.close()

			TriggerServerEvent('lama_cloackroom:deleteOutfit', data.current.value)	
			ESX.ShowNotification('Outfit gelöscht.')

            end, function(data, menu)
            menu.close()
			  
		 	CurrentAction     = 'main_action'
			CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
			CurrentActionData = {}
            end)
		end)
	end

	end, function(data, menu)
	menu.close()

    CurrentAction     = 'main_action'
    CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
    CurrentActionData = {}

    end)
end


AddEventHandler('lama_cloackroom:hasEnteredMarker', function(zone)
	CurrentAction     = 'shop_menu'
	CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
	CurrentActionData = {}
end)


AddEventHandler('lama_cloackroom:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

	if not HasLoadCloth then 
		TriggerEvent('esx_skin:getLastSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin) 
		end)
	end
end)


-- Display markers
CreateThread(function()
	while true do
		local Sleep = 2000

		Sleep = 500
		local coords, letSleep = GetEntityCoords(PlayerPedId()), true

		for k,v in pairs(Config.Zones) do
			if Config.MarkerType ~= -1 and #(coords - v.Pos) < Config.DrawDistance then
				Sleep = 0
				DrawMarker(Config.MarkerType, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
				letSleep = false
			end
		end		
	Wait(Sleep)
	end
end)

-- Enter / Exit marker events
CreateThread(function()
	while true do
		local Sleep = 500
		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if(#(coords - v.Pos) < Config.MarkerSize.x) then
				Sleep = 0
				isInMarker  = true
				currentZone = 'main_action'
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('lama_cloackroom:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('lama_cloackroom:hasExitedMarker', LastZone)
		end
		
	Wait(Sleep)
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
	local sleep = 500

		if CurrentAction then
			sleep = 0
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlPressed(0,  38) then
				if CurrentAction == 'main_action' then
					OpenMainMenu()
				end
				CurrentAction = nil
			end
		end

	Wait(sleep)
	end
end)
