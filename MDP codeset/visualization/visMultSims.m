function [] = visMultSims(multStruct)

if isequal(multStruct(1).sim.tuned_parameter,'mu0') || ...
        isequal(multStruct(1).sim.tuned_parameter,'SLval') || ...
        isequal(multStruct(1).sim.tuned_parameter,'eps') || ...
        isequal(multStruct(1).sim.tuned_parameter,'sub')
    
    %x axis title
    if isequal(multStruct(1).sim.tuned_parameter,'SLval')
        xlab = 'Stage Limit [h]';
    elseif isequal(multStruct(1).sim.tuned_parameter,'eps')
        xlab = 'Epsilon';
    elseif isequal(multStruct(1).sim.tuned_parameter,'sub')
        xlab = 'Spin Up Buffer [h]';
        xt = multStruct(1).sim.tuning_array;
    end
    %unpack structure array
    for i = 1:length(multStruct)
        beta_avg(i,1) = multStruct(i).output.beta_avg;
        power_avg(i,1) = multStruct(i).output.power_avg;
        for j = 1:length(multStruct(1).output.apct)
            % simulation x opmode x stoc/pb
            apct(i,j,1) = multStruct(i).output.apct(j);
            if isfield(multStruct,'pb')
                beta_avg(i,2) = multStruct(i).pb.output.beta_avg;
                power_avg(i,2) = multStruct(i).pb.output.power_avg;
                apct(i,j,2) = multStruct(i).pb.output.apct(j);
            end
        end
    end
    clear i j
    
    figure
    ax(1) = subplot(2,1,1);
    plot(multStruct(1).sim.tuning_array,beta_avg(:,1),'-bo','DisplayName', ...
        'Stochastic','LineWidth',1.3)
    if isfield(multStruct,'pb')
        hold on
        plot(multStruct(1).sim.tuning_array,beta_avg(:,2),'-ro','DisplayName', ...
            'Posterior Bound','LineWidth',1.3)
        legend('show')
    end
    xlim([0 max(multStruct(1).sim.tuning_array)*1.1])
    %ylim([0 10])
    ylabel({'Average','Beta Value'})
    ylh = get(gca,'ylabel');
    ylp = get(ylh, 'Position');
    ylp(1) = ylp(1)-.5;
    set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
        'HorizontalAlignment','center')
    xlabel(xlab)
    if exist('xt','var')
        xticks(xt)
    end
    grid on
    set(gca,'FontSize',16)
    title('Performance Metrics')
    axp = get(gca,'Position');
    axp(1) = 1.5*axp(1);
    set(gca,'Position',axp)
    
    %ca = {'-ro','-bo','-go','-co','--ro','--bo','--go','--co'};
    ax(2) = subplot(2,1,2);
    %     for i = 1:length(multStruct(1).output.apct)
    %         plot(multStruct(1).sim.tuning_array,apct(:,i,1),ca{i})
    %         hold on
    %         if isfield(multStruct,'pb')
    %             plot(multStruct(1).sim.tuning_array,apct(:,i,2),ca{4+i})
    %         end
    %     end
    plot(multStruct(1).sim.tuning_array,power_avg(:,1),'-bo','DisplayName', ...
        'Stochastic','LineWidth',1.3)
    if isfield(multStruct,'pb')
        hold on
        plot(multStruct(1).sim.tuning_array,power_avg(:,2),'-ro','DisplayName', ...
            'Posterior Bound','LineWidth',1.3)
        legend('show')
    end
    xlim([0 max(multStruct(1).sim.tuning_array)])
    %ylim([0 1])
    ylabel({'Average Operational','Power [W]'})
    ylh = get(gca,'ylabel');
    ylp = get(ylh, 'Position');
    ylp(1) = ylp(1)-.5;
    set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
        'HorizontalAlignment','center')
    xlabel(xlab)
    if exist('xt','var')
        xticks(xt)
    end
    grid on
    set(gca,'FontSize',16)
    axp = get(gca,'Position');
    axp(1) = 1.5*axp(1);
    set(gca,'Position',axp)
    
    set(gcf, 'Position', [100, 100, 1000, 500])
    
    linkaxes(ax,'x')
    
end
end

