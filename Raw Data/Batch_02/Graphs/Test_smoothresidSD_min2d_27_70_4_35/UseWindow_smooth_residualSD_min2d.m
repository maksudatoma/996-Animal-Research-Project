function [zsc,aft,pft,cha,hfA,sd,aa]=UseWindow_smooth_residualSD_min2d(PigNum,NumDay,date1,aftime,pftime,threshold,ongoing_thresh,pos_outlier,outlier_start,UniquePigNum,a,WindowSizeStart,WindowSizeMax,zscore,healthflag_All)

%% Assignment of variables and data preparation

% Set first day of alarms being shown in graphs
daythreshold=2;

% Set first and last day to include in analysis
firstday=1;
lastday=NumDay-1;

% Make sure that aftime on the first days is not 1e6, replace this
% value by the aftime of the first day the function UseAll_filtered uses to predict
% the feeding time (pftime). In this way a reasonable start of the model is
% ensured.

for j=1:PigNum
    startday=firstday;
    for i=1:WindowSizeStart
        if aftime(i,j)>999999
           while aftime(startday,j)>999999
               startday=startday+1;
           end
           aftime(i,j)=aftime(startday,j); 
        end
    end
end   

% Create feed time matrix for smoothening standard deviation
aftime_SD=aftime;

% Create a prediction for feeding time of each pig on each day

for j=1:PigNum
    WindowSize=WindowSizeStart;
    
%% Growing window
        while WindowSize<WindowSizeMax
            bottom=firstday;
            top=bottom+WindowSize-1;
            x=date1(bottom:top,j);            
            y=aftime(bottom:top,j);
         % Regression
            Beta=polyfit(x,y,1);
         % Prediction
            pftime(top+1,j)= Beta(1,1)*date1(top+1,j)+Beta(1,2);
            
         % On uncomplete days the aftime (set to 1e6) is replaced by
         % the predicted ftime of the respective day, preventing FP on these
         % days
            if aftime(top+1,j)>999999
                aftime(top+1,j)=pftime(top+1,j);
                aftime_SD(top+1,j)=pftime(top+1,j);
            end
            
         % Create vector of residuals from predicted feeding time to
         % calculate the standard deviation of these residuals
            residual=zeros(top,1);
            for c=bottom:top
                if c<(firstday+WindowSizeStart)
                    % Do nothing
                else 
                    residual(c)=pftime(c,j)-aftime_SD(c,j);
                end
            end
         
         % Calculate the standard deviation according to certain conditions
            if (top+1)<=(firstday+WindowSizeStart+1)
                stdev(top+1,j)=std(y);
            else
                stdev(top+1,j)=std(residual((firstday+WindowSizeStart):top,1));
            end
                    
         % Calculate difference between actual and predicted feeding time
            diff(top+1,j)=aftime(top+1,j)-pftime(top+1,j);
            
         % If stdev is = 0 then zscore is equal to infinity, this prevents
         % this
            if stdev(top+1,j)< 0.00001
                %zscore1(top+1,j)=0;
                zscore(top+1,j)=0;
            else
         % Calculate Z-Score
                zscore(top+1,j)=diff(top+1,j)/stdev(top+1,j);
                % zscore1(n,j)=abs(zscore(n,j));
                % Uncomment the above line to capture both + and - events
            end
            
         % Set healthflags according to certain conditions
            if zscore(top+1,j)<=threshold
         % Make sure that only alarms with an at least 2d-drop of
         % feeding time are maintained
                if zscore(top,j)<=threshold
         % Activate the following if-loop to exclude alarm days before
         % daythreshold
                    if date1(top+1,j)-min(date1)>=daythreshold
         % Set healthflag
                        healthflag_All(top+1,j)=1;
         % Entry in list of sick pigdays
                        checka(a,:)=[UniquePigNum(j) date1(top+1,j) aftime(top+1,j) pftime(top+1,j) zscore(top+1,j)];
                        a=a+1;
         % Smoothen standard deviation
                        aftime_SD(top+1,j)=pftime(top+1,j);
                    end
                end
         % Set healthflag for ongoing drop in feeding time
            else if zscore(top+1,j)<=ongoing_thresh*threshold
                    if healthflag_All(top,j)==1
         % Set healthflag
                     healthflag_All(top+1,j)=1;
         % Entry in list of sick pigdays
                     checka(a,:)=[UniquePigNum(j) date1(top+1,j) aftime(top+1,j) pftime(top+1,j) zscore(top+1,j)];
                     a=a+1;
         % Smoothen standard deviation
                     aftime_SD(top+1,j)=pftime(top+1,j);
                    end
                end
            end
         % For positive outliers set actual feeding time to value of the day before to smoothen
         % predicted feeding time and standard deviation
            if zscore(top+1,j)>=pos_outlier
                if (top+1)>=outlier_start
                    aftime(top+1,j)=pftime(top+1,j);
                    aftime_SD(top+1,j)=pftime(top+1,j);
                end
            end        
            WindowSize=WindowSize+1; 
        end
        
