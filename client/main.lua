
local GUI, CurrentActionData = {}, {}
GUI.Time = 0
local LastZone, CurrentAction, CurrentActionMsg
local HasPayed, HasLoadCloth, HasAlreadyEnteredMarker = false, false, false

function OpenShopMenu()
  local elements = {}

  table.insert(elements, {label = 'Outfit wechseln', value = 'player_dressing'})
  table.insert(elements, {label = 'Outfit löschen',  value = 'suppr_cloth'}) 

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_main', {
	  css      = 'umkleide',
      title    = 'Outfit',
      align    = 'top-left',
      elements = elements,
    }, function(data, menu)
	menu.close()

      if data.current.value == 'player_dressing' then
		
        ESX.TriggerServerCallback('lama_umkleide:getPlayerDressing', function(dressing)
          local elements = {}

          for i=1, #dressing, 1 do
            table.insert(elements, {label = dressing[i], value = i})
          end

          ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
			  css      = 'umkleide',
              title    = 'Outfit Wechseln',
              align    = 'top-left',
              elements = elements,
            }, function(data, menu)

              TriggerEvent('skinchanger:getSkin', function(skin)

                ESX.TriggerServerCallback('lama_umkleide:getPlayerOutfit', function(clothes)

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
			  
			  CurrentAction     = 'shop_menu'
			  CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
			  CurrentActionData = {}
            end
          )
        end)
      end
	  
	  if data.current.value == 'suppr_cloth' then
		ESX.TriggerServerCallback('lama_umkleide:getPlayerDressing', function(dressing)
			local elements = {}

			for i=1, #dressing, 1 do
				table.insert(elements, {label = dressing[i], value = i})
			end
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'supprime_cloth', {
			  css      = 'umkleide',
              title    = 'Outfit Löschen',
              align    = 'top-left',
              elements = elements,
            }, function(data, menu)
			menu.close()
				TriggerServerEvent('lama_umkleide:deleteOutfit', data.current.value)
				  
				ESX.ShowNotification('Outfit gelöscht.')

            end, function(data, menu)
              menu.close()
			  
			  CurrentAction     = 'shop_menu'
			  CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
			  CurrentActionData = {}
            end)
		end)
	  end
    end, function(data, menu)

      menu.close()

      CurrentAction     = 'room_menu'
      CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
      CurrentActionData = {}
    end)
end

AddEventHandler('lama_umkleide:hasEnteredMarker', function(zone)
	CurrentAction     = 'shop_menu'
	CurrentActionMsg  = 'Drücke ~INPUT_CONTEXT~ um den ~b~Kleiderschrank~s~ zu öffnen'
	CurrentActionData = {}
end)

AddEventHandler('lama_umkleide:hasExitedMarker', function(zone)
	
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil

	if not HasPayed then
		if not HasLoadCloth then 

			TriggerEvent('esx_skin:getLastSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		end
	end
end)


-- Display markers
Citizen.CreateThread(function()
	while true do

		Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Wait(0)

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('lama_umkleide:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('lama_umkleide:hasExitedMarker', LastZone)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  38) and (GetGameTimer() - GUI.Time) > 300 then

				if CurrentAction == 'shop_menu' then
					OpenShopMenu()
				end

				CurrentAction = nil
				GUI.Time      = GetGameTimer()
			end
		end
	end
end)
