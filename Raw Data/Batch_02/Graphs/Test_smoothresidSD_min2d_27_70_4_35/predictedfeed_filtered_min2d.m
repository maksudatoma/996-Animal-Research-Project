clear

%% DATA IMPORT
% load('HitsTEN.mat');
% load('AnimalTEN.mat');
% load('dateTEN.mat');
% load('goldTEN.mat');

% Hits=HitsTEN;
% Animal=AnimalTEN;
% date=dateTEN;

load('Hits_2.mat');
load('animal_2.mat');
load('date_2.mat');
load('healthmatrix_b2_pneumo.mat');

%% DATA PREPARATION
% Combining all columns into a 2-d array

ftime=Hits/3;
% This step is only necessary, if date is not importet as a number from 
% excel
% date=date-693960;

PigData=[animal date ftime];

mindate=min(date); 
maxdate=max(date);
NumDay=maxdate-mindate+1;
NumObs=max(size(PigData));
j=1; n=1; a=1; PigNum=1;
datec=zeros(NumDay,1);

%Sets a date table to fill in missing days (where system was completely down)
datec(1)=mindate;
for i=2:NumDay
    datec(i)=datec(i-1)+1;
end

date1=datec;

%Counts number of animals in the data file
for i=2:NumObs
    if animal(i)~=animal(i-1)
        PigNum=PigNum+1;
        date1=[date1 datec];
    end
end


%Creates a number of arrays with pignumbers in columns and dates in rows
aftime=zeros(NumDay,PigNum);
pftime=zeros(NumDay,PigNum);
zscore=zeros(NumDay,PigNum);
healthflag_All=zeros(NumDay,PigNum);
healthflag_chronic=zeros(NumDay,PigNum);
UniquePigNum=zeros(1,PigNum);
avgftime=zeros(1,PigNum);
start_slope=zeros(1,PigNum);
long_slope=zeros(1,PigNum);
checka=zeros(1,5);


%Create a date and aftime array ensuring that missing days are 0 -
%system down, pig missing, ear tag lost or pig sick.
k=111;
for i=1:NumObs
    if k==111
       UniquePigNum(j)=animal(i);
       if date(i)==datec(n)
           aftime(n,j)=ftime(i);
       end
       k=1;
       n=n+1;
    elseif animal(i-1)== animal(i) %check pig number, 
            % if = to the line above then move down one row
            % check if there is missing data for that line, 
            % add in the data, and
            % make actual feedtime equal to 0
       if date(i)==datec(n)
           aftime(n,j)=ftime(i); 
           n=n+1;
       else
           while date(i)~=datec(n) 
               aftime(n,j)=0;
               n=n+1;               
           end
           aftime(n,j)=ftime(i); 
           n=n+1;
  
       end
           
         % If the pig number in line a is not equal 
         % to pig number in line a-1 then start a new column
    else
       j=j+1;
       n=1;
       UniquePigNum(j)=animal(i);
       if date(i)==datec(n)
          aftime(n,j)=ftime(i);
       end
       n=n+1;
    end
end

% Save aftime under a different name to be able to see the system-off-days
% in the plots

raw_ftime=aftime;
       
% Make sure, that on all days, when the pig already left the barn (=no
% data), the aftime is set to 1e6 to prevent creation of FP

for j=1:PigNum
    endday=NumDay;
    while aftime(endday,j)==0
        aftime(endday,j)=1e6;
        endday=endday-1;
    end
end  

% Set aftime of days when system was off later than 6 AM or earlier than
% 8 PM, to 1e6
[off_days] = find_off_days(date1,NumDay);
Num_off_days=size(off_days,1);

for i=1:NumDay
    for j=1:Num_off_days
        if date1(i,1)==off_days(j)
            aftime(i,:)=1e6;
        end
    end
end

%% PREDICTION OF ILLNESS
% Creates a prediction of feeding time for each animal
% Change this section to get a moving window.

% Set threshold for z-score
threshold=-2.7;

% Set threshold for ongoing sickness (ongoing drop)as percentage of
% threshold
ongoing_thresh=0.7;

