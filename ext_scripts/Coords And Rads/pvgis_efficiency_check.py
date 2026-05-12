import os, csv

path: str = "./radiation"

data: list = []



for f in os.scandir(path):
    if f.is_file():
        if ".import" in f.name: continue
        with open(f.path, "r") as file:
            csvreader = csv.reader(file, delimiter=",")
            skip_first = True
            total_produced: float = 0.0
            for row in csvreader:
                if len(row) < 7: continue
                if skip_first:
                    skip_first = False
                    continue
                total_produced += float(row[1])
            data.append([f.name, total_produced])


best_schools: list = []
amount: int = 28

for i in range(len(data)):
    best_idx: int = -1
    best_score: float = 0
    for j in range(len(data)):
        if data[j][1] > best_score:
            best_score = data[j][1]
            best_idx = j
    best_schools.append(data.pop(best_idx))
print(best_schools)


with open("pvgis_canditate_rankings.csv", "w") as file:
    csvwriter = csv.writer(file, delimiter=";")
    for row in best_schools:
       csvwriter.writerow(row)
