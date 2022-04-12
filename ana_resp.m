% load all files
clear; addpath('psignifit');

Subjects = {'BW','XY','MKE','BH','MH'};
dot_lengths = [250, 500, 700];
curve_x = linspace(0.3,0.7,1000);
Curves = NaN(numel(Subjects),numel(dot_lengths),numel(curve_x));


for subject = Subjects

	Colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
	ax = np(3,1); set(gcf,'Position',[0 0 207 401]);

	for l_dot = dot_lengths
		[P_reds,resp_lr,rt_rep,confidence_rep] = load_data(['../../Results/' subject{1} '_' num2str(l_dot)]);
		result = fit_psych(resp_lr,P_reds); % fit psychometric curve

		% plot confidence rating
			plt_confidence(P_reds,confidence_rep,result,ax(l_dot==dot_lengths));
			title(ax(l_dot==dot_lengths),sprintf('%d ms',l_dot));

		% get fit for all subjects
			% [~,Curves(cellfun(@(x) strcmp(x,subject{1}),Subjects),l_dot==dot_lengths,:)] = get_y(result,curve_x);

		% plot psychmetric curve
			% data_color = Colors(l_dot==dot_lengths,:);
			% hdata = scatter(result.data(:,1),result.data(:,2)./result.data(:,3),'filled','SizeData',sqrt(30000./sum(result.data(:,3)).*result.data(:,3)),'MarkerEdgeColor','none','MarkerFaceColor',data_color,'MarkerFaceAlpha',0.5);
			% fitline(l_dot==dot_lengths) = plot(result.x,result.y,'Color',data_color);
	    
	end

	export_fig(sprintf('../Results/confidence_%s.pdf',subject{1}));
	% legend(fitline,{'250','500','700'});
	% title(subjectID);
end
return
save tmp P_reds resp_lr rt_rep confidence_rep result

% transform data

%% average psychometric curve
	sub_ind = [1 2 3 4 5];

	ax = np(numel(sub_ind)+1);
	arrayfun(@(i) plot(ax(i==sub_ind),curve_x,squeeze(Curves(i,:,:))), sub_ind);
	arrayfun(@(i) title(ax(i==sub_ind),Subjects{i}), sub_ind);

	% average trace
	h = plot(ax(end),curve_x,squeeze(mean(Curves(sub_ind,:,:),1)));

	% pick sample x
	sample_ind = 1:249:1000;
	sample_y   = squeeze(Curves(sub_ind,:,sample_ind));
	% plot actual errorbar
	Colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
	arrayfun(@(i) errorbar(ax(end),curve_x(sample_ind),squeeze(mean(sample_y(:,i,:),1)),squeeze(std(sample_y(:,i,:),[],1)),'.','Color',Colors(i,:),'MarkerSize',10,'LineStyle','none','LineWidth',1), 1:3);
	title(ax(end),'average');
	legend(h,arrayfun(@(x) num2str(x), dot_lengths, 'UniformOutput',false));

	% use my custom script
		% ax = np; Colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
		% arrayfun(@(i) plot_multiple_lines(squeeze(Curves(sub_ind,i,:)),ax,'base_color',Colors(i,:)), 1:3);


%% separate plotting of response
	ax = np;
	data_color = [0 0 1];
	hdata = scatter(result.data(:,1),result.data(:,2)./result.data(:,3),'filled','SizeData',sqrt(30000./sum(result.data(:,3)).*result.data(:,3)),'MarkerEdgeColor','none','MarkerFaceColor',data_color,'MarkerFaceAlpha',0.5);
	plot(result.x,result.y,'Color',data_color);

% quick analysis of response
% repeated_p = unique(P_reds(i_tr_start+1:end));
% plot(repeated_p,arrayfun(@(x) sum(resp_lr(P_reds==x)==80)/sum(P_reds==x), repeated_p));
% arrayfun(@(x) sum(P_reds==x), repeated_p);
% plot(unique(P_reds),arrayfun(@(x) sum(P_reds==x), unique(P_reds)));