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

% Created by Beicun Li (John Resse) at 2015-10-24 08:14. Contact mister.resse@outlook.com.

function [err] = pf_validate(Y,P,Q,U2,N,BLNodes,PQNodes,PVNodes,precision,maxIterTimes)
    err = [];
    t = size(BLNodes);
    if (t(1)~=1)
        err = common_err(1,mfilename(), 'Multi-balance-nodes is NOT supported yet: %d balance nodes found.', t(1));
        return;
    end

    t = size(U2);
    for i = 1:t(1)
        if(U2(i)>1.5)
            err = common_err(5, mfilename(), 'A voltage value seems NOT valid: node - %d, V - %f.', i, U2(i));
            return;
        end
    end
end
