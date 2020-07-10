
function [logSharpness, logSteepness, shpAvg, stpAvg] = waveform_shape_one_signal(signal,...
    sampling_rate, low_freq, high_freq, sharpness_range, rejection_indicies, window_width, threshold)
    %{
        Signal: EEG 1xN matrix
        SR: 1x1 matrix double in Hz
        Low/High Freq: 1x1 matrix, Range for the filter, Hz
        Sharpness_Range: 1x1 matrix, Range around peak to examin, in ms
        Rejection_ind: 1xM matrix of integers representing indicies to
            discard.
    %}

    % This should compute the sharpness and steepness from just the
    % incoming signal....
    
    [peak_points, trough_points] = find_peaks_and_troughs(signal, sampling_rate, low_freq, high_freq, sharpness_range, window_width);
    
    
    
    
    peaks = extract_sharpness(signal, peak_points, sampling_rate, low_freq, high_freq, sharpness_range, threshold, 'diff');
    troughs = extract_sharpness(signal, trough_points, sampling_rate, low_freq, high_freq, sharpness_range, threshold, 'diff');
    

    
    
    [rising_rates, falling_rates] = extract_steepness(signal, peak_points, trough_points, sampling_rate);
    
    % Now remove those indicies that are included in bad sectors...
    % Note: This is the original implementation where we only exclude the peaks
    %    included, not where the 'bad section' occurs in the middle. 
    rejected_peaks = find(ismember(peak_points, rejection_indicies));
    
    % Remove the bad indicies
    peaks(rejected_peaks(rejected_peaks <= length(peaks))) = [];
    rising_rates(rejected_peaks(rejected_peaks <= length(rising_rates))) = [];
    
    % Now do the same for the troughs
    rejected_troughs = find(ismember(trough_points, rejection_indicies));
    
    troughs(rejected_troughs(rejected_troughs <= length(troughs))) = [];
    falling_rates(rejected_troughs(rejected_troughs <= length(falling_rates))) = [];
    
    logSharpness = log10(max([mean(peaks) / mean(troughs), mean(peaks) / mean(troughs)]));
    logSteepness = log10(max([mean(rising_rates) / mean(falling_rates), mean(falling_rates) / mean(rising_rates)]));
    shpAvg = mean(peaks) / mean(troughs);
    stpAvg = mean(rising_rates)/mean(falling_rates);
    
end
function [rise, falls] = extract_steepness(signal, peaks, troughs, sampling_rate)
    
    if peaks(1) < troughs(1)
        offset_peaks = 1;
    else
        offset_peaks = 0;
    end

    
    rise = zeros(length(troughs) - 1, 1);
    falls = zeros(length(peaks) - 1, 1);
    % Since we just want to find the maximum slope between the two peaks...
    
    signal_diff = diff(signal);
    for i = 1:length(rise)+length(falls)
        current_position = ceil(i/2);
        
        if (mod(i, 2)== 1) ~= (offset_peaks == 1)
            % trough
            falls(current_position) = -min(signal_diff(peaks(current_position):troughs(current_position + (1 - offset_peaks))));
        else
            % peak
            rise(current_position) = max(signal_diff(troughs(current_position):peaks(current_position + offset_peaks)));
        end
    end
    
end
function [result]= ternary_expr(question, correct, incorrect)
    %{
        As shown below, this is a glorified "if" statement, where 
            if the question evaluates to true, it returns correct,
            otherwise it will return incorrect. 

            Useful for inline if statements.
    %}
    if question
        result = correct; 
    else
        result = incorrect;
    end
