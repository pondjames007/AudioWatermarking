[x,fs] = wavread('masked.wav');
L = length(x);
N = 512;
num_frame = L/N;

im = uint8(zeros(150,150,3));

S = size(im);
row = 1;
column = 1;

imsg = dec2bin(0,8);

count2 = 0;
mask_no_ex = zeros(1,num_frame);

for mm = 1:num_frame
    tt = (mm-1)*N+1 : mm*N;
    X = fft(x(tt));
    M = find_mask(X,fs);
    
    pix = uint8(zeros(1,12,3));
    S2 = size(pix);
    row2 = 1;
    column2 = 1;
    color = 1;
    count = 1;
    
    for k = 1:(N/2)
        check = 0;
        if 20*log(abs(X(k))) < M(k)
            count2 = count2+1;
            if abs(X(k)) < exp(-1.8)
                check = 1;
            end
            
            if abs(X(k)) >= exp(-2.1)
                imsg_tmp1 = '1';
                imsg_tmp2 = '1';
            elseif abs(X(k)) >= exp(-4.1)
                imsg_tmp1 = '1';
                imsg_tmp2 = '0';
            elseif abs(X(k)) >= exp(-6.1)
                imsg_tmp1 = '0';
                imsg_tmp2 = '1';
            else
                imsg_tmp1 = '0';
                imsg_tmp2 = '0';
            end
            
            if check == 1
                imsg(count) = imsg_tmp1;
                imsg(count+1) = imsg_tmp2;
                count = count+2;
                if count > 8
                    count = 1;
                    if row2 <= S2(1)
                        pix(row2,column2,color) = bin2dec(imsg);
                    end
                    color = color+1;
                    if color > 3
                        color = 1;
                        column2 = column2+1;
                        if column2 > S2(2)
                            column2 = 1;
                            row2 = row2+1;
                        end
                    end
                end
            end
        end
    end

    if (column+11) > S(2) && (row+1) <= S(1)
        last = S(2)-column+1;
        im(row,column:S(2),:) = pix(1,1:last,:);
        im(row+1,1:(column+11-S(2)),:) = pix(1,last+1:12,:);
        row = row +1;
        column = column+12-S(2);
    elseif (column+11) > S(2) && row == S(1)
        im(row,column:S(2),:) = pix(1,1:S(2)-column+1,:);
    elseif row <= S(1)
        im(row,column:(column+11),:) = pix;
        column = column+12;
    end
    
%     if mm == 1
%         plot(20*log(abs(X)));
%     end
    
    mask_no_ex(mm) = count2;
    count2 = 0;
end

imwrite(im,'extracted.jpg','JPG');