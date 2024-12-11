from datetime import datetime
from scipy.interpolate import interp1d
import numpy as np
import json
import requests

url = [
    "http://85.215.67.153:3001/py"
    ]

data = [
    [
        {"position": {"latitude": 51.4814085, "longitude": 7.2052173}, "timestamp": "2024-12-07T11:09:07.072027"},
        {"position": {"latitude": 51.4802119, "longitude": 7.2029687}, "timestamp": "2024-12-07T11:09:52.083133"},
        {"position": {"latitude": 51.4807671, "longitude": 7.2024472}, "timestamp": "2024-12-07T11:10:25.618541"},
        {"position": {"latitude": 51.4809144, "longitude": 7.2016653}, "timestamp": "2024-12-07T11:11:08.384155"},
        {"position": {"latitude": 51.4812272, "longitude": 7.2014786}, "timestamp": "2024-12-07T11:12:17.191753"},
        {"position": {"latitude": 51.4821797, "longitude": 7.2008703}, "timestamp": "2024-12-07T11:13:14.192242"},
        {"position": {"latitude": 51.4828809, "longitude": 7.2011395}, "timestamp": "2024-12-07T11:14:56.284824"},
        {"position": {"latitude": 51.48156, "longitude": 7.2001502}, "timestamp": "2024-12-07T11:15:45.028200"},
        {"position": {"latitude": 51.4810599, "longitude": 7.200564}, "timestamp": "2024-12-07T11:16:22.273152"},
        {"position": {"latitude": 51.4809319, "longitude": 7.2014866}, "timestamp": "2024-12-07T11:16:45.776228"},
        {"position": {"latitude": 51.4806924, "longitude": 7.2014409}, "timestamp": "2024-12-07T11:17:24.526868"},
        {"position": {"latitude": 51.4809222, "longitude": 7.1977905}, "timestamp": "2024-12-07T11:18:58.023"},
        {"position": {"latitude": 51.4798618, "longitude": 7.1984394}, "timestamp": "2024-12-07T11:19:34.628313"},
        {"position": {"latitude": 51.4795498, "longitude": 7.2005655}, "timestamp": "2024-12-07T11:20:54.196339"},
        {"position": {"latitude": 51.4798618, "longitude": 7.2006328}, "timestamp": "2024-12-07T11:21:55.733151"}
    ],
    [
        {"coordinates": [7.202850328508449, 51.480203822002565]},
        {"coordinates": [7.202435007770543, 51.48076764667677]},
        {"coordinates": [7.201738155388343, 51.48088930512144]},
        {"coordinates": [7.201465777417864, 51.48133883841012]},
        {"coordinates": [7.200705672638127, 51.482144504413775]},
        {"coordinates": [7.200918315327095, 51.4828905852812]},
        {"coordinates": [7.199891664423626, 51.481571400881414]},
        {"coordinates": [7.200575895857488, 51.481080479995775]},
        {"coordinates": [7.201473219598438, 51.480880414127476]},
        {"coordinates": [7.201366227168291, 51.48054035835537]},
        {"coordinates": [7.2005309121852115, 51.48033582995885]},
        {"coordinates": [7.198481393416557, 51.479863180221066]},
        {"coordinates": [7.198946257135974, 51.47956371014744]},
        {"coordinates": [7.200765998275842, 51.4799782064199]},
        {"coordinates": [7.202084777871267, 51.48027861195343]}
    ]
]
measured_data = data[0]
groundtruth = data[1]

#Zeit in Sekunden umrechnen
def timestamp_to_seconds(timestamp):
    dt = datetime.fromisoformat(timestamp)
    #print(dt.timestamp())
    return dt.timestamp()

#Interpolierte Position mittels der Groundtruth
def interpolate_groundtruth(query_time):
    query_seconds = timestamp_to_seconds(query_time)

    # Hole die Indizes der Groundtruth-Koordinaten
    groundtruth_timestamps = np.linspace(0, 1, len(groundtruth))  # Normalisierte Zeit zwischen den Punkten
    groundtruth_lats = [entry["coordinates"][1] for entry in groundtruth]
    groundtruth_lons = [entry["coordinates"][0] for entry in groundtruth]
    #print(groundtruth_timestamps)
    #print(groundtruth_lons)
    #print(groundtruth_lats)

    #Funktionen für Interpolation erstellen
    lat_interp = interp1d(groundtruth_timestamps, groundtruth_lats, kind="linear", fill_value="extrapolate")
    lon_interp = interp1d(groundtruth_timestamps, groundtruth_lons, kind="linear", fill_value="extrapolate")

    # Mappe den query_seconds-Wert auf den Normalisierten Bereich (0, 1)
    measured_start = timestamp_to_seconds(measured_data[0]["timestamp"])
    measured_end = timestamp_to_seconds(measured_data[-1]["timestamp"])
    query_normalized = (query_seconds - measured_start) / (measured_end - measured_start)
    #print(measured_start)
    #print(measured_end)
    #print(query_normalized)


    # Interpolierte Werte abrufen
    interpolated_lat = lat_interp(query_normalized)
    interpolated_lon = lon_interp(query_normalized)

    return {"latitude": interpolated_lat, "longitude": interpolated_lon}

#Von 2024-12-07T11:09:10
#Bis 2024-12-07T11:21:50
query_time = "2024-12-07T11:09:50"

result = interpolate_groundtruth(query_time)
print(f"Interpolierte Position (Groundtruth) für {query_time}: {result}")

data = {
    "lat" : np.array(result['latitude']).item(),
    "long" : np.array(result['longitude']).item()
}

response = requests.post(url[0], json=data)

print(response.status_code)