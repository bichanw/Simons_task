% load all files
clear;
subjectID = 'test3';
P_reds = []; resp_lr = []; rt = [];
for iFile = 1:numel(dir(['Results/' subjectID '*']))-1
	load(['Results/' subjectID '_' num2str(iFile) '.mat']);
	P_reds  = [P_reds; P_reds_rep'];
	resp_lr = [resp_lr;resp_lr_rep];
	rt_rep  = [rt; rt_rep];
end


% organize data
% data = [unique(P_reds),...
% 		arrayfun(@(x) sum(resp_lr(P_reds==x)==80)/sum(P_reds==x), unique(P_reds)),...
% 		arrayfun(@(x) sum(P_reds==x), unique(P_reds))];
data = [unique(P_reds);...
		arrayfun(@(x) sum(resp_lr(P_reds==x)==80)/sum(P_reds==x), unique(P_reds));...
		arrayfun(@(x) sum(P_reds==x), unique(P_reds))]';
addpath('psignifit');
options=struct;
result=psignifit(data,options);
plotPsych(result);

% quick analysis of response
% repeated_p = unique(P_reds(i_tr_start+1:end));
% plot(repeated_p,arrayfun(@(x) sum(resp_lr(P_reds==x)==80)/sum(P_reds==x), repeated_p));
% arrayfun(@(x) sum(P_reds==x), repeated_p);
% plot(unique(P_reds),arrayfun(@(x) sum(P_reds==x), unique(P_reds)));