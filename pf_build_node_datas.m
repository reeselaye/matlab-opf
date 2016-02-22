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

% Created by Beicun Li (John Resse) at 2015-10-23 10:10. Contact mister.resse@outlook.com.

function [U,fy,S,UExceedUprNodes,UExceedLwrNodes] = pf_build_node_datas(fe,Y,N)
    e = fe(N+1:N+N,1);
    f = fe(1:N,1);

    U1 = e+f*i;
    U = abs(U1);
    fy = angle(U1);
    G = real(Y);
    B = imag(Y);

    tmp1 = G*e-B*f;
    tmp2 = G*f+B*e;

    P = diag(e)*tmp1 + diag(f)*tmp2;
    Q = diag(f)*tmp1 - diag(e)*tmp2;

    S = P + Q*i;
    t = angle(S);

    UExceedUprNodes = zeros(N,1);
    UExceedLwrNodes = zeros(N,1);

    for j = 1:N
        if (U(j)>1.1)
            UExceedUprNodes(j) = 1;
        elseif (U(j)<0.9)
            UExceedLwrNodes(j) = 1;
        end
    end
end