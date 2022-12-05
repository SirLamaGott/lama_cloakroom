# lama_umkleide
Video Showcase: https://youtu.be/s-zm63A5rJE

# Lama - Cloakroom
Let your players change their saved clothes. It works with ESX, **no QBCore** integration anytime soon! Almost everything is configurable trough the Config.

# Requirements
- ESX **1.1 or higher** *(if you add the fix at the bottom)*
- oxmysql

# Features
- Easy Config
- Save/delete Otufits
- Comes with 14 points
- Comes with 2 languages (de, en)
- Optimized

# Installation
1. Install all the requirements
2. Clone the repository
3. Extract the zip in your resources folder
4. Rename from lama_cloakroom-master to lama_cloakroom
5. Modify the config to your liking
6. Done!

# ESX 1.1 & 1.2 Fix
Add this to top of the client:
```
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)
```

Add this to the top of the server:
```
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
```
Remove this from the fxmanifest: 
``shared_script '@es_extended/imports.lua'``
