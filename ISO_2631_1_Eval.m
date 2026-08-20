f1 = 0.4;
f2 = 100;
f3 = 12.5;
f4 = 12.5;
Q4 = 0.63;
f5 = 2.37;
Q5 = 0.91;
f6 = 3.35;
Q6 = 0.91;
w1 = 2*pi*f1; w2 = 2*pi*f2; w3 = 2*pi*f3; w4 = 2*pi*f4; w5 = 2*pi*f5; w6 = 2*pi*f6;

% p = tf('p');
% 
% % Define component TFs in algebraic form per Annex (continuous s-domain)
% Hh = 1/(1 + sqrt(2)*w1/p + (w1/p)^2);   % band-limiting high-pass
% Hl = 1/(1 + sqrt(2)*p/w2 + (p/w2)^2);   % band-limiting low-pass
% 
% % acceleration-velocity transition (use the algebraic form from Annex)
% Ht = (1 + p/w3) / (1 + p/(Q4*w4) + (p/w4)^2);  
% 
% % upward step (numerator/denominator as ratio)
% Hs = ((1 + p/(Q5*w5) + (p/w5)^2) / (1 + p/(Q6*w6) + (p/w6)^2)) * (w5/w6)^2;
% 
% H_total = Hh * Hl * Ht * Hs;
% 
% % Plot Bode and fvtool magnitude
% %figure; bode(H_total,{0.1,200}); grid on;
sim('Qcar_basic.slx');
T_a0 = ba_0.Time
a0 = ba_0.Data
% sim('Qcar_EM.slx');
% T_a1 = ba_1.Time
% a1 = ba_1.Data
% sim('Qcar_EM_new.slx');
% T_a2 = ba_2.Time
% a2 = ba_2.Data
sim('Qcar_EM_bound_rebound.slx');
T_a3 = ba_3.Time
a3 = ba_3.Data

function results = iso2631_from_aw(t, a_w)

    %% Basic RMS
    T = t(end) - t(1);
    RMS = sqrt(1/T * trapz(t, a_w.^2));

    %% Peak & Crest
    Peak = max(abs(a_w));
    Crest = Peak / RMS;

    %% MTVV (running RMS)
    fs = 1/mean(diff(t));
    tau_2631 = 1.0; 
    N = round(tau_2631 * fs);
    runRMS = sqrt(movmean(a_w.^2, N));
    MTVV = max(runRMS);

    %% VDV
    VDV = (trapz(t, abs(a_w).^4))^(1/4);

    %% Package
    results.RMS = RMS;
    results.Peak = Peak;
    results.CrestFactor = Crest;
    results.MTVV = MTVV;
    results.VDV = VDV;
    results.runRMS = runRMS;
    %% Figures
    figure;
    plot(t, a_w);
    xlabel('Time (s)');
    ylabel('Weighted Acceleration (m/s^2)');
    title('ISO 2631 – Weighted Acceleration Time History');
    grid on;

    figure;
    plot(t, runRMS);
    xlabel('Time (s)');
    ylabel('Running RMS (m/s^2)');
    title('ISO 2631 – Running RMS');
    grid on;

    L = length(a_w);
    Y = fft(a_w);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = fs*(0:(L/2))/L;

    figure;
    semilogx(f, 20*log10(P1));   % or linear plot
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title('ISO 2631 Weighted Acceleration Spectrum');
    grid on;

end

basic_results = iso2631_from_aw(T_a0, a0)
%frictionless_results = iso2631_from_aw(T_a1, a1)
%twoloop_results = iso2631_from_aw(T_a2, a2)
threeloop_results = iso2631_from_aw(T_a3, a3)


%% Time Domain Comparison
figure; hold on; grid on;

plot(T_a0, a0, 'LineWidth', 1.2);
plot(T_a1, a1, 'LineWidth', 1.2);
plot(T_a2, a2, 'LineWidth', 1.2);
plot(T_a3, a3, 'LineWidth', 1.2);

xlabel('Time (s)');
ylabel('Weighted Acceleration a_w (m/s^2)');
title('Time Domain Comparison of a_w(t)');
legend('Passive','Frictionless 2-loop','Friction 2-loop','Friction 3-loop');

%% Running RMS (MTVV Curve)
runRMS_passive = basic_results.runRMS;
runRMS_f2 = frictionless_results.runRMS;
runRMS_f2f = twoloop_results.runRMS;
runRMS_f3f = threeloop_results.runRMS;
figure; hold on; grid on;

