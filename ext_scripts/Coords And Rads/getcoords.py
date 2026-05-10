from geopy.geocoders import Nominatim
import time, csv

#READ FROM A LIST OF SCHOOLS FROM TXT FILE
# INFILE REQUIRED: TXT FILE WITH SCHOOL NAMES, ONE PER LINE
INFILE = "SandefjordSkoler.txt"
#WRITE TO TXT FILE WITH SCHOOL NAME, LATITUDE, LONGITUDE
OUTFILE = "SandefjordSkolerCoords.txt"

schools = []
coords = []
city = "Sandefjord"
country = "Norway"

#create geolocator object with user agent and timeout
geolocator = Nominatim(
    user_agent="GetCoords",
    timeout=10,
    )

#read schools from file and append to list
with open(INFILE, "r", encoding="utf-8") as file:
    for line in file:
        schools.append(line.strip())

#location = geolocator.geocode("Bugården Ungdomsskole, Sandefjord, Norway")
print(f"Getting coords for buildings in {city}, {country}...")

#loop through schools and get coords, print progress
for school in schools:
    #create query string for geocoding
    query = (school + ", "+ city+ ", "+ country)
    print(query)
    #get location from geocoding
    location = geolocator.geocode(query)
    print(f"Location: lat:{location.latitude}, long:{location.longitude}")
    #append to coords list as [address, lat, long]
    coords.append([location,location.latitude, location.longitude]) 
    print("\n")
    #wait a bit to avoid hitting the rate limit of the geocoding service
    time.sleep(1.5)



print("Done getting coords.\n")
print("Writing to file...")


# write coords to file as csv with ; as delimiter
with open(OUTFILE, "w", encoding="utf-8",  newline="") as file:
    writer = csv.writer(file, delimiter=";")
    for i in range(len(schools)):
        # write for row: building address, latitude, longitude
        writer.writerow([coords[i][0], coords[i][1], coords[i][2]]) 

print("Done writing to file.")