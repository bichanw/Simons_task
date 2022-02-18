% quick analysis of response
repeated_p = unique(P_reds(i_tr_start+1:end));
plot(repeated_p,arrayfun(@(x) sum(resp_lr(P_reds==x)==80)/sum(P_reds==x), repeated_p));
plot(unique(P_reds),arrayfun(@(x) sum(P_reds==x), unique(P_reds)));