plot(T_a0, runRMS_passive, 'LineWidth', 1.3);
plot(T_a1, runRMS_f2, 'LineWidth', 1.3);
plot(T_a2, runRMS_f2f, 'LineWidth', 1.3);
plot(T_a3, runRMS_f3f, 'LineWidth', 1.3);

xlabel('Time (s)');
ylabel('Running RMS (m/s^2)');
title('Running RMS Comparison');
legend('Passive','Frictionless 2-loop','Friction 2-loop','Friction 3-loop');

%% Frequency-Domain Magnitude Spectrum - doesnt work
figure; hold on; grid on;

% Passive
Fs0 = 1 / mean(diff(T_a0));
N0 = length(a0);
f0 = (0:N0-1)*(Fs0/N0);
P0 = abs(fft(a0))/N0;   % normalised
semilogx(f0, 20*log10(P0), 'LineWidth', 1.3);

% Frictionless 2 loop
Fs1 = 1 / mean(diff(T_a1));
N1 = length(a1);
f1 = (0:N1-1)*(Fs1/N1);
P1 = abs(fft(a1))/N1;
semilogx(f1, 20*log10(P1), 'LineWidth', 1.3);

% Friction 2 loop 
Fs2 = 1 / mean(diff(T_a2));
N2 = length(a2);
f2 = (0:N2-1)*(Fs2/N2);
P2 = abs(fft(a2))/N2;
semilogx(f2, 20*log10(P2), 'LineWidth', 1.3);

% Friction 3 loop
Fs3 = 1 / mean(diff(T_a3));
N3 = length(a3);
f3 = (0:N3-1)*(Fs3/N3);
P3 = abs(fft(a3))/N3;
semilogx(f3, 20*log10(P3), 'LineWidth', 1.3);

% Plot Formatting
xlim([0.5 50]);  
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Spectrum of Weighted Acceleration');
legend('Passive','Frictionless 2-loop','Friction 2-loop','Friction 3-loop');

%% Running RMS
RMS_vals  = [basic_results.RMS, frictionless_results.RMS, twoloop_results.RMS, threeloop_results.RMS];
MTVV_vals = [basic_results.MTVV, frictionless_results.MTVV, twoloop_results.MTVV, threeloop_results.MTVV];
VDV_vals  = [basic_results.VDV, frictionless_results.VDV, twoloop_results.VDV, threeloop_results.VDV];

labels = categorical({'Passive','Frictionless 2-loop','Friction 2-loop','Friction 3-loop'});
labels = reordercats(labels, {'Passive','Frictionless 2-loop','Friction 2-loop','Friction 3-loop'});

figure;
subplot(3,1,1);
bar(labels, RMS_vals); grid on;
ylabel('RMS (m/s^2)');
title('ISO Metrics Comparison');

subplot(3,1,2);
bar(labels, MTVV_vals); grid on;
ylabel('MTVV (m/s^2)');

subplot(3,1,3);
bar(labels, VDV_vals); grid on;
ylabel('VDV (m/s^{1.75})');

%% Power Spectrum (dB) vs Frequency (Hz)
figure; hold on; grid on;

% Sampling frequency
Fs = 1 / mean(diff(T_a0));

% Welch PSD estimation
[PSD1,f] = pwelch(a0, hamming(2048), [], [], Fs);
[PSD2,~] = pwelch(a1, hamming(2048), [], [], Fs);
[PSD3,~] = pwelch(a2, hamming(2048), [], [], Fs);
[PSD4,~] = pwelch(a3, hamming(2048), [], [], Fs);

% Convert to dB
PSD1_dB = 10*log10(PSD1);
PSD2_dB = 10*log10(PSD2);
PSD3_dB = 10*log10(PSD3);
PSD4_dB = 10*log10(PSD4);

% Plot
semilogx(f, PSD1_dB, 'LineWidth', 1.4);
semilogx(f, PSD2_dB, 'LineWidth', 1.4);
semilogx(f, PSD3_dB, 'LineWidth', 1.4);
semilogx(f, PSD4_dB, 'LineWidth', 1.4);

xlabel('Frequency (Hz)');
ylabel('Power Spectral Density (dB/Hz)');
title('Power Spectrum of Weighted Acceleration (a_w)');
legend('Passive','Frictionless 2-loop','Friction 2-loop','Friction 3-loop');
xlim([0.5 50]);       % ISO-2631 comfort band
%% 



