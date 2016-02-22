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

% Created by Beicun Li (John Resse) at 2015-10-24 17:12. Contact mister.resse@outlook.com.

function [Y,P,QAndU2,BLVoltage,U,N,BLNodes,PQNodes,PVNodes,precision,maxIterTimes] = pf_mock_ieee5()
    Y = [
    1.3787+-6.2917i -0.6240+3.9002i -0.7547+2.6415i 0.0000+0.0000i 0.0000+0.0000i ;
    -0.6240+3.9002i 1.4539+-66.9808i -0.8299+3.1120i 0.0000+63.4921i 0.0000+0.0000i ;
    -0.7547+2.6415i -0.8299+3.1120i 1.5846+-35.7379i 0.0000+0.0000i 0.0000+31.7460i ;
    0.0000+0.0000i 0.0000+63.4921i 0.0000+0.0000i 0.0000+-66.6667i 0.0000+0.0000i ;
    0.0000+0.0000i 0.0000+0.0000i 0.0000+31.7460i 0.0000+0.0000i 0.0000+-33.3333i ;
    ];
    P = [
    -0.0160;
    -0.0200;
    -0.0370;
    0.0500;
    0.0000;
    ];
    QAndU2 = [
    -0.0080;
    -0.0100;
    -0.0130;
    1.1025;
    0.0000;
    ];
    PQNodes = [
    1;
    2;
    3;
    ];
    PVNodes = [
    4;
    ];
    U = [
    1.0500;
    ];
    BLNodes = [
    5;
    ];
    BLVoltage = 1.0500;
    precision = 0.00001;
    maxIterTimes = 30;
    N = 5;
end