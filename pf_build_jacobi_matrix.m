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

% Created by Beicun Li (John Resse) at . Contact mister.resse@outlook.com.

function  Jacobi = pf_build_jacobi_matrix(N,PQNodes,PVNodes,BLNodes,P,Q,Y,fe)
    %计算雅各比矩阵。
    nodeNbrOfBL = BLNodes(1,1);
    PVNbr = size(PVNodes);
    nodeNbr = N;

    [e,f] = pf_dicompose_fe(N,fe);
    [G,B] = pf_dicompose_ri(Y);
    
    e_ex = [];
    f_ex = [];

    for i = 1:N
        e_ex(:,i) = e;
        f_ex(:,i) = f;
    end

    a = diag((G * e) - (B * f));
    b = diag((G * f) + (B * e));
    H = -B.*e_ex + G.*f_ex + b;
    N = G.*e_ex + B.*f_ex + a;
    J = -G.*e_ex - B.*f_ex + a;
    L = -B.*e_ex + G.*f_ex -b;

    for i = 1:PVNbr(1)
        index = PVNodes(i);
        J(index,:) = zeros(1,nodeNbr);
        L(index,:) = zeros(1,nodeNbr); 
        J(index,index) = 2*f(index);
        L(index,index) = 2*e(index);
    end



    Jacobi = [
        H N;
        J L;
    ];


    Jacobi(nodeNbrOfBL, :) = zeros(1,2*nodeNbr);
    Jacobi(nodeNbrOfBL+nodeNbr,:) = zeros(1,2*nodeNbr);
    Jacobi(:,nodeNbrOfBL) = zeros(2*nodeNbr,1);
    Jacobi(:,nodeNbrOfBL+nodeNbr) = zeros(2*nodeNbr,1);

    Jacobi(nodeNbrOfBL,nodeNbrOfBL) = 1;
    Jacobi(nodeNbrOfBL,nodeNbrOfBL+nodeNbr) = 2;
    Jacobi(nodeNbrOfBL+nodeNbr,nodeNbrOfBL) = 3;
    Jacobi(nodeNbrOfBL+nodeNbr,nodeNbrOfBL+nodeNbr) = 4;

end