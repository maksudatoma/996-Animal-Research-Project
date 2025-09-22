% This script plots a graph with actual and predicted feeding time for each
% animal of a batch. It also marks the days with healthflag (model
% predictions) with blue stars on the line of the predicted feeding time 
% and adds green triangles for all days with diagnosed pneumonia as well 
% as red squares for all days wit other diagnoses.

% !!predicted_filtered has to be run before running plot_sick!!

load('date_sick_2.mat');
load('sick_animal_2.mat');
load('diagnosis_2.mat');

NumObsi=size(checka,1);
NumObsj=size(UniquePigNum,2);
%NumObsj=1;
NumObsk=size(date1,1);
begin=min(date);
ending=max(date);
a=1;
x=0;
h=1;

days_fattening=(date1-date1(1,1))+1;
date_sick_fattening=(date_sick-date1(1,1))+1;
checka_fattening=[checka (checka(:,2)-date1(1,1))];

% To plot not only the sick animals but all animals, activate the
% following lines:

for j=1:NumObsj
    pigsick=any(checka(:,1)==UniquePigNum(j));
    if pigsick==0
       % open a figure window
       figure; 
       %create a figure with actual and predicted feed time
       plot(days_fattening(1:NumObsk,j), aftime(1:NumObsk,j), '--m.', days_fattening(1:NumObsk,j), pftime(1:NumObsk,j),'-r',days_fattening(1:NumObsk,j), raw_ftime(1:NumObsk,j), '--k' ,days_fattening(1:NumObsk,j), stdev(1:NumObsk,j),'-y','Linewidth',1.2);
       %plot(date1(1:NumObsk,j), aftime(1:NumObsk,j), '--m.', date1(1:NumObsk,j), pftime(1:NumObsk,j),'-r', date1(1:NumObsk,j), stdev(1:NumObsk,j),'-y','Linewidth',1.2);
       axis([0 135 0 250]);
       %label figure
       PigN = num2str(UniquePigNum(j));
       title (PigN);
       legend ('Actual feed time','Predicted feed time','Raw feed time','Standard deviation');
       %legend ('actual feed time','predicted feed time','SD');
       xlabel('Days in barn');
       ylabel('Time at feeder (min)');       
       
       hold on
       %Plot Markers on days, when the pig was sick
       for g=1:size(sick_animal,1)
                if sick_animal(g)==UniquePigNum(j)
                    if diagnosis(g)=='Pneumonia'
                    plot(date_sick_fattening(g,1),10,'^g', 'MarkerSize',12,'Markerfacecolor','green');
                    else
                    plot(date_sick_fattening(g,1),10,'sr','Markersize',12,'MarkerFaceColor','red');
                    end
                end
       end
       
       %Plot Marker, if pig had a bad start of the fattening period or
       %a long-time drop
       for m=1:NumDay
           if healthflag_chronic(m,j)==1
               plot(days_fattening(m,j),6,'oc','MarkerSize',12,'Markerfacecolor','cyan'); 
               hold on
           end
       end
      
        savefig(PigN);
        hold off;
    end
end
        
% Plot graphs of animals predicted sick
for i=1:NumObsi
    if i>1 
        if checka(i,1)~=checka(i-1,1)
        for j=1:NumObsj
            % Find pig number
           if checka(i,1)== UniquePigNum(j)
               % find the ending date for each pig - for graph
               for d=1:NumObsk
                    if date1(d,j)~= 0
                       x=1+x;
