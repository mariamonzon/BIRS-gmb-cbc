%Load data (assume the csv is in current folder)
M = readtable('GBM_longitutinal_data_CBC.csv');

%Remove unused columns (just one for now)
M = removevars(M, {'ord_rslt_dttm'});

%Make time formats the same for all time-columns of interest
M.date_initial_cbc = datetime(M.date_initial_cbc, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''');

%Some more format editing to enable "==" comparisons further down in code
if ~iscell(M.date_surgery) && ~isstring(M.date_surgery)
    M.date_surgery = cellstr(M.date_surgery); 
end

M.date_surgery = regexprep(M.date_surgery, '-00(\d{2})', '-20$1');
M.date_surgery = datetime(M.date_surgery, 'InputFormat', 'dd-MMM-yyyy');
M.date_recurrence_cbc = datetime(M.date_recurrence_cbc, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''');
M.ord_proc_dttm = datetime(M.ord_proc_dttm, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''');
M.date_surgery.Format = 'yyyy-MM-dd';
M.date_recurrence_cbc.Format = 'yyyy-MM-dd';
M.ord_proc_dttm.Format = 'yyyy-MM-dd';


%Find unique patient IDs
uniqueIDs = unique(M.PatientID);

%Prep table cols to store data in
concentration_pre_surgery = NaN(length(uniqueIDs), 1);
concentration_at_rec = NaN(length(uniqueIDs), 1);
window = NaN(length(uniqueIDs), 1);
delta_l = NaN(length(uniqueIDs), 1);
min_l = NaN(length(uniqueIDs), 1);
max_l = NaN(length(uniqueIDs), 1);
per_change = NaN(length(uniqueIDs), 1);

for i = 1:length(uniqueIDs)
    
    pid = uniqueIDs(i);
    rows = M(strcmp(M.PatientID, pid), :);

    surgeryTime = rows.date_surgery(1);
    recTime = rows.date_recurrence_cbc(1);
    timePoints = rows.ord_proc_dttm;

    surgeryTime = dateshift(surgeryTime, 'start', 'day');
    recTime = dateshift(recTime, 'start', 'day');
    timePoints = dateshift(timePoints, 'start', 'day');

    exactMatchIdx_s = timePoints == surgeryTime;
    exactMatchIdx_r = timePoints == recTime;

    window(i)=days(recTime-surgeryTime);

    filteredRows = rows(rows.ord_proc_dttm >= surgeryTime & rows.ord_proc_dttm <= recTime, :);
    min_l(i) = min(filteredRows.lymphp);
    max_l(i) = max(filteredRows.lymphp);

    %%%% surgery
    if any(exactMatchIdx_s)
        %Use exact date if exists...
        closestIdx = find(exactMatchIdx_s, 1);
    else
        %... otherwise use closest before surgery
        validIdx = timePoints < surgeryTime;
        if any(validIdx)
            [~, closestIdx] = max(timePoints(validIdx));
            closestIdx = find(validIdx, 1, 'first') + closestIdx - 1;
        else
            closestIdx = NaN; 
        end
    end  
    if ~isnan(closestIdx)
        concentration_pre_surgery(i) = rows.lymphp(closestIdx); 
    end

    %%%% recurrence
    if any(exactMatchIdx_r)
        closestIdx = find(exactMatchIdx_r, 1);
    else
        validIdx = timePoints < recTime;
        if any(validIdx)
            [~, closestIdx] = max(timePoints(validIdx));
            closestIdx = find(validIdx, 1, 'first') + closestIdx - 1;
        else
            closestIdx = NaN; 
        end
    end  
    if ~isnan(closestIdx)
        concentration_at_rec(i) = rows.lymphp(closestIdx); 
    end

    delta_l(i) = concentration_at_rec(i) - concentration_pre_surgery(i);
    per_change(i) = concentration_at_rec(i)/concentration_pre_surgery(i);


end

%Make new table T to analyse
T = table(uniqueIDs, window, concentration_pre_surgery, concentration_at_rec, delta_l,...
          min_l, max_l,per_change,'VariableNames', ...
          {'uniqueIDs', 'window', ...
          'concentration_pre_surgery', 'concentration_at_rec',...
          'delta_l','min_l','max_l','per_change'});


T=rmmissing(T);