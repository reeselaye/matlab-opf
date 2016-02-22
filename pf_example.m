% Copyright (c) 2016 the Institute of Power System Optimization, Guangxi University (the iPso)
% and original author(s). This file is licensed to you under the Apache License, Version 
% 2.0 (the "License"); you may not use this file except in compliance with the License. You 
% may obtain a copy of the License at
% 
%      http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software distributed under the
% License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
% either express or implied. See the License for the specific language governing permissions
% and limitations under the License.

% Created by Beicun Li (John Resse) at 2015-10-27 10:20. Contact mister.resse@outlook.com.

function pf_example(srcFilePath)

    set_globals

    format long
    [err,iterTimes,N,U,fy,S,QLimits] = pf(srcFilePath,  [], @pf_notify_before_initialize, @pf_notify_before_iterations, @pf_notify_before_iteration, @pf_notify_after_iteration, @pf_notify_when_finished);

    if (isstruct(err))
        common_err_print(err);
    else



        xbase = 1:1:N;
        X = transpose(xbase);
        ybase = ones(N,1);
        


        yellow      = [0,255,0]/255.;
        strNi       = 'Node Index ';
        strAng      = 'Angle ';
        strAmp      = 'Amplitude ';
        strOf       = 'of ';
        strSp       = ' ';
        strVol      = 'Voltage ';

        plotRows    = 2;
        plotColumns = 2;



        figure('Name', ['Output datas of ', srcFilePath]);
        

        subplot(plotRows,plotColumns,1);
        plot(X,U,'b.',X,ybase*1.1000,'r-',X,ybase*0.9000,'r-',X,ybase*0.95,'r--',X,ybase*1.05,'r--');
        axis([1,N,0.875,1.125]);
        title([strVol, strOf, srcFilePath]);
        xlabel(strNi);
        ylabel([strAmp, strOf, strVol]);
       

        subplot(plotRows,plotColumns,2);
        plot(X,fy,'b.',X,ybase*pi/2.,'r-',X,ybase*(-pi/2.),'g-');
        axis([1,N,-1,1]);
        title([strAng, strOf, srcFilePath]);
        xlabel(strNi);
        ylabel([strAng, strOf, strVol]);


        subplot(plotRows,plotColumns,3);
        hold on;
        h = area(X,QLimits(:,1));
        set(h(1),'FaceColor', yellow);
        h = area(X,QLimits(:,2));
        set(h(1),'FaceColor', yellow);
        Q = imag(S);
        Q2Nbr = 0;
        Q1Nbr = 0;
        Q3Nbr = 0;
        for i=1:N
            upr = QLimits(i,2) + 0.01;
            lwr = QLimits(i,1) - 0.01;
            q   = Q(i);
            if( q > upr )
                Q3Nbr = Q3Nbr + 1;
            elseif( q < lwr )
                Q2Nbr = Q2Nbr + 1;
            else
                Q1Nbr = Q1Nbr + 1;
            end    
        end
        X1 = zeros(Q1Nbr,1);
        X2 = zeros(Q2Nbr,1);
        X3 = zeros(Q3Nbr,1);
        Q1 = zeros(Q1Nbr,1);
        Q2 = zeros(Q2Nbr,1);
        Q3 = zeros(Q3Nbr,1);
        Q2Nbr = 0;
        Q1Nbr = 0;
        Q3Nbr = 0;
        for i=1:N
            upr = QLimits(i,2) + 0.01;
            lwr = QLimits(i,1) - 0.01;
            q   = Q(i);
            if( q > upr )
                Q3Nbr = Q3Nbr + 1;
                Q3(Q3Nbr) = q;
                X3(Q3Nbr) = i;
            elseif( q < lwr )
                Q2Nbr = Q2Nbr + 1;
                Q2(Q2Nbr) = q;
                X2(Q2Nbr) = i;
            else
                Q1Nbr = Q1Nbr + 1;
                Q1(Q1Nbr) = q;
                X1(Q1Nbr) = i;
            end    
        end
        plot(X1,Q1,'g.');
        plot(X2,Q2,'r.');
        plot(X3,Q3,'r.');
        xlim([1,N]);
        title(['Reactive Power of ',srcFilePath]);
        xlabel(strNi);
        ylabel('Active Power');
        

        subplot(plotRows,plotColumns,4);
        global g_unbalance
        plot(1:1:iterTimes, g_unbalance, '*-');
        xlim([1, iterTimes]);
        
        resFileName = [common_getpath(mfilename('fullpath')), 'output\result-of-ieee-', int2str(N), '-system.csv'];
        [file, msg] = fopen(resFileName, 'w');
        if (file == -1)
            fprintf(2,'+ There are Warnings.\n');
            fprintf(2,'    - Unable to open file %s to write results.\n', resFileName);
        else
            fprintf('- Write results to file %s.\n', resFileName);
            fprintf(file, 'Node Index, Amplitude of Voltage, Angle of Voltage\n');
            fullU = full(U);
            fullFy = full(fy);
            for i = 1:N
                fprintf(file,'%d,%f,%f\n', i, fullU(i), fullFy(i));
            end
            fclose(file);
        end

        
        
    end



end
