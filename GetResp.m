function [rt,resp] = GetResp(dur,resp_key)

if nargin < 2
    resp_key = [];
end

% initialization
t_start = GetSecs;
resp = NaN;
rt = NaN;
Time = 0;
while (Time < dur)
    Time = GetSecs - t_start;
    [~, ~, keyCode] = KbCheck;

    % key is down 
    if sum(keyCode)>0 && (isempty(resp_key) || sum(ismember(find(keyCode),resp_key)))
        resp = find(keyCode);
        rt   = Time;
        break;
    end
end

% loop until duration end
% while (GetSecs-start < dur) end;