function plt_confidence(P_reds,confidence_rep,result,ax)
	if nargin < 4
		ax = np; 
	end

	all_coherence = unique(abs(result.data(:,1)-0.5));
	for iCoherence = 1:5
		coherence_mat(iCoherence,:) = arrayfun(@(conf) sum(confidence_rep==conf&abs(P_reds-0.5)'==all_coherence(iCoherence,1)), 1:5);
	end

	% ax = np;
	imagesc(ax,1:5,1:5,coherence_mat);
	colormap(cbrewer2('OrRd'));
	set(ax,'YTick',1:5,'YTickLabel',arrayfun(@(x) sprintf('%.1f',x*100), all_coherence,'UniformOutput',false),'YLim',[0.5 5.5],...
		   'XTick',1:5,'XLim',[0.5 5.5]);
	xlabel(ax,'rating'); ylabel(ax,'Coherence (%)');
	c = colorbar(ax); c.Label.String = '# Trial';
	


	% old plotting with lines
	% Colors = flip(cbrewer2('RdYlBu',numel(all_coherence)),1);

	% % plotting
	% for iCoherence = 1:numel(all_coherence)
	% 	plot(ax,1:5,arrayfun(@(conf) sum(confidence_rep==conf&abs(P_reds-0.5)'==all_coherence(iCoherence,1)), 1:5),'.-','Color',Colors(iCoherence,:),'MarkerSize',9);
	% end
	% % figure labels
	% xlabel(ax,'confidence rating'); ylabel(ax,'# responses'); set(ax,'XLim',[1 5]);
	% % all colorbar setting
	% c = colorbar(ax,'Ticks',linspace(0,1,5),'TickLabels',arrayfun(@(x) sprintf('%.2f',x), all_coherence+0.5, 'UniformOutput',false)); colormap(Colors); 


end
