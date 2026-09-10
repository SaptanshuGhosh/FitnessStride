clc;
clear m;
m = mobiledev;
m.SampleRate = 60;
m.Logging = 1;
pause(30);
m.Logging = 0;
[acc, t_acc] = accellog(m);
[pos, t_pos] = poslog(m);
ax = acc(:,1);
ay = acc(:,2);
az = acc(:,3);
if size(pos,2) >= 1
    lat = pos(:,1);
else
    lat = zeros(size(pos,1),1);
end
if size(pos,2) >= 2
    lon = pos(:,2);
else
    lon = zeros(size(pos,1),1);
end
if size(pos,2) >= 3
    alt = pos(:,3);
else
    alt = zeros(size(pos,1),1);
end
if size(pos,2) >= 4
    speed = pos(:,4);
else
    speed = zeros(size(pos,1),1);
end
acc_mag = sqrt(ax.^2 + ay.^2 + az.^2);
th = mean(acc_mag) + 0.8*std(acc_mag); 
[~, locs] = findpeaks(acc_mag, 'MinPeakHeight', th, 'MinPeakDistance', 15);
steps = length(locs);
R = 6400000;
dists = zeros(length(lat),1);
for i = 2:length(lat)
    phi1 = deg2rad(lat(i-1)); phi2 = deg2rad(lat(i));
    dphi = deg2rad(lat(i)-lat(i-1));
    dlambda = deg2rad(lon(i)-lon(i-1));
    a = sin(dphi/2)^2 + cos(phi1)*cos(phi2)*sin(dlambda/2)^2;
    dists(i) = 2*R*atan2(sqrt(a), sqrt(1-a));
end
total_dist = sum(dists);
gain = sum(max(0, diff(alt)));
flights = floor(gain/3);
weight = 70;
duration_h = (max(t_acc)-min(t_acc))/3600;
if mean(speed) < 2
    MET = 3;
elseif mean(speed) < 3
    MET = 5;
else
    MET = 8;
end
calories = MET * weight * duration_h;
fprintf('Steps: %d\n', steps);
fprintf('Distance: %.2f m (%.2f km)\n', total_dist, total_dist/1000);
fprintf('Flights Climbed: %d\n', flights);
fprintf('Calories Burned: %.1f kcal\n', calories);
figure;
plot(lon,lat,'r-','LineWidth',1.5);
xlabel('Longitude');
ylabel('Latitude');
title('GPS Route');
grid on;
figure;
plot(acc_mag,'k');
hold on;
plot(locs,acc_mag(locs),'ro');
xlabel('Sample Index');
ylabel('|acc|');
title('Step Detection');
hold off;