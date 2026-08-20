%% === Common Settings ===
Tsim = 5;                 % simulation time (s)
fs = 1000;                % sample frequency (Hz)
t = (0:1/fs:Tsim)';       % time vector (column)
%% === Single Sine Bump ===
A = 0.02;                 % amplitude (m)
f = 1;                    % frequency (Hz)

r = A * sin(2*pi*f*t);

road_sine = [t r];
%% === Gaussian Bump ===
A = 0.03;                 % bump height (m)
t0 = 1.5;                 % center of bump
sigma = 0.05;             % width (s)

r = A * exp(-((t - t0).^2) / (2*sigma^2));

road_gaussian = [t r];
%% === Step (Kerb) ===
A = 0.03;                 % kerb height (m)
t0 = 2;                   % at t = 2s

r = A * double(t >= t0);

road_step = [t r];
%% === Pothole (negative rectangular pulse) ===
A = -0.03;                % depth (negative)
start_t = 2;              % start time
end_t   = 2.2;            % end time

r = A * double(t >= start_t & t <= end_t);

road_pothole = [t r];
%% === Chirp (0.5 → 20 Hz sweep) ===
A = 0.01;

f0 = 0.5;                 % start frequency
f1 = 20;                  % end frequency

% linear frequency sweep
k = (f1 - f0) / Tsim;
inst_freq = f0 + k*t;     % instantaneous frequency

r = A .* sin(2*pi .* (f0*t + 0.5*k*t.^2));

road_chirp = [t r];
%% === Random Rough Road ===
rng(1);                   % repeatable randomness

white = randn(size(t));
cutoff = 30;              % max frequency (Hz)

[b,a] = butter(2, cutoff/(fs/2));      % low-pass filter
smooth_noise = filtfilt(b, a, white);

A = 0.005;                % roughness amplitude
r = A * smooth_noise;

road_random = [t r];
%% === Combined Road Profile ===
A_bump = 0.02;
t0 = 1.2;
sigma = 0.04;
gaussian_bump = A_bump * exp(-((t - t0).^2)/(2*sigma^2));

A_noise = 0.003;
white = randn(size(t));
[b,a] = butter(2, 20/(fs/2));
rnd = filtfilt(b,a,white) * A_noise;

r = gaussian_bump + rnd;

road_combined = [t r];

