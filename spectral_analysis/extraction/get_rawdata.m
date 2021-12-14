function [rawdata] = get_rawdata(raw_path_name)

fid = fopen(raw_path_name); 
rawdata = fread(fid, inf, '*uint16'); 
fclose(fid);

end

