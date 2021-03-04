function [] = visMultSims(mdp,pbo,slo)

yoff = -.8;
ms = 5;
lw = 1;

c1 = [220,20,60]/256;
c2 = [0,0,205]/256;
c3 = [123,104,238]/256;

if isequal(mdp(1).sim.tuned_parameter,'mu0') || ...
        isequal(mdp(1).sim.tuned_parameter,'SLval') || ...
        isequal(mdp(1).sim.tuned_parameter,'eps') || ...
        isequal(mdp(1).sim.tuned_parameter,'sub') || ...
        isequal(mdp(1).sim.tuned_parameter,'emx') || ...
        isequal(mdp(1).sim.tuned_parameter,'wcd') || ...
        isequal(mdp(1).sim.tuned_parameter,{'emx','wcd'})
    
    %x axis title
    if isequal(mdp(1).sim.tuned_parameter,'SLval')
        xlab = 'Stage Limit [h]';
    elseif isequal(mdp(1).sim.tuned_parameter,'eps')
        xlab = 'Epsilon';
    elseif isequal(mdp(1).sim.tuned_parameter,'sub')
        xlab = 'Spin Up Buffer [h]';
        xt = mdp(1).sim.tuning_array;
    elseif isequal(mdp(1).sim.tuned_parameter,'emx')
        xlab = 'Battery Size [kWh]';
        x = mdp(1).sim.tuning_array./1000;
        %xt = multStruct_mdp(1).sim.tuning_array;
    elseif isequal(mdp(2).sim.tuned_parameter,'wcd')
        xlab = 'WEC Size [m]';
        x = mdp(1).sim.tuning_array(2:end);      
    elseif isequal(mdp(1).sim.tuned_parameter,{'emx','wcd'})
        xlab = 'Battery Size [kWh]';
        x = mdp(1).sim.tuning_array1./1000;
    end
    %unpack structure array
    for i = 1:length(mdp)
        for j = 1:size(mdp,1)
            beta_avg(i,j,1) = mdp(j,i).output.beta_avg;
            power_avg(i,j,1) = mdp(j,i).output.power_avg;
            if exist('pbo','var')
                beta_avg(i,j,2) = pbo(j,i).output.beta_avg;
                power_avg(i,j,2) = pbo(j,i).output.power_avg;
            end
            if exist('slo','var')
                beta_avg(i,j,3) = slo(j,i).output.beta_avg;
                power_avg(i,j,3) = slo(j,i).output.power_avg;
            end
            %         for j = 1:length(multStruct(1).output.apct)
            %             % simulation x opmode x stoc/pb
            %             apct(i,j,1) = multStruct(i).output.apct(j);
            %             if isfield(multStruct,'pb')
            %                 apct(i,j,2) = multStruct(i).pb.output.apct(j);
            %             end
            %         end
        end
    end
    clear i j
    
    mdpresults = figure;
    ax(2) = subplot(1,1,1);
    for j = 1:size(mdp,2)
        plot(x,power_avg(:,j,1),'-o','MarkerEdgeColor',c1, ...
            'MarkerSize',ms,'Color',c1, ...
            'DisplayName','MDP','LineWidth',lw)
        if exist('pbo','var')
            hold on
            plot(x,power_avg(:,j,2),'-o','MarkerEdgeColor',c2, ...
                'MarkerSize',ms,'Color',c2, ...
                'DisplayName','Posterior Bound','LineWidth',lw)
        end
        if exist('slo','var')
            hold on
            plot(x,power_avg(:,j,3),'-o','MarkerEdgeColor',c3, ...
                'Color',c3, ...
                'MarkerSize',ms,'DisplayName','Simple Logic','LineWidth',lw)
        end
        lg2 = legend('show','Location','northoutside', ...
            'orientation','horizontal');
        lg2.FontSize = 10;
        %xlim([0 max(x)*1.15])
        ylim([min(power_avg(:))*.99 max(power_avg(:))*1.01])
        %ylim([0 max(power_avg(:))*1.01])
        ylabel({'Mean','Power','Consumed','[W]'})
        ylh = get(gca,'ylabel');
        set(ylh, 'Rotation',0,'Units','Inches', ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
        xlabel(xlab)
        xticks([3 4 5 6])
        if exist('xt','var')
            xticks(xt)
        end
        grid on
        set(gca,'FontSize',10)
        %title('Performance Metrics')
        set(gca,'Units','Inches')
        axp =  [1.25 0.5 4.5 2];
        set(gca,'Position',axp,'LineWidth',1)
    end
    
    set(gcf,'Units','Inches','Position', [1, 1, 6, 3])
    drawnow
    ylp = get(ylh, 'Position');
    ylp(1) = yoff;
    set(ylh,'Position',ylp)
    
    linkaxes(ax,'x')
    
    print(mdpresults,['~/Dropbox (MREL)/Research/General Exam/' ...
    'mdpresults'],'-dpng','-r600')
    
end
end

