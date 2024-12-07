import json
from datetime import datetime, timedelta
import numpy as np
import matplotlib.pyplot as plt
from geopy.distance import geodesic
from scipy.interpolate import interp1d

# Funktion zum Interpolieren der Positionen
def interpolate_positions(groundtruth, interval=1):
    for point in groundtruth:
        pass
        #print(f"Timestamp: {point['timestamp']} (Type: {type(point['timestamp'])})")
        print(f"Lat: {point['position']['latitude']} (Type: {type(point['timestamp'])})")
        print(f"Long: {point['position']['longitude']} (Type: {type(point['timestamp'])})")
    times = [datetime.fromisoformat(point['timestamp']) for point in groundtruth]
    latitudes = [point['position']['latitude'] for point in groundtruth]
    longitudes = [point['position']['longitude'] for point in groundtruth]

    # Sekundenintervalle festlegen
    start_time = times[0]
    end_time = times[-1]
    total_seconds = int((end_time - start_time).total_seconds())
    new_times = [start_time + timedelta(seconds=i) for i in range(total_seconds + 1)]

    # Interpolation der 
    lat_interp = interp1d([(t - start_time).total_seconds() for t in times], latitudes, kind='linear')
    lon_interp = interp1d([(t - start_time).total_seconds() for t in times], longitudes, kind='linear')

    interpolated_positions = [
        {'latitude': lat_interp((t - start_time).total_seconds()),
         'longitude': lon_interp((t - start_time).total_seconds()),
         'timestamp': t.isoformat()}  # Zeitstempel für jede interpolierte Position
        for t in new_times
    ]

    return interpolated_positions, new_times

# CDF-Berechnung
def calculate_position_error(interpolated_positions, recorded_positions):
    errors = []
    for rec_point in recorded_positions:
        rec_time = datetime.fromisoformat(rec_point['timestamp'])
        rec_pos = (rec_point['position']['latitude'], rec_point['position']['longitude'])

        # Finde die interpolierte Position mit dem nächsten Zeitstempel
        #print(interpolated_positions)
        #nearest_time_idx = min(range(len(interpolated_positions)), key=lambda i: abs(interpolated_positions[i]['timestamp'] - rec_time))
        nearest_time_idx = min(
        range(len(interpolated_positions)),
        key=lambda i: abs((datetime.fromisoformat(interpolated_positions[i]["timestamp"]) - rec_time).total_seconds())
        )

        groundtruth_pos = (
            interpolated_positions[nearest_time_idx]['latitude'],
            interpolated_positions[nearest_time_idx]['longitude']
        )
        #print(groundtruth_pos)

        # Berechne den Fehler
        error = geodesic(groundtruth_pos, rec_pos).meters
        errors.append(error)

    return errors

# Erstellung des CDF-Grafen und berechnung des konfidenzlevels
def plot_cdf(errors, title='CDF of Position Errors'):
    sorted_errors = np.sort(errors)
    cdf = np.arange(1, len(sorted_errors) + 1) / len(sorted_errors)

    # CDF
    plt.figure(figsize=(8, 6))
    plt.plot(sorted_errors, cdf, label="CDF")
    plt.xlabel("Positionierungsfehler (m)")
    plt.ylabel("CDF")
    plt.title(title)
    plt.grid()
    plt.show()

    # Konfidenzlevel berechnen
    conf_50 = np.percentile(sorted_errors, 50)
    conf_95 = np.percentile(sorted_errors, 95)
    return conf_50, conf_95

# JSON-Daten laden
with open('graph\output3.json', 'r') as file:
    data = json.load(file)


# Groundtruth-Daten richtig verarbeiten
#groundtruth = [
#    {"position": {"latitude": point["coordinates"][1], "longitude": point["coordinates"][0]}, "timestamp": None}
#    for point in data[2]
#]
#print(groundtruth)

groundtruth = [
    {
        "position": {"latitude": point["coordinates"][1], "longitude": point["coordinates"][0]},
        "timestamp": data[0][i]["timestamp"]  # Timestamps aus data[0] verwenden
    }
    for i, point in enumerate(data[2])
]

# Groundtruth ausgeben
#print(groundtruth)

recorded_positions = data[:2]

# Interpolieren der Groundtruth-Daten
interpolated_positions, interpolated_times = interpolate_positions(groundtruth)

# CDF-Berechnung fuer alle Varianten
for idx, variant in enumerate(recorded_positions):
    errors = calculate_position_error(interpolated_positions, variant)
    conf_50, conf_95 = plot_cdf(errors, title=f"CDF der Positionierungsfehler {idx + 1}")
    print(f"Konfidenzlevel (50%): {conf_50:.2f} m, (95%): {conf_95:.2f} m")

# Darstellung der PFade
def plot_paths(groundtruth, recorded_positions):
    plt.figure(figsize=(10, 8))

    # Groundtruth
    gt_lat = [point['latitude'] for point in groundtruth]
    gt_lon = [point['longitude'] for point in groundtruth]
    plt.plot(gt_lon, gt_lat, label="Groundtruth", marker="o")

    # Aufgezeichnete Positionen
    for idx, variant in enumerate(recorded_positions):
        rec_lat = [point['position']['latitude'] for point in variant]
        rec_lon = [point['position']['longitude'] for point in variant]
        plt.plot(rec_lon, rec_lat, label=f"Recorded Variant {idx + 1}", linestyle="--")

    plt.xlabel("Longitude")
    plt.ylabel("Latitude")
    plt.title("Position Comparison")
    plt.legend()
    plt.grid()
    plt.show()

plot_paths(interpolated_positions, recorded_positions)
