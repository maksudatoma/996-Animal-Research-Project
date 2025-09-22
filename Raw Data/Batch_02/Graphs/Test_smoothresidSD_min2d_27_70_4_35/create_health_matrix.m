%This script reads in animal IDs and dates of one batch, combines it with
%the health monitoring data of the animal caretakers and creates a matrix
%that gives information about the health status of the animals on each day
%of the feeding period (healthy, pneumonia, inflammation, lameness, open
%wound, rough)

clear

%Load data from RFID system and health monitoring
load ('animal.mat');
load ('date.mat');
load ('date_sick.mat');
load ('sick_animal.mat');
load ('diagnosis.mat');

%Assign data to variables
%animal=animal;
%date=date;
SickAnimal=sick_animal;
DateSick=date_sick;
Diagnosis=diagnosis;


%Calculate feeding period
mindate=min(date); 
maxdate=max(date);
NumDay=maxdate-mindate+1;

%Calculate number of RFID observations (pig feed days)and number of
%sickness observations
NumObs=size(animal,1);
NumSickDays=size(SickAnimal,1);

%Create vector with zeros on all days of feeding period
datecomplete=zeros(NumDay,1);

%Create a date vector with numbers for all days of feeding period 
datecomplete(1)=mindate;
for i=2:NumDay
    datecomplete(i)=datecomplete(i-1)+1;
end

%Count number of animals in the data file
PigNum=1;
for i=2:NumObs
    if animal(i)~=animal(i-1)
        PigNum=PigNum+1;
    end
end

%Create vector of zeros for diagnosis indexing
DiagnosisIndex=zeros(NumSickDays,1);

%Assign values to vector DiagnosisIndex based on healthmonitoring data
for i=1:NumSickDays
    if Diagnosis(i)=='Pneumonia'
        DiagnosisIndex(i)=1;
    %Reactivate to look at more than pneumonia    
    %elseif Diagnosis(i)=='Inflamation'
    %    DiagnosisIndex(i)=2;
    %elseif Diagnosis(i)=='Lame'
    %    DiagnosisIndex(i)=3;
    %elseif Diagnosis(i)=='Open Wound'
    %    DiagnosisIndex(i)=4;
    %elseif Diagnosis(i)=='Rough'
    %    DiagnosisIndex(i)=5;
    %elseif Diagnosis (i)=='Abscess'
    %    DiagnosisIndex(i)=6;
    %elseif Diagnosis (i)=='Scours'
    %    DiagnosisIndex(i)=7;
    else
        DiagnosisIndex(i)=0;
    %   DiagnosisIndex(i)=8;
    end
end
        
%Create healthmatrix with zeros (number of pigs columns and number of 
%dates rows) and row vector for pig number with zeros (number of pigs 
%in columns)

healthmatrix=zeros(NumDay, PigNum);
UniquePigNum=zeros(1, PigNum);

%Fill in AnimalIDs to vector UniquePigNum
p=222;
j=1;
for i=1:NumObs
    if p==222
       UniquePigNum(j)=animal(i);
       p=1;
    elseif animal(i-1)==animal(i)
       UniquePigNum(j)=UniquePigNum(j);
    elseif animal(i-1)~=animal(i)
        j=j+1;
        UniquePigNum(j)=animal(i);
    end
end

%Create a date and health status array 
for k=1:PigNum
    for i=1:NumDay
        for m=1:NumSickDays
            if DateSick(m)==datecomplete(i)
                if SickAnimal(m)==UniquePigNum(k)
                healthmatrix(i,k)=DiagnosisIndex(m);
                end
            end   
        end
    end
end



