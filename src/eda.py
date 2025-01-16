import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime

from src.data_curation import filepath

date_format = '%Y-%m-%dT%H:%M:%SZ'


def load_data(file_path):
    global data
    data = pd.read_csv(file_path)
    # Convert date columns to datetime format
    date_columns = ['date_initial_cbc', 'date_surgery', 'date_recurrence_cbc', 'ord_proc_dttm', 'ord_rslt_dttm']
    for col in date_columns:
        data[col] = pd.to_datetime(data[col], format=date_format, errors='coerce')

    return data

if __name__ == '__main__':
    target = 'lymphp'
    # Load the dataset
    file_path = "data/GBM_longitutinal_data_CBC_trimmed.csv"  # Replace with your file path

    data = load_data(filepath)
    # Make sure the data  si sorted by time_between_recurrence
    data = data.sort_values(by='time_between_recurrence')

    # Exploratory Data Analysis (EDA)
    ## Summary Statistics
    print("Summary Statistics:")
    print(data[target].describe())

    ## Distribution of Target variable Percentage
    plt.figure(figsize=(10, 6))
    sns.histplot(data['lymphp'], kde=True, bins=20, color='green', alpha=0.6)
    plt.title("Distribution of Lymphocyte Percentage (lymphp)",
              fontsize=14)
    plt.xlabel("Lymphocyte Percentage (lymphp)", fontsize=12)
    plt.ylabel("Frequency", fontsize=12)
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.show()


    # Visualization: Correlation Heatmap
    correlation_matrix = data[['wbc', 'neutp', 'absneut', 'lymphp', 'abslymph', 'monop', 'absmono']].corr()
    plt.figure(figsize=(10, 8))
    sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', fmt='.2f')
    plt.title('Correlation Heatmap of CBC Features', fontsize=16)
    plt.show()


    # Temporal; trend basic analysis
    data['ord_proc_dttm'] = pd.to_datetime(data['ord_proc_dttm'])
    plt.figure(figsize=(14, 8))
    for patient_id, group in data.groupby('PatientID'):
        plt.plot(group['ord_proc_dttm'], group['lymphp'], marker='o', label=f'Patient {patient_id}')



    # Calculate observation counts per PatientID
    counts = data['PatientID'].value_counts()
    count_ranges = [0, 10, 20, 30, 100]  # Define ranges for categorization
    count_labels = ['1-10', '11-20', '21-30', '31+']
    count_categories = pd.cut(counts, bins=count_ranges, labels=count_labels, right=False)
    counts_df = pd.DataFrame({'PatientID': counts.index, 'DataPoints': count_categories})
    data = data.merge(counts_df.reset_index(drop=True), on='PatientID')

    # Create box plot of lymphp by PatientID, color-coded by mean value ranges
    plt.figure(figsize=(16, 8))
    sns.boxplot(x='PatientID', y=target, hue='DataPoints', data=data, palette='PuBu')
    plt.title(f'Box Plot of {target.title()} by Patient ID')
    plt.xlabel('Patient ID')
    plt.ylabel(f'{target.title()}')
    plt.xticks(rotation=90)
    plt.legend(title='Available Datapoints')
    plt.tight_layout()
    plt.show()

    # Get unique patient IDs
    patient_ids = data['PatientID'].unique()

    # Determine grid size for subplots (1 column, many rows)
    n_patients = len(patient_ids)
    n_cols = 1
    n_rows = n_patients

    # Create a figure with subplots
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(10, n_patients * 2), sharex=True)
    axes = axes.flatten()

    # Loop through each patient and plot their data in a separate subplot
    for i, patient_id in enumerate(patient_ids):
        ax = axes[i]
        # Filter data for the current patient
        patient_data = data[data['PatientID'] == patient_id]

        # Sort the data by the date of the procedure
        patient_data = patient_data.sort_values(by='ord_rslt_dttm')

        # Plot the trend for this patient
        ax.plot(patient_data['ord_rslt_dttm'], patient_data[target],
                marker='o', color='red', label=f'{patient_id} Time Recurrence {patient_data["time_between_recurrence"].unique()[0]} ')
        # Can you plot the derivative

        ax.set_title(f'Patient {patient_id}', fontsize=12)
        ax.set_ylabel(f'{target.title()}', fontsize=10)
        ax.set_xlabel('Date', fontsize=10)
        # Show X Tick labels at an angle
        plt.setp(ax.get_xticklabels(), rotation=45)

        ax.grid(axis='y', linestyle='--', alpha=0.7)

        # Add legend for each subplot
        ax.legend(fontsize=8)

        # Set common x-axis label
        plt.xlabel('Date', fontsize=12)


    # Show the plot
    plt.show()
