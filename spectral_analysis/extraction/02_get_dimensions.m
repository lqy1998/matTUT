function [samples, lines, bands, wavelengths] = get_dimensions(info)
% get samples
start = strfind(info,'samples = '); 
len = length('samples = ');
stop = strfind(info,'lines ');
samples = [];
for i = start+len : stop-1
    samples = [samples, info(i)];
end
samples = str2num(samples);

% get lines
start = strfind(info,'lines   = ');
len = length('lines   = ');
stop = strfind(info,'bands');
lines = [];
for i = start+len : stop-1
    lines = [lines, info(i)];
end
lines = str2num(lines);

% get bands
start = strfind(info,'bands   = ');
len = length('bands   = ');
stop = strfind(info,'default bands');
bands = [];
for i = start+len : stop-1
    bands = [bands, info(i)];
end
bands = str2num(bands);

% get wavelengths
start = strfind(info,'Wavelength = { ');
len = length('Wavelength = { ');
stop = strfind(info,'fwhm');
wavelengths = [];
for i = start+len : stop-1
    wavelengths = [wavelengths, info(i)];
end

wavelengths = splitlines(wavelengths);
wavelengths = wavelengths(2:end-2);
wavelengths = cellfun(@str2num, wavelengths);
wavelengths = wavelengths';

end

