function [info] = get_info(hdr_path_name)

fid = fopen(hdr_path_name,'r');
info = fread(fid, 'char=>char');
info = info';
fclose(fid);

end