end
function [sharpness] = extract_sharpness(signal, peaks, sampling_rate, low_freq, high_freq, window_width, threshold, calc_method)


    %{

        window_width: ms around the peak to consider.
    %}
    
    int_window_width = floor(window_width * sampling_rate / 1000.0);
    if strcmp(calc_method, 'diff')
        sharpness = abs(signal(peaks) - mean([signal(peaks - int_window_width);signal(peaks + int_window_width)]));
    elseif strcmp(calc_method, 'deriv')
        sharpness = abs(mean(abs(diff(signal(peaks - int_window_width:peaks + int_window_width+1)))));
    else
       error(strjoin(['Unrecognized method:', calc_method,'in extract sharpness. Accepted methods are diff and deriv'.'])); 
    end
    if threshold > 0
       [~, ampl] =  get_phase_amplitude_of_series(sharpness, sharpness, sampling_rate,...
           low_freq, high_freq, low_freq, high_freq, sharpness_range, false, false);
       ampl = repair_edge_removal(ampl, sampling_rate, low_freq, high_freq, window_width);
       sharpness = metric(ampl(peaks) >= prctile(ampl(peaks), threshold));
    end
end
function [repaired] = repair_edge_removal(amplitudes, sampling_rate, low_freq, ~, window_width)
    %{
        Re-aligns the amplitudes with the actual data.

        To be consistent with the other functions, this one will still take
        a high_freq parameter, but it is ignored.
    %}

    number_taps = int(floor(sampling_rate*sampling_rate * window_width / (low_freq * 1000.0)));
    repaired = zeros(length(amplitudes) + 2*number_taps, 1);
    repaired(number_taps:end-number_taps) = amplitudes;
end
function [lower, higher] = get_phase_amplitude_of_series_manual_tapping(low_signal, high_signal,...
    sampling_rate, low_low_freq, low_high_freq, high_low_freq, high_high_freq, number_low_taps,...
    number_high_taps, clip_edges, use_high_phase_instead)

     %{
        Note, this function is supposed to be generic, but every time it is
        used it has duplicated inputs (low_signal = high_signal, low_x_freq
        = high_x_freq, etc.)


        Return are lower and higher since higher may be a "phase" or an
        "amplitude".
    %}
    low_filter = manual_firf(low_signal, sampling_rate, low_low_freq, ...
        low_high_freq,number_low_taps, clip_edges);
    
    if use_high_phase_instead > 0
        high_filter = manual_firf(high_signal, sampling_rate, low_low_freq, ...
           low_high_freq, number_low_taps, clip_edges);
    else
        high_filter = manual_firf(high_signal, sampling_rate, high_low_freq, ...
            high_high_freq,number_high_taps, clip_edges);
    end
    assignin('base', 'aaa2', low_filter);
    assignin('base', 'aab2', high_filter);
    
    % So take the angle of the hilbert of the filtered low signal...
    
    [lower, higher] = sub_calculate_phase_amplitude_of_series(low_filter, high_filter, use_high_phase_instead);



end
function [lower, higher] = get_phase_amplitude_of_series(low_signal, high_signal, sampling_rate,...
    low_low_freq, low_high_freq, high_low_freq, high_high_freq, sharpness_range, clip_edges, use_high_phase_instead)
    %{
        Note, this function is supposed to be generic, but every time it is
        used it has duplicated inputs (low_signal = high_signal, low_x_freq
        = high_x_freq, etc.)


        Return are lower and higher since higher may be a "phase" or an
        "amplitude".
    %}
    low_filter = firf(low_signal, sampling_rate, low_low_freq, low_high_freq, sharpness_range, clip_edges);
    
    if use_high_phase_instead > 0
        high_filter = firf(high_signal, sampling_rate, low_low_freq, ...
           low_high_freq, sharpness_range, clip_edges);
    else
        high_filter = firf(high_signal, sampling_rate, high_low_freq, high_high_freq, sharpness_range, clip_edges);
    end
    % So take the angle of the hilbert of the filtered low signal...
    
    [lower, higher] = sub_calculate_phase_amplitude_of_series(low_filter, high_filter, use_high_phase_instead);
end
function [lower, higher] = sub_calculate_phase_amplitude_of_series(low_filter, high_filter, use_high_phase_instead)

    
    lower = angle(hilbert(low_filter));
    if use_high_phase_instead > 0
    
       % And here we recompute the filtered high signal using the lower
       % frequencies?!
       higher = angle(hilbert(high_filter));
    else
        % But this one we take the absolute of the hilbert of the filtered high
        % signal...? Why?
        higher = abs(hilbert(high_filter));
    
    end
    % Remove artifacts of the edges, make the high and lower parts match.
    if length(lower) == length(higher)
        % Early return
        return;
    end
    
    diff_in_length = abs(length(lower) - length(higher));
    if mod(diff_in_length, 2) ~= 0
       error('The difference between the length of the filtered time series should be even.'); 
    end
    
    if length(lower) < length(higher)
        higher = higher(1 + floor(diff_in_length / 2): end - floor(diff_in_length)); 
    else
        lower = lower(1 + floor(diff_in_length / 2): end - floor(diff_in_length)); 
    end
end
function [peaks, troughs] = find_peaks_and_troughs(signal, sampling_rate, low_freq, high_freq, sharpness_range, boundary_range)
    %{
        signal
        rejected_indicies
        sampling_rate
        low_freq
        high_freq
        sharpness_range
        boundary_range
    %}
    filtered = firf(signal, sampling_rate, low_freq, high_freq, sharpness_range, false);
    zero_fall_locations = find((filtered(1:end-1) > 0) & ~(filtered(2:end) > 0));
    zero_rise_locations = find(~(filtered(1:end-1) > 0) & (filtered(2:end) > 0));
    % Correct the number of peaks and troughs to pick out of data (due to
    % boundary issues)
    % First determine if we end with a peak or a trough
    if zero_rise_locations(end) > zero_fall_locations(end)
        number_peaks = length(zero_rise_locations) - 1;
        number_troughs = length(zero_fall_locations);
    else
        number_peaks = length(zero_rise_locations);
        number_troughs = length(zero_fall_locations) - 1;
    end
    
    % Fix an off-by-2 issue
    if number_peaks - number_troughs == 2
        number_peaks = number_peaks - 2;
    elseif number_troughs - number_peaks == 2
        number_troughs = number_troughs - 2;
    end
    
    % Calculate the best point to identify the peak or trough
    peaks = zeros(number_peaks, 1);
    troughs = zeros(number_troughs, 1);
    
    for p=1:number_peaks
       next_fall_locations = zero_fall_locations(zero_fall_locations > zero_rise_locations(p));
       peaks(p) = argmax(signal(zero_rise_locations(p):next_fall_locations(1)-1)) + zero_rise_locations(p) - 1;
    end
    
    for t=1:number_troughs
       next_rise_locations = zero_rise_locations(zero_rise_locations > zero_fall_locations(t));
       troughs(t) = argmin(signal(zero_fall_locations(t):next_rise_locations(1)-1)) + zero_fall_locations(t) - 1;
    end
    % Clip the boundary terms if we are excluding them.
    if boundary_range > 0
        peaks = peaks(peaks >= boundary_range*sampling_rate    & peaks <= length(signal) - (boundary_range*sampling_rate));
        troughs = troughs(troughs >= boundary_range*sampling_rate & troughs <= length(signal) - (boundary_range*sampling_rate));
    end
    
end
function [a] = argmax(input)
    [~,a] = max(input);
end
function [a] = argmin(input)
    [~,a] = min(input);
end
function [filtered_signal] = firf(signal, sampling_rate, low_freq, high_freq, sharpness_range, clip_edges)
    
    nyquist = sampling_rate / 2.0;
    if any([low_freq, high_freq] > nyquist)
        error('Filter frequencies must be below the nyquist frequency.');
    end
    if any([low_freq, high_freq] < 0)
       error('Filter frequencies must be positive.'); 
    end
    number_taps = floor(sampling_rate*sampling_rate*sharpness_range / (1000.0*low_freq)) - 1;
    
    filtered_signal = manual_firf(signal, sampling_rate, low_freq, high_freq, ...
            number_taps, clip_edges);
end
function [filtered_signal] = manual_firf(signal, sampling_rate, low_freq, high_freq,number_taps, clip_edges)
    %{
        signal: EEG 1xN matrix
        sampling_rate: Hz
        low_freq: Hz
        high_freq: Hz
        sharpness_range: Length of the filter in ms
        clip_edges: True/false

    %}
    nyquist = sampling_rate / 2.0;
    if any([low_freq, high_freq] > nyquist)
        error('Filter frequencies must be below the nyquist frequency.');
    end
    if any([low_freq, high_freq] < 0)
       error('Filter frequencies must be positive.'); 
    end
    
    if length(signal) < number_taps
       error('Length of filter is longer than data. Provide more data or a shorter filter.'); 
    end
    
    taps = fir1(number_taps, [low_freq/nyquist, high_freq/nyquist]);
    
    signal_filtered = filtfilt(taps, 1, double(signal));
    
    if any(isnan(signal_filtered))
       error('Filtered signal contains NANs, adjust filter parameters.'); 
    end
    
    if clip_edges
       filtered_signal = signal_filtered(number_taps+1:end-number_taps);
    else
       filtered_signal = signal_filtered(1:end); 
    end
end