%                        shouldn't x be =NumObsk? (because date1 has the
%                        same size for all pigs and is never==0)                
                    end
               end
               
                % Open a figure window
                figure; 
                %Create a figure with actual and predicted feed time
                plot(days_fattening(1:x,j), aftime(1:x,j), '--m.', days_fattening(1:x,j), pftime(1:x,j),'-r', days_fattening(1:x,j), raw_ftime(1:x,j), '--k' ,days_fattening(1:x,j), stdev(1:x,j),'-y','Linewidth',1.2);
                %plot(date1(1:x,j), aftime(1:x,j), '--m.', date1(1:x,j), pftime(1:x,j),'-r', date1(1:x,j), stdev(1:x,j),'-y','Linewidth',1.2);
                axis([0 135 0 250]);
                %Label figure
                PigN = num2str(UniquePigNum(j));
                title (PigN);
                legend ('Actual feed time','Predicted feed time','Raw feed time','Standard deviation');
                %legend ('actual feed time','predicted feed time','SD');
                xlabel('Days in barn');
                ylabel('Time at feeder (min)');
                
                hold on

            % Add points to graph for healthflags
            for c=1:NumObsi
                    if checka(i,1)==checka(c,1)
                      plot(checka_fattening(c,6),checka(c,4),'*b','MarkerSize',12);
                      hold on
                    end
            end
            
            %Plot Marker, if pig had a bad start of the fattening period or
            %a long-time drop
            for m=1:NumDay
                if healthflag_chronic(m,j)==1
                    plot(days_fattening(m,j),6,'oc','MarkerSize',12,'Markerfacecolor','cyan'); 
                hold on
                end
            end
            
            %Plot Markers on days, when the pig was sick
            for g=1:size(sick_animal,1)
                if sick_animal(g)==UniquePigNum(j)
                    if diagnosis(g)=='Pneumonia'
                    plot(date_sick_fattening(g,1),10,'^g','MarkerSize',12,'Markerfacecolor','green'); 
                    else
                    plot(date_sick_fattening(g,1),10,'sr','Markersize',12,'MarkerFaceColor','red');
                    end           
                end
            end    
            savefig(PigN);
            hold off;
            x=0;      
           end
       end
       end
    else
    for j=1:NumObsj
            % Find pig number
           if checka(i,1)== UniquePigNum(j)
               % find the ending date for each pig - for graph
               for d=1:NumObsk
                    if date1(d,j)~= 0
                       x=1+x;
%                        shouldn't x be =NumObsk? (because date1 has the
%                        same size for all pigs and is never==0)               
                    end
               end
                %Open a figure window
                figure ; 
                %Create a figure with actual and predicted feed time
                plot(days_fattening(1:x,j), aftime(1:x,j), '--m.',days_fattening(1:x,j), pftime(1:x,j),'-r', days_fattening(1:x,j), raw_ftime(1:x,j), '--k', days_fattening(1:x,j), stdev(1:x,j), '-y','Linewidth',1.2);
                %plot(date1(1:x,j), aftime(1:x,j), '--m.', date1(1:x,j), pftime(1:x,j),'-r', date1(1:x,j), stdev(1:x,j),'-y','Linewidth',1.2);
                axis([0 135 0 250]);
                %Label figure
                PigN = num2str(UniquePigNum(j));
                title (PigN);
                legend ('Actual feed time','Predicted feed time', 'Raw feed time','Standard deviation');
                %legend ('actual feed time','predicted feed time','SD');
                xlabel('Days in barn');
                ylabel('Time at feeder (min)');
                hold on


            % Add points to graph for healthflags
            for c=1:NumObsi
                    if checka(i,1)==checka(c,1)
                      plot(checka_fattening(c,6),checka(c,4),'*b','MarkerSize',12);
                     
                    hold on
                    end
            end
            
            %Plot Marker, if pig had a bad start of the fattening period
            %or a long-time drop
            for m=1:NumDay
                if healthflag_chronic(m,j)==1
                    plot(days_fattening(m,j),6,'oc','MarkerSize',12,'Markerfacecolor','cyan'); 
                hold on
                end
            end
            
            %Plot Markers on days, when the pig was sick
            for g=1:size(sick_animal,1)
                if sick_animal(g)==UniquePigNum(j)
                    if diagnosis(g)=='Pneumonia'
                    plot(date_sick_fattening(g,1),10,'^g', 'MarkerSize',12,'Markerfacecolor','green');
                    else
                    plot(date_sick_fattening(g,1),10,'sr','Markersize',12,'MarkerFaceColor','red');
                    end
                end
            end    
            savefig(PigN);
            hold off;
            x=0;
           end
    end
    end
end

    