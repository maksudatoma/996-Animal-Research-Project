function [od] = find_off_days(date1,NumDay)
% Looks through a list of first and last hits of a day and sorts out days
% when the system was off

% The function goes through the list of days and looks for late min. times
% or early max. times (times of  first or last hit of a farrowing group at
% a certain day). If two or more farrowing groups were in a batch, it only
% sorts out days, when all farrowing groups had the same late min. time or
% early max. time.

load('Daily_mintime_2.mat');
load('Daily_maxtime_2.mat');
load('All_days_2.mat');
b=1;
c=1;
NumAlldays=size(All_days,1);

% Set off_days to 0, so that the main program can work with this, even if no
% off_days were recorded during this batch
off_days=[0];

% Fill in missing days, where the system was off the whole day
curr_day=All_days(1);
for i=1:NumAlldays
    if i<NumAlldays
        if All_days(i)==curr_day
            All_days_compl(c,1)=All_days(i);
            Daily_mintime_compl(c,1)=Daily_mintime(i);
            Daily_maxtime_compl(c,1)=Daily_maxtime(i);
            if All_days(i+1)==All_days(i)
                % Do nothing
            else
                curr_day=curr_day+1;
            end
                c=c+1;
        else
            while All_days(i)~=curr_day
                    All_days_compl(c,1)=All_days_compl(c-1,1)+1;
                    Daily_mintime_compl(c,1)=2;
                    Daily_maxtime_compl(c,1)=2;
                    curr_day=curr_day+1;
                    c=c+1;
            end
            All_days_compl(c,1)=All_days(i);
            Daily_mintime_compl(c,1)=Daily_mintime(i);
            Daily_maxtime_compl(c,1)=Daily_maxtime(i);
            if All_days(i+1)==All_days(i)
                % Do nothing
            else
                curr_day=curr_day+1;
            end
                c=c+1;
        end
    else
        if All_days(i)==curr_day
            All_days_compl(c,1)=All_days(i);
            Daily_mintime_compl(c,1)=Daily_mintime(i);
            Daily_maxtime_compl(c,1)=Daily_maxtime(i);
        else
            while All_days(i)~=curr_day
                  All_days_compl(c,1)=All_days(c-1,1)+1;
                  Daily_mintime_compl(c,1)=2;
                  Daily_maxtime_compl(c,1)=2;
                  curr_day=curr_day+1;
                  c=c+1;
            end
            All_days_compl(c,1)=All_days(i);
            Daily_mintime_compl(c,1)=Daily_mintime(i);
            Daily_maxtime_compl(c,1)=Daily_maxtime(i);
        end
    end
end

% Check if the first and last hit of a day are before/after a defined
% time-limit. If not, then list this day in the vector "off_days" to sort
% them out in the main program
NumAlldays=size(All_days_compl,1);
for i=1:NumDay
    for j=1:NumAlldays
        if date1(i,1)==All_days_compl(j)
            if j==1
                if All_days_compl(j)==All_days_compl(j+1)
                    % Do nothing
                else
                    if Daily_mintime_compl(j)>0.25
                        off_days(b,1)=All_days_compl(j);
                        b=b+1;
                    else
                        if Daily_maxtime_compl(j)<0.833333333333
                            off_days(b,1)=All_days_compl(j);
                            b=b+1;
                        end
                    end
                end
            else
                if j==NumAlldays
                    if All_days_compl(j)==All_days_compl(j-1)
                        if Daily_mintime_compl(j)>0.25
                            if abs(Daily_mintime_compl(j)-Daily_mintime_compl(j-1))<0.0007
                                off_days(b,1)=All_days_compl(j);
                                b=b+1;
                            end 
                        else
                            if Daily_maxtime_compl(j)<0.833333333333
                                if abs(Daily_maxtime_compl(j)-Daily_maxtime_compl(j-1))<0.0007
                                    off_days(b,1)=All_days_compl(j);
                                    b=b+1;
                                end
                            end
                        end
                    else
                        if Daily_mintime_compl(j)>0.25
                            off_days(b,1)=All_days_compl(j);
                            b=b+1;
                        else
                            if Daily_maxtime_compl(j)<0.833333333333
                                off_days(b,1)=All_days_compl(j);  
                                b=b+1;
                            end
                        end
                    end
                else
                    if All_days_compl(j)==All_days_compl(j+1)
                        % Do nothing   
                        else
                            if All_days_compl(j)==All_days_compl(j-1)
                                if Daily_mintime_compl(j)>0.25
                                    if abs(Daily_mintime_compl(j)-Daily_mintime_compl(j-1))<0.0007
                                        off_days(b,1)=All_days_compl(j);
                                        b=b+1;
                                    end 
                                else
                                    if Daily_maxtime_compl(j)<0.833333333333 
                                        if abs(Daily_maxtime_compl(j)-Daily_maxtime_compl(j-1))<0.0007
                                            off_days(b,1)=All_days_compl(j);
                                            b=b+1;
                                        end
                                    end
                                end
                            else
                                if Daily_mintime_compl(j)>0.25
                                    off_days(b,1)=All_days_compl(j);
                                    b=b+1;
                                else
                                    if Daily_maxtime_compl(j)<0.833333333333
                                        off_days(b,1)=All_days_compl(j);
                                        b=b+1;
                                    end
                                end
                            end
                    end
                end
            end
        end
    end
end
od=off_days;
end