%% Moving window
        for i=(WindowSizeMax):lastday
            bottom=i-(WindowSizeMax-1);
            top=bottom+WindowSizeMax-1;
            x=date1(bottom:top,j);            
            y=aftime(bottom:top,j);
         % Regression
            Beta=polyfit(x,y,1);
         % Prediction
            pftime(top+1,j)= Beta(1,1)*date1(top+1,j)+Beta(1,2);
            
         % On uncomplete days the aftime (set to 1e6) is replaced by
         % the predicted ftime of the respective day, preventing FP on these
         % days
            if aftime(top+1,j)>999999
                aftime(top+1,j)=pftime(top+1,j);
                aftime_SD(top+1,j)=pftime(top+1,j);
            end
            
         % Create vector of residuals from predicted feeding time to
         % calculate the standard deviation of these residuals
            residual=zeros(top,1);
            for c=bottom:top
                if c<(firstday+WindowSizeStart)
                    %Do nothing
                else 
                    residual(c)=pftime(c,j)-aftime_SD(c,j);
                end
            end
         % Calculate the standard deviation according to certain conditions
         if bottom<(firstday+WindowSizeStart)
            stdev(top+1,j)=std(residual((firstday+WindowSizeStart):top,1));
         else
             stdev(top+1,j)=std(residual(bottom:top,1));
         end    
         % Calculate difference between actual and predicted feeding time  
            diff(top+1,j)=aftime(top+1,j)-pftime(top+1,j);
            
         % If stdev is = 0 then zscore is equal to infinity, this prevents
         % this
            if stdev(top+1,j)< 0.00001
                %zscore1(i,j)=0;
                zscore(top+1,j)=0;
            else
         % Calculate Z-Score
                zscore(top+1,j)=diff(top+1,j)/stdev(top+1,j);
                % zscore1(n,j)=abs(zscore(n,j));
                % Uncomment the above line to capture both + and - events
            end
            
         % Set healthflags according to certain conditions
            if zscore(top+1,j)<=threshold 
         % Make sure that only alarms with an at least 2d-drop of
         % feeding time are maintained
                if zscore(top,j)<=threshold
         % Activate the following if-loop to exclude alarm days before
         % daythreshold
                    if date1(top+1,j)-min(date1)>=daythreshold
         % Set healthflag
                    healthflag_All(top+1,j)=1;
         % Entry in list of sick pigdays
                    checka(a,:)=[UniquePigNum(j) date1(top+1,j) aftime(top+1,j) pftime(top+1,j) zscore(top+1,j)];
                    a=a+1;
         % Smoothen standard deviation
                    aftime_SD(top+1,j)=pftime(top+1,j);
                    end
                end
         % Set healthflag for ongoing drop in feeding time
            else if zscore(top+1,j)<=ongoing_thresh*threshold
                    if healthflag_All(top,j)==1
         % Set healthflag
                     healthflag_All(top+1,j)=1;
         % Entry in list of sick pigdays
                     checka(a,:)=[UniquePigNum(j) date1(top+1,j) aftime(top+1,j) pftime(top+1,j) zscore(top+1,j)];
                     a=a+1;
         % Smoothen standard deviation
                     aftime_SD(top+1,j)=pftime(top+1,j);            
                    end
                end
            end
            
         % For positive outliers set actual feeding time to value of the day before to smoothen
         % predicted feeding time and standard deviation
             if zscore(top+1,j)>=pos_outlier
                if (top+1)>=outlier_start
                    aftime(top+1,j)=pftime(top+1,j);
                    aftime_SD(top+1,j)=pftime(top+1,j);
                end
             end        
        end  
end
%% Assignment of function output variables
zsc=zscore;
aft=aftime;
pft=pftime;
cha=checka;
hfA=healthflag_All;
sd=stdev;
aa=a;
end
