function plt_confidence(P_reds,confidence_rep,result,ax)
	if nargin < 4
		ax = np; 
	end

	all_coherence = unique(abs(result.data(:,1)-0.5));
	Colors = flip(cbrewer2('RdYlBu',numel(all_coherence)),1);

	% plotting
	for iCoherence = 1:numel(all_coherence)
		plot(ax,1:5,arrayfun(@(conf) sum(confidence_rep==conf&abs(P_reds-0.5)'==all_coherence(iCoherence,1)), 1:5),'.-','Color',Colors(iCoherence,:),'MarkerSize',9);
	end
	% figure labels
	xlabel(ax,'confidence rating'); ylabel(ax,'# responses'); set(ax,'XLim',[1 5]);
	% all colorbar setting
	c = colorbar(ax,'Ticks',linspace(0,1,5),'TickLabels',arrayfun(@(x) sprintf('%.2f',x), all_coherence+0.5, 'UniformOutput',false)); colormap(Colors); 


end
