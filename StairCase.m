function [Xnext,Threshold,Rev,StepSize] = StairCase(Xprev,Resp,NUps,Rev,StepSize)
%% Input
% Xprev - Stimulus intensity of previous trials
% Resp - Response history, 0 for failure, 1 for success
% NUps - Number of consecutive successes before intensity decrement
% Rev - Number of reversals
% StepSize - Step size of intensity decrement

%% Output
% Xnext - Stimulus intensity of next(incoming) trial
% Thresh - Estimated Threshold
% Rev - Number of reversals

% Exclude first three(odd) or four(even) reversals in computing threshold
% Thresold obtained by averaging the last six endpoints
Flag = false;
if Resp(end) == 0 % Failure
    Xnext = Xprev(end)+StepSize; % Staircase goes up
    if length(Resp)>NUps
        if sum(Resp(end-NUps:end-1))==NUps % Reversal: Up to Down
            Rev = Rev +1;
            Flag = true; % Flg - Flag for reversal adjustment, reset when number of reversals has changed
        end
    end
else % Success
    if length(Resp)>=NUps
        if sum(Resp(end-NUps+1:end))==NUps && Xprev(end)==Xprev(end-NUps+1)  % NUps consecutive successes for the same intensity
            Xnext = Xprev(end)-StepSize; % Staircase goes down
            if  length(Resp)>NUps % Reversal: Down to Up
                if Resp(end-NUps)== 0 %% 
                     Rev = Rev+1;
                     Flag = true;
                end
            end
        else Xnext = Xprev(end);  
        end
    else Xnext = Xprev(end);     
    end
    
end


if  ismember(Rev,[1,3,7]) && Flag  
    StepSize = StepSize/2;
end

if length(Resp)<6 || Rev<6
    Threshold = NaN;
else
    Threshold = mean(Xprev(end-5:end));
end
    
end