%Set windowsize to start with
WindowSizeStart=4;

%Set maximum WindowSize
WindowSizeMax=35;

%Set threshold to replace positive outliers (pigs lying at the feeder) by
%the predicted feeding time of the day before from a certain day on
pos_outlier=6;
outlier_start=14;

% Create prediction for feeding time and illness by analysing acute drops in
% feeding time
% [zscore,aftime,pftime,checka,healthflag_All,stdev,a]=UseWindow_filtered_smoothSD_min2d(PigNum,NumDay,date1,aftime,pftime,threshold,UniquePigNum,a,WindowSizeStart,WindowSizeMax,zscore,healthflag_All);
[zscore,aftime,pftime,checka,healthflag_All,stdev,a]=UseWindow_smooth_residualSD_min2d(PigNum,NumDay,date1,aftime,pftime,threshold,ongoing_thresh,pos_outlier,outlier_start,UniquePigNum,a,WindowSizeStart,WindowSizeMax,zscore,healthflag_All);

% Analyze starting period
% Define length of starting period to be analysed
% start_period=7+WindowSizeStart;
% Set threshold of lower limit for average feeding time during starting
% period
% ftime_threshold=10;
% Set threshold of slope for feeding time during starting period
% start_slope_threshold=0.0;
% Do predictions for bad start of fattening period
% [healthflag_chronic,avgftime,start_slope]=alarm_bad_start(PigNum,pftime,date1,avgftime,WindowSizeStart,start_slope,start_period,ftime_threshold,start_slope_threshold,healthflag_chronic);

% Look for long-time drops of predicted feeding time
% Define size of moving window
% slope_window_size=10;
% Set threshold of slope for feeding time during a long-time drop
% long_slope_threshold=-5;
% Do predictions for long time drops
% [healthflag_chronic,long_slope]=alarm_long_drop(PigNum,NumDay,pftime,date1,WindowSizeStart,long_slope,slope_window_size,long_slope_threshold,healthflag_chronic);

%healthevent=[39930 39940]; % start and end day of known health 
%                               event or time of interest

% truncate results to only days of interest as defined by healthevent

%firstrow=1;
%for i=1:max(size(datec))
 %   if datec(i)>=healthevent(1);
  %      if datec(i)<=healthevent(2);
   %         if firstrow==1;
    %            healthflag_trunc=healthflag_All(i,:);
     %           zscore_trunc=zscore(i,:);
      %          firstrow=firstrow+1;
       %     else
        %        healthflag_trunc=[healthflag_trunc;healthflag_All(i,:)];
         %       zscore_trunc=[zscore_trunc; zscore(i,:)];
          %  end
       % end
   % end
% end

%healthflag=healthflag_trunc;
            
numObs=NumDay*PigNum;

difference=healthmatrix-healthflag_All;

% Tally of correct predictions (TP and TN = Accuracy)
TypeCorrect=difference==0;
NumCorrect=sum(sum(TypeCorrect));
Accuracy=100*NumCorrect/numObs;

%Tally of sick days that have been predicted by the model (Sensitivity)
trueillness=healthmatrix>0;
TypeTP=healthflag_All & healthmatrix;
NumTypeTP=sum(sum(TypeTP));
Sensitivity=100*NumTypeTP/(sum(sum(trueillness)));

%Tally of healthy days that have been predicted by the model (Specificity)
healthzero=healthmatrix==0;
healthflagzero=healthflag_All==0;
compzero=healthzero + healthflagzero;
numbothzero=find(compzero==2);
NumTypeTN=numel(numbothzero);
Specificity=100*NumTypeTN/sum(sum(healthzero));

% Tally of actual sick days, on which model indicates a healthy day
% false negative
TypeFN=difference==1;
NumTypeFN=sum(sum(TypeFN));

% Tally of healthy days, on which model indicates a sick day
% false positive
TypeFP=difference==-1;
NumTypeFP=sum(sum(TypeFP));

% Calculation of Precision
Precision=100*NumTypeTP/(NumTypeTP+NumTypeFP);