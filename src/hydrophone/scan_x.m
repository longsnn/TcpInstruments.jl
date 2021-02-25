function wave_info_x = ky_hydro_scan_x(settings, x_range, x_num, called)
% wave_info_x = ky_hydro_scan_x(settings, x_range, x_num, called)
%
% This function moves along the x axis and grabs data based on a fixed
% increment passed by the user. This program uses the ky_scope_rs_ch_data
% function that returns a structure with helpful information. There are
% three mantadory inputs and one optional input that is used only when this
% function is called by other functions and the printed messages should be
% surpressed. The user usually doesn't have to use the variable called.
%
% Input: 
%       settings: the structure for all controller connections.
%        x_range: A 1x2 or 1x1 array that contains the start and end point
%                 of the desired range in the x-direction.
%          x_num: The number of points the user desires to record along the
%                 x-axis.
%         called: This variable is either one or zero and is used to turn
%                 off user notifications when another function calls this
%                 one. User usually won't have to use this variable.
%
% Output:
%   wave_info_x: A structure that contains the data that traces x_num of
%                waveforms and the coordinates travelled. The waveforms are
%                stored under wave_info_x.wave_form and the coordinates 
%                travelled is stored under wave_info_x.coordinates. The
%                coordinates are the (x, y, z) coordinates along the path
%                that the function took.
%
% Example:
% scan_range = [0 1]; num_points = 5;
% wave_info_x = ky_hydro_scan_x(settings, scan_range, num_points);
%

%% Declare Variables
tstart     = tic; % starts timer
num_axis   = 3; % represents the three axis, xyz
min_ind    = 1; % the first index of the z_range variable (the first point to scan)
max_ind    = 2; % the second index of the z_range variable (the last point to scan)
first_iter = 1; % represents the first time that the loop has been entered

%% Check input
if nargin < 4 % checks to see if the variable called was entered
    called = 0;
end

if nargin < 3 % makes sure that there are enough inputs
    error('Not enough Inputs!');
end

%% Check there are limits
limits_exist = ky_xyz_IsLimits(settings, 'x'); % checks to see if limits are in place
if ~limits_exist % gives an error if no limits are in place
    error('Please set up limits')
end

%% Pre-Allocate matrices
wave_info_x.wave_form   = zeros(settings.sample_size, x_num); % pre-allocate output waveform matrix
wave_info_x.coordinates = zeros(num_axis, x_num); % pre-allocate output coordinates matrix

%% Check X Controller on
if ~isfield(settings,'Motor_ctrl_x')
    error('The X-Controller is not initialized');
end

%% Set up X Positions Vector
if length(x_range) == 2 % tests to see if the user entered a range of values
    x_pos = linspace(x_range(min_ind), x_range(max_ind), x_num); % computes positions for movements
elseif length(x_range) == 1 % tests to see if the user entered a single value
    x_pos = x_range; % sets position for a range of 1 point
    if x_num > 1 % makes sure the user only wants to measure 1 point
        error('Impossible to take multiple points when user enters 1 value to scan');
    end
else % makes sure that x_range is only 1 or 2 elements long
    error('The x_range must have a length of 1 or 2 elements');
end

%% Loop to scan positions
for i=1:x_num
    if ~called && settings.print_time_msg % checks if the function has been called or the user does not want messages shown
        t_loop = tic; % starts loop timer
        fprintf('Scanning x-direction: %i/%i iterations. ', i, x_num);
    end
    
    ky_xyz_move_x_abs(settings, x_pos(i)); % moves to desired position
    pause(settings.pause_time); % pauses the program between movement and scope read so that the scope can adjust the image
    
    arr_structs              = ky_scope_rs_get_ch_data(settings.scope_handle, settings.ch_number); % grabs/stores data
    if settings.sample_size ~= arr_structs.num_samples % tests to make sure the amount of samples grabbed is correct
        error('The sample size used on Scope is different from the sample size stored in settings');
    end
    if settings.remove_amount_data ~= 0 % checks if the user desires to remove the first and last part of the data set
        arr_structs.data(1:settings.remove_amount_data, i) = 0; % removes first part of data if the user desires
        arr_structs.data((settings.sample_size - settings.remove_amount_data):end, i) = 0; % removes end part of data if the user desires
    end
    if isfield(settings, 'filter') % checks if the user desires to filter the data
        if i == first_iter % program only creates a new matrix on the first iteration of the program
            wave_info_x.unfiltered_waveform      = zeros(settings.sample_size, x_num); % pre-allocate space
        end
        wave_info_x.unfiltered_waveform(:,i) = arr_structs.data; % store unfilted data
        arr_structs.data                     = conv(arr_structs.data, settings.filter, 'same'); % data is filtered and ready to be stored
    end
    
    wave_info_x.wave_form(:,i)   = arr_structs.data; % stores the waveform data
    wave_info_x.coordinates(:,i) = ky_xyz_get_position(settings); % stores the position data
    
    if ~called && settings.print_time_msg && (i ~= x_num) % checks if the function has been called or the user does not want messages shown or that the loop is on its last iteration
        time_left = toc(t_loop)*(x_num - i); % estimates the time remaining in the for loop
        fprintf('Estimated Time Remaining: '); % prints out message
        ky_hydro_convert_time(time_left); % converts and prints out time
    end
end
% write data to file
if ~called % saves the data if the function was not called
    t_clock = fix(clock);
    FileName = sprintf('hydro_scan_x_%.f_%.f_%.f_%.f_%.f_%.f_%.f', t_clock(1), t_clock(2), t_clock(3), t_clock(4), t_clock(5), t_clock(6));
    save(FileName, 'wave_info_x');
end

%% Print End Results
if ~called % makes sure the function was not called
    fprintf('\nScan Completed from %.4f to %.4f\n', x_range(min_ind), x_range(max_ind)); % tells the range it scanned
    fprintf('Total time elasped: '); % prints out message
    ky_hydro_convert_time(toc(tstart)); % converts and prints out time
end

%% Make plot
if ~called && settings.plot_on % makes plot if neccessary
    wave_form_env = abs(hilbert(wave_info_x.wave_form)); % finds the envelope of the waveform
    max_vector    = max(wave_form_env); % finds the maximum of each envelope
    
    figure;
    plot(x_pos, max_vector) % plots the data
    title('X-Scan');
    xlabel('X-Position (mm)');
    ylabel('Magnitude (V)');
end

end

