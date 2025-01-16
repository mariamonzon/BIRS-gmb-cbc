close all

%definde (rudimentary) feature vectors 
f1 = T.concentration_pre_surgery;  %lymph concentration just before surgery
f2 = T.concentration_at_rec;  %lymph concentration at declared recurrence
f3 = T.delta_l;  %f2-f1
f4 = T.min_l;  %minimum lymph concentration bewteen (and including) surgery and recurrence times
f5 = T.max_l;  %maximum (as above)
f6 = T.per_change; %f2/f1

%threshold value for red/blue color split (now just the median)
threshold = median(T.window);
t = T.window;
colors = t > threshold;  % Logical array, 1 if above p, 0 if below or equal to p

%plot features in 2D plots
figure

subplot(3,3,1)
scatter(f1, f2, 100, colors, 'filled'); 
xlabel('surgery');
ylabel('recurrence');

subplot(3,3,2)
scatter(f1, f3, 100, colors, 'filled'); 
xlabel('surgery');
ylabel('delta');

subplot(3,3,3)
scatter(f2, f3, 100, colors, 'filled'); 
xlabel('recurrence');
ylabel('delta');

subplot(3,3,4)
scatter(f4, f5, 100, colors, 'filled'); 
xlabel('min');
ylabel('max');

subplot(3,3,5)
scatter(f1, f4, 100, colors, 'filled'); 
xlabel('surgery');
ylabel('min');

subplot(3,3,6)
scatter(f1, f5, 100, colors, 'filled'); 
xlabel('surgery');
ylabel('max');

subplot(3,3,7)
scatter(f2, f4, 100, colors, 'filled'); 
xlabel('rec');
ylabel('min');

subplot(3,3,8)
scatter(f2, f5, 100, colors, 'filled'); 
xlabel('rec');
ylabel('max');

subplot(3,3,9)
scatter(f1, f6, 100, colors, 'filled'); 
xlabel('surgery');
ylabel('change');


colormap([1 0 0; 0 0 1]);  % Red short, Blue long
