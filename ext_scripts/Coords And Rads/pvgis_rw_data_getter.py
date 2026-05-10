from pvgis_api import PVGISClient, RadiationDatabase
import os

# Create a client
client = PVGISClient()

""" # SARAH3 - Europe, Africa, parts of Asia (2005-2020)
result = client.hourly_radiation(
    year=2023,
    lat=59.13342, lon=10.174096,
    peakpower=1.0, loss=0,
    radiation_db=RadiationDatabase.SARAH3,
    output_format="csv",
    optimal_angles=True
) """

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


for i in range(len(schools)):
    print(f"Getting radiation data for {schools[i]} at coords {coords[i]}...")
    result = client.hourly_radiation(
        year=2023,
        lat=coords[i][1], lon=coords[i][2],
        peakpower=1.0, loss=0,
        radiation_db=RadiationDatabase.SARAH3,
        output_format="csv",
        optimal_angles=True
    )

    os.makedirs('./radiation', exist_ok=True)
    
    with open(f'./radiation/{schools[i]}.csv', 'w',  newline="") as f:
        f.write(result['data'])

