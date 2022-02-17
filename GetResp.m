function [rt,resp] = GetResp(dur)

% initialization
t_start = GetSecs;
resp = NaN;
rt = NaN;
Time = 0;
while (Time < dur)
    Time = GetSecs - t_start;
    [~, ~, keyCode] = KbCheck;
    if sum(keyCode)>0
        resp = find(keyCode);
        rt   = Time;
        break;
    end
end

% loop until duration end
% while (GetSecs-start < dur) end;