function plt_curve_conf(result,P_reds,confidence_rep,ax,varargin)
	if nargin < 4 || isempty(ax)
		ax = np; 
	end

	% parser
	p = inputParser;
	addParameter(p,'c',[0 0 0]);
	parse(p,varargin{:});

	xlabel(ax,'% green dot');
	yyaxis(ax,'left'); ylabel(ax,'% right response'); 
	plot(ax,result.x,result.y,'-','Color',p.Results.c); 

	yyaxis(ax,'right'); ylim(ax,[0.5 5.5]); ylabel(ax,{'Confidence rating','size = # trs'});
	for p_red = unique(P_reds)
		% scatter(p,)
		conf_p = confidence_rep(P_reds==p_red);
		h = arrayfun(@(conf) scatter(ax,p_red,conf,sum(conf_p==conf)*10,'filled','MarkerFaceColor',p.Results.c,'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none'), unique(conf_p));
	end

end