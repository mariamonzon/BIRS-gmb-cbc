import pandas as pd
from datetime import timedelta

# Define the date format
date_format = '%Y-%m-%dT%H:%M:%SZ'

filepath = "data/GBM_longitutinal_data_CBC.csv"
date_columns = ['date_initial_cbc', 'date_recurrence_cbc', 'ord_proc_dttm', 'ord_rslt_dttm']

# Load the dataset
data = pd.read_csv(filepath)
target = 'lymphp'
data = data.dropna(subset=[target])
time_threshold = timedelta(days=30)


# Convert date columns to datetime format
for col in date_columns:
    data[col] = pd.to_datetime(data[col], format=date_format, errors='coerce')

data['date_surgery'] = pd.to_datetime(data['date_surgery'], errors='coerce')
# Define a time window of 1 month (30 days) after the recurrence date

# Filter the dataset to keep data points up to 1 month after the recurrence date
filtered_data = data[data['ord_proc_dttm'] <= (data['date_recurrence_cbc'] + time_threshold)]

# Save the filtered dataset to a new CSV file
output_path =  "data/GBM_longitutinal_data_CBC_trimmed.csv"
filtered_data.to_csv(output_path, index=False)

print(f"Filtered dataset saved to {output_path}")
