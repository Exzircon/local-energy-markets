from pvgis_api import PVGISClient, RadiationDatabase, OutputFormat
import os

# Create a client
client = PVGISClient()

INSCHOOL = "SandefjordSkoler.txt"
INCOORDS = "SandefjordSkolerCoords.txt"
schools = []
coords = []

with open(INSCHOOL, "r", encoding="utf-8") as file:
    for line in file:
        schools.append(line.strip())

with open(INCOORDS, "r", encoding="utf-8") as file:
    for line in file:
        address, lat, lon = line.strip().split(';')
        coords.append([address, float(lat), float(lon)])

params = {
    'lat': 0, #Lat and lon to be overwritten later
    'lon': 0,
    'year': 2023, #2023 is newest available data
    'pvcalculation': 1, #Needed to get power calculation
    'peakpower': 1, #Set to one so we can scale it in Godot
    'loss': 0, #Set to zero so we can scale it in Godot
    'components': 0, #Unsused
    'raddatabase': RadiationDatabase.SARAH3, #Database for Europe
    'outputformat': OutputFormat.CSV,
    'optimalangles': 1 #Automatically optizime solar panel angle and azimuth
}



for i in range(len(schools)):
    print(f"Getting radiation data for {schools[i]} at coords {coords[i]}...")
    params["lat"] = coords[i][1]
    params["lon"] = coords[i][2]
    result = client._make_request("seriescalc", params)
    os.makedirs('./radiation', exist_ok=True)
    
    with open(f'./radiation/{schools[i]}.csv', 'w',  newline="") as f:
        f.write(result['data'])
