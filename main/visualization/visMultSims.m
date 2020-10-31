function [] = visMultSims(multStruct_mdp,multStruct_pb,multStruct_sl)

yoff = 1.3;
ms = 10;
lw = 2.5;

c1 = [220,20,60]/256;
c2 = [0,0,205]/256;
c3 = [123,104,238]/256;

if isequal(multStruct_mdp(1).sim.tuned_parameter,'mu0') || ...
        isequal(multStruct_mdp(1).sim.tuned_parameter,'SLval') || ...
        isequal(multStruct_mdp(1).sim.tuned_parameter,'eps') || ...
        isequal(multStruct_mdp(1).sim.tuned_parameter,'sub') || ...
        isequal(multStruct_mdp(1).sim.tuned_parameter,'emx')
    
    %x axis title
    if isequal(multStruct_mdp(1).sim.tuned_parameter,'SLval')
        xlab = 'Stage Limit [h]';
    elseif isequal(multStruct_mdp(1).sim.tuned_parameter,'eps')
        xlab = 'Epsilon';
    elseif isequal(multStruct_mdp(1).sim.tuned_parameter,'sub')
        xlab = 'Spin Up Buffer [h]';
        xt = multStruct_mdp(1).sim.tuning_array;
    elseif isequal(multStruct_mdp(1).sim.tuned_parameter,'emx')
        xlab = 'Battery Size [kWh]';
        x = multStruct_mdp(1).sim.tuning_array./1000;
        %xt = multStruct_mdp(1).sim.tuning_array;        
    end
    %unpack structure array
    for i = 1:length(multStruct_mdp)
        beta_avg(i,1) = multStruct_mdp(i).output.beta_avg;
        power_avg(i,1) = multStruct_mdp(i).output.power_avg;
        if exist('multStruct_pb','var')
            beta_avg(i,2) = multStruct_pb(i).output.beta_avg;
            power_avg(i,2) = multStruct_pb(i).output.power_avg;
        end
        if exist('multStruct_sl','var')
            beta_avg(i,3) = multStruct_sl(i).output.beta_avg;
            power_avg(i,3) = multStruct_sl(i).output.power_avg;
        end
%         for j = 1:length(multStruct(1).output.apct)
%             % simulation x opmode x stoc/pb
%             apct(i,j,1) = multStruct(i).output.apct(j);
%             if isfield(multStruct,'pb')
%                 apct(i,j,2) = multStruct(i).pb.output.apct(j);
%             end
%         end
    end
    clear i j
    
    figure
%     ax(1) = subplot(2,1,2);
%     plot(x,beta_avg(:,1),'-ro','MarkerEdgeColor','r', ... 
%          'MarkerFaceColor','r','MarkerSize',ms, ...
%         'DisplayName','Stochastic','LineWidth',lw)
%     if exist('multStruct_pb','var')
%         hold on
%         plot(x,beta_avg(:,2),'-bo','MarkerEdgeColor','b', ...
%             'MarkerFaceColor','b','MarkerSize',ms, ...
%             'DisplayName','Posterior Bound','LineWidth',lw)
%     end
%     if exist('multStruct_sl','var')
%         hold on
%         plot(x,beta_avg(:,3),'-o','MarkerEdgeColor',[204,204,0]/256, ... 
%             'MarkerFaceColor',[204,204,0]/256,'Color',[204,204,0]/256, ...
%             'MarkerSize',ms,'DisplayName','Simple Logic','LineWidth',lw)
%     end
% %     lg1 = legend('show');
% %     lg1.FontSize = 12;
%     %xlim([-inf max(x)*1.35])
%     ylim([min(beta_avg(:)*.3) max(beta_avg(:)*1.1)])
%     ylabel({'Mean','Battery','Penalty [~]'})
%     ylh = get(gca,'ylabel');
%     ylp = get(ylh, 'Position');
%     ylp(1) = ylp(1)-yoff;
%     set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
%         'HorizontalAlignment','center')
%     xlabel(xlab)
%     if exist('xt','var')
%         xticks(xt)
%     end
%     grid on
%     set(gca,'FontSize',16)
%     axp = get(gca,'Position');
%     axp(1) = 1.5*axp(1);
%     set(gca,'Position',axp,'LineWidth',2)
    
    %ca = {'-ro','-bo','-go','-co','--ro','--bo','--go','--co'};
    ax(2) = subplot(1,1,1);
    %     for i = 1:length(multStruct(1).output.apct)
    %         plot(multStruct(1).sim.tuning_array,apct(:,i,1),ca{i})
    %         hold on
    %         if isfield(multStruct,'pb')
    %             plot(multStruct(1).sim.tuning_array,apct(:,i,2),ca{4+i})
    %         end
    %     end
    plot(x,power_avg(:,1),'-o','MarkerEdgeColor',c1, ... 
         'MarkerSize',ms,'Color',c1, ...
        'DisplayName','Stochastic','LineWidth',lw)
    if exist('multStruct_pb','var')
        hold on
        plot(x,power_avg(:,2),'-o','MarkerEdgeColor',c2, ...
            'MarkerSize',ms,'Color',c2, ...
            'DisplayName','Posterior Bound','LineWidth',lw)
    end
    if exist('multStruct_sl','var')
        hold on
        plot(x,power_avg(:,3),'-o','MarkerEdgeColor',c3, ... 
            'Color',c3, ...
            'MarkerSize',ms,'DisplayName','Simple Logic','LineWidth',lw)
    end 
%     lg2 = legend('show','Location','northoutside', ... 
%         'orientation','horizontal');
%     lg2.FontSize = 12;
    xlim([0 max(x)*1.15])
    ylim([min(power_avg(:))*.99 max(power_avg(:))*1.01])
    %ylim([0 max(power_avg(:))*1.01])    
    %ylabel({'Mean','Operational','Power [W]'})
    ylh = get(gca,'ylabel');
    ylp = get(ylh, 'Position');
    ylp(1) = ylp(1)-yoff;
    set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
        'HorizontalAlignment','center')
    %xlabel(xlab)
    if exist('xt','var')
        xticks(xt)
    end
    grid on
    set(gca,'FontSize',20)
    %title('Performance Metrics')
    axp = get(gca,'Position');
    %axp(1) = 1.5*axp(1);
    set(gca,'Position',axp,'LineWidth',1.4)
    
    set(gcf, 'Position', [100, 100, 800, 500])
    
    linkaxes(ax,'x')
    
end
end

