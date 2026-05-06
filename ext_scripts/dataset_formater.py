import csv
from datetime import date, timedelta

## Declaring which wiles we will be working with
EXR_FILE: str = "EXR.csv" #Exchange rate csv collected from https://www.norges-bank.no/en/topics/Statistics/exchange_rates/?tab=currency&id=EUR
PRICE_FILE: str = "PRICES.csv" #Power prices collected from ENTSO‑E Transparency Platform: https://transparency.entsoe.eu/market/energyPrices?permalink=69ef4592bf132d2aaeeb053a under the Creative Commons Attribution 4.0 International License
OUTPUT: str = "PowerPrices.csv" #File to output the results to


def print_dict(obj: dict) -> None:
    ### Function to print the dict in a more readable format. Debugging only
    for key in obj.keys():
        print(key, " --- ", obj[key])

exr_by_date = {} #Exchange rate of EUR to NOK for each date of the year
current_date = date(2025, 1, 1)
end_date = date(2025, 12, 31)

# Populate the exr_by_date dict with temporary data
while current_date <= end_date:
    exr_by_date[current_date.isoformat()] = 0
    current_date += timedelta(days=1)

with open(EXR_FILE, 'r') as file:
    csvreader = csv.reader(file, delimiter=';')
    skip_first = True #Skips the first line as this does not contain any actual data
    for row in csvreader:
        if skip_first:
            skip_first = False
            continue

        date = row[-2] #The date is in the second to last column
        rate = row[-1] #The exchange rate is in the last column
        exr_by_date[date] = float(rate)

def fix_exr_dict(obj: dict) -> None:
    # The exchange rate dataset has missing data for some dates, 
    #   to remedy this it fills in the exhange rate of the previous day when empty
    
    #Due to python weirdness, obj is the same object as the inputet dict, 
    #   making this func apply changes in place

    keys: list = []
    for key in obj.keys():
        keys.append(key)
    for i in range(len(keys)):
        #print(i, " --- ", keys[i], " --- ", obj[keys[i]])
        if i == 0 and obj[keys[i]] == 0: #If the first date is missing, use the next day data
            obj[keys[i]] = obj[keys[i+1]]
        if obj[keys[i]] == 0: #if exr is missing, use previous day data
            obj[keys[i]] = obj[keys[i-1]]
    #return obj
fix_exr_dict(exr_by_date)


prices_eur: list = [] #Array containing all the prices in EUR, before any processing is done. In a 15minute resolution
with open(PRICE_FILE, 'r') as file:
    csvreader = csv.reader(file, delimiter=',')
    skip_first = True
    for row in csvreader:
        if skip_first:
            skip_first = False
            continue
        prices_eur.append(row[3])

#The power prices dataset were given in a mix of hourly and quarter hourly resolution, fixes it to be consistent under
prices: list = [] #Array containing all the prices averaged for per hour resolution
for i in range(0, len(prices_eur), 4):
    added: float = 0.0
    divide: int = 0
    for j in range(4):
        if j+i >= len(prices_eur): break
        #print(prices_raw[i+j])
        added += float(prices_eur[i+j])
        divide += 1
    #print("Avg: ", added/divide)
    prices.append(round(added/divide, 2))


final_prices: list = [] #Final prices in øre/Wh
keys: list = []
for key in exr_by_date.keys():
    keys.append(key)

for i, price in enumerate(prices):
    #Price = EUR/MWh
    #print(i, price, i // 24)
    final_prices.append(price * exr_by_date[keys[i//24]] * 100 / 1_000_000) #øre/Wh
                                          # * NOK -> Øre / MWh -> Wh


#Writes the data into the OUT file
if True: #if statement for debugging
    with open(OUTPUT, "w") as file:
        writer = csv.writer(file, delimiter=';')
        for i in range(len(final_prices)):
            writer.writerow([keys[i//24], i%24, final_prices[i]]) #Date, Hour, øre/Wh

