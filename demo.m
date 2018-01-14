[x,fs] = wavread('Imsad.wav');
x = x(1:30*fs); x = x(:);
L = length(x);
N = 512;
win = blackman(N+1);
win = win(1:end-1);
num_frame = L/N;
y = zeros(1,L);

im = imread('leo_re.jpg');
S = size(im);
row = 1;
column = 1;

count2 = 0;
mask_no = zeros(1,num_frame);

for mm = 1:num_frame
    tt = (mm-1)*N+1 : mm*N;
    X = fft(x(tt));
    M = find_mask(X,fs);
    plot(M);
    X_tmp = X;
    
    pix = [];
    if (column+11) > S(2) && (row+1) <= S(1)
        pix = [im(row,column:S(2),:) im(row+1,1:(column+11-S(2)),:)];
        row = row +1;
        column = column+12-S(2);
    elseif (column+11) > S(2) && row == S(1)
        pix = im(row,column:S(2),:);
    elseif row <= S(1)
        pix = im(row,column:(column+11),:);
        column = column+12;
    end
    
    S2 = size(pix);
    row2 = 1;
    column2 = 1;
    color = 1;
    count = 1;
    if ~isempty(pix)
        imsg = dec2bin(pix(row2,column2,color),8);
        for k = 1:(N/2)
            if 20*log(abs(X(k))) < M(k)
                count2 = count2+1;
                if imsg(count) == '1' && imsg(count+1) == '1'
                    msg = exp(-1.9);
                elseif imsg(count) == '1' && imsg(count+1) == '0'
                    msg = exp(-3.9);
                elseif imsg(count) == '0' && imsg(count+1) == '1'
                    msg = exp(-5.9);
                else
                    msg = exp(-10);
                end
            
                if k~=1
                    X(k) = msg*exp(1i*angle(X(k)));
                    X(N-k+2) = msg*exp(1i*angle(X(N-k+2)));
                else
                    X(k) = msg*exp(1i*angle(X(k)));
                end
            
                count = count+2;
                if count > 8
                    count = 1;
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
                if row2 > S2(1)
                    imsg = dec2bin(0,8);
                else
                    imsg = dec2bin(pix(row2,column2,color),8);
                end
            end
        end
    end
    
%     if mm == 1
%         plot(20*log(abs(X)));
%     end
    
    mask_no(mm) = count2;
    count2 = 0;
    
    y(tt) = ifft(X);
end

y = y/max(abs(y));
wavwrite(y,fs,'masked.wav');