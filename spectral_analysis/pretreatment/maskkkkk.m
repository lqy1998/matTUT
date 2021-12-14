% clear all;
% clc;

cd H:\lqy\2020
for n=1:10
%读入hdr头文件，提取lines行参数，确定每张高光谱图像的大小，即samples和lines
number=n;%文件命名为001 002 003，确定文件名前缀
str=num2str(number,'%03d');
file_hdr=strcat('2020-',str,'.hdr');        %连接字符串的函数%_RT.hdr
file_raw=strcat('2020-',str,'.raw');        %_RT.raw

a=importdata(file_hdr);             %读入高光谱数据头文件
b=a.textdata;                       %读取其中的文本结构
samples = b{9};                     %读取‘samples   = XXX’
lines = b{10};                      %读取‘lines   = XXX’
bands = b{11};                      %读取‘band   = XXX’

lines_read = str2num(lines(regexp(lines,'\d')));       %提取lines的数值
samples_read = str2num(samples(regexp(samples,'\d'))); %提取samples的数值
bands_read = str2num(bands(regexp(bands,'\d')));       %提取bands的数值
wavelengths=a.data;                                    %提取波长数据
Roman_shift=10^7/785 - 10^7./wavelengths;              %拉曼坐标变换，激发激光为785nm

%利用multibandread函数读入.raw文件
AllBand=multibandread(file_raw,[lines_read samples_read  bands_read],'uint16=>uint16',0,'bil', 'ieee-le');

% Grayscale image at 500th ，获取Mask image
Band_mask=imadjust(AllBand(:,:,500));                   %Roman  第500个波段

%figure,imshow(Band_mask,[])
%figure,imhist(imadjust(Band_mask));

Mask1=uint16(zeros(lines_read,samples_read));

for i=1:lines_read
    for j=1:samples_read
        if Band_mask(i,j)>12000%拉曼
            Mask1(i,j)=1;
        end
    end
end
% figure,imshow(Mask1,[])
Mask1=bwareaopen(Mask1,1000);
Mask1=imfill(Mask1,'holes');

se = strel('disk',5);
Mask1=imclose(Mask1,se);
% Mask1=imerode(Mask1,se);
%查看图像，排查异常
figure,imshow(Mask1,[])
title(str)

sample1=AllBand.*repmat(uint16(Mask1),1,1,bands_read);


row_sum1 = sum(Mask1,2);
segment_row_sum1 = bwconncomp(row_sum1,8);  %对每一行进行分割
row_num1 = segment_row_sum1.NumObjects;  


for j1=1:row_num1
    
   Pixellist1 = segment_row_sum1.PixelIdxList{1,j1}; 
%    segment1 = bwconncomp(Mask1(Pixellist1(1)-5:Pixellist1(end)+5,:),8);   %对每一行按照列再进行分割
   segment1 = bwconncomp(Mask1(Pixellist1(1):Pixellist1(end),:),8); 
   column_num1 = segment1.NumObjects; 

       for w1=1:bands_read
    %        sub_sample1 = sample1((Pixellist1(1)-5):(Pixellist1(end)+5),:,w1);
            sub_sample1 = sample1((Pixellist1(1)):(Pixellist1(end)),:,w1);
               for m1=1:column_num1

                   Pixellist_column1 = segment1.PixelIdxList{1,m1};

                   spec1(m1,w1) = mean(sub_sample1(Pixellist_column1));

               end

       end
      spec_all1(j1*column_num1-(column_num1-1):j1*column_num1,:) = spec1;      
%       s = ['spectral_data',num2str(j),'=spec;'];
%       eval(s);
end


if n<10
    Roman_spec_2020((n-1)*(row_num1*column_num1)+1:n*(row_num1*column_num1),:)=spec_all1;
else
    Roman_spec_2020=[Roman_spec_2020;spec_all1];
end


clear spec_all1
clear AllBand; 
clear sample1;
%建议换为元胞，方便查错
% corn_surface{n}=spec_all(:,:);
% corn_endosperm{n}=spec_all1(:,:);

end
