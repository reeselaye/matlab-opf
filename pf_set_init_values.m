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

% Created by Beicun Li (John Resse) at 2015-10-21 21:10. Contact mister.resse@outlook.com.

function fe = pf_set_init_values(N,PQInit,U,BLNodeVoltage,PQNodes,PVNodes,BLNodes)

    fe(1:N,:) = zeros(N,PQInit);
    fe(N+1:N+N,:) = ones(N,PQInit);
    fe = fe.*1.00;

    blSize = size(BLNodes);

    for i = 1:blSize(1)
        fe(N+BLNodes(i,1)) = BLNodeVoltage(i,1);
    end

    PVNbr = size(PVNodes);
    for i = 1:PVNbr(1)
        index = PVNodes(i);
        fe(N+index) = U(i);
    end

end