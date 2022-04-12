function [P_reds,resp_lr,rt_rep,confidence_rep] = load_data(subjectID)

P_reds = []; resp_lr = []; rt = []; confidence_rep = [];
for iFile = 1:numel(dir(['Results/' subjectID '*']))-1
	load(['Results/' subjectID '_' num2str(iFile) '.mat']);
	P_reds  = [P_reds; P_reds_rep'];
	resp_lr = [resp_lr;resp_lr_rep];
	rt_rep  = [rt; rt_rep];
	confidence_rep = [confidence_rep; confidence];
end

if max(confidence_rep)<49
	confidence_rep = confidence_rep - 29;
else
	confidence_rep = confidence_rep - 48;
end