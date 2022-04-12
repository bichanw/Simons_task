function result = fit_psych(resp_lr,P_reds,correct_resp)
% organize data
% data = [unique(P_reds),...
% 		arrayfun(@(x) sum(resp_lr(P_reds==x)==80)/sum(P_reds==x), unique(P_reds)),...
% 		arrayfun(@(x) sum(P_reds==x), unique(P_reds))];
if nargin < 3 && sum(resp_lr==80)>0
	correct_resp = 80;
elseif nargin < 3
	correct_resp = 37;
end
data = [unique(P_reds);...
		arrayfun(@(x) sum(resp_lr(P_reds==x)==correct_resp)/sum(P_reds==x), unique(P_reds));...
		arrayfun(@(x) sum(P_reds==x), unique(P_reds))]';

options=struct;
result=psignifit(data,options);
[result.x,result.y] = get_y(result);
% plotPsych(result);

end
