function [label] = get_single_roi(bw)

[label, num] = bwlabel(bw);  
num
im1 = (label == 1);
figure; imshow(im1); title('object1');

for j = 1:num
    [row, col] = find(label == j);
    len = max(row) - min(row) + 2;
    breadth = max(col) - min(col) + 2;
    target = uint8(zeros(len, breadth));
    sx = min(row) - 1;
    sy = min(col) - 1;
        
    for i = 1:size(row, 1)
        x = row(i, 1) - sx;
        y = col(i, 1) - sy;
        target(x, y) = bw(row(i, 1), col(i, 1));
    end
    
    mytitle = strcat('object num: ', num2str(j));
    figure; imshow(target); title(mytitle);
    
end

end

