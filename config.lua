Config = {}

Config.DrawDistance = 20.0
Config.MarkerSize   = {x = 0.5, y = 0.5, z = 0.35}
Config.MarkerColor  = {r = 255, g = 255, b = 23}
Config.MarkerType   = 21

Config.Zones = {}

Config.Umkleiden = {
  {x = 463.22,   y = -996.36,  z = 30.5},
  {x = 74.67,    y = -1970.99, z = 19.77},
  {x = -160.90,  y = -1638.56, z = 33.02},
  {x = -18.15,   y = -1439.02, z = 30.10},
  {x = 8.45,   	 y = 528.58,   z = 169.63},
  {x = 103.83,   y = -1301.6,  z = 27.77},
  {x = -1526.04, y = 832.65,   z = 180.59},
  {x = -1595.11, y = 2102.05,  z = 68.3},
  
 }

for i=1, #Config.Umkleiden, 1 do

	Config.Zones['Umkleide_' .. i] = {
	 	Pos   = Config.Umkleiden[i],
	 	Size  = Config.MarkerSize,
	 	Color = Config.MarkerColor,
	 	Type  = Config.MarkerType
  }

end
