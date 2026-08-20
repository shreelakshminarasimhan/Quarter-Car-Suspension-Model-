y = position_rise.Data; % signal values from To Workspace
t = position_rise.Time;           % corresponding time vector

% Determine 10% and 90% levels
y_min = min(y);
y_max = max(y);
y10 = y_min + 0.1*(y_max - y_min);
y90 = y_min + 0.9*(y_max - y_min);

% Find the indices where signal crosses 10% and 90%
t10 = t(find(y >= y10, 1, 'first'));
t90 = t(find(y >= y90, 1, 'first'));

rise_time = t90 - t10;
disp(['Rise Time: ', num2str(rise_time), ' seconds']);
