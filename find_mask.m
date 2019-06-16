% Function to find mask
function MR = find_mask(X,fs)

N=size(X(:),1);
data = 20*log10(abs(X));
data=data(:);

ind = find( (data>[data(1)-100;data((1:N-1)')]) & (data>=[data((2:N)'); data(N)-100]) & data>0);
peaks = [data(ind) ind];

df = fs/N;
N = floor(N/2);
MR = zeros(1,N);

for i = 1:N
    zi = 13*atan(0.00076*i*df) + 3.5*atan(((i*df)/7500)^2);
    MR(i) = 3.64*(i*df/1000)^-0.8 - 6.5*exp(-0.6*((i*df/1000)-3.3).^2) + (10^-3)*(i*df/1000)^4 - 10;
    
    if not(isempty(peaks))
        for j = 1:length(peaks(:,1))
            k = peaks(j,2);
            amp = peaks(j,1);
            zk = 13*atan(0.00076*k*df) + 3.5*atan(((k*df)/7500)^2);
            dz = zi - zk;
            M_tmp = MR(i);
            if dz >= -3 && dz < 8
                avtm = -1.525 - 0.275 * zk - 4.5;
                if -3 <= dz && dz < -1
                    vf = 17 * (dz + 1) - (0.4 * amp + 6);
                elseif -1 <= dz && dz < 0
                    vf = (0.4 * amp + 6) * dz;
                elseif 0 <= dz && dz < 1
                    vf = -17 * dz;
                elseif 1 <= dz && dz < 8
                    vf = - (dz - 1) * (17 - 0.15 * amp) - 17;
                end
                M_tmp = amp + avtm + vf;
            end
            if M_tmp > MR(i)
                MR(i) = M_tmp;
            end
            if MR(i) > 70
                MR(i) = 70;
            end
        end
    end
end