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

% Created by Beicun Li (John Resse) at 2015-10-21 10:12. Contact mister.resse@outlook.com.

function [delta, Jacobi] = pf_calc_delta(N,PQNodes,PVNodes,BLNodes,P,QAndU2,Y,fe)
    
    [e,f]   = pf_dicompose_fe(N,fe);
    [G,B]   = pf_dicompose_ri(Y);

    PQAndU2 = sparse([P; QAndU2]);
    fe      = sparse([f; e]);
    diagE   = sparse(diag(e));
    diagF   = sparse(diag(f));
    mAboutEf = sparse([diagE, diagF; diagF, -diagE;]);
    mAboutGB = sparse([-B, G; G, B]);
    mAboutGeBf = sparse(diag(G*e - B*f));
    mAboutBeGf = sparse(diag(B*e + G*f));
    mAboutGBef = sparse(mAboutEf * mAboutGB);

    delta = sparse([P; QAndU2] - mAboutGBef*fe) ;

    NOfBL = BLNodes(1,1);

    delta(NOfBL) = 0.0000;
    delta(N + NOfBL) = 0.0000;

    PVNbr = size(PVNodes);
    for i = 1:PVNbr(1)
        index = PVNodes(i);
        delta(N + index) = QAndU2(index) - (e(index)*e(index)+f(index)*f(index));
    end


    Jacobi = (mAboutGBef + [mAboutBeGf, mAboutGeBf; mAboutGeBf, -mAboutBeGf]);

    for i = 1:PVNbr(1)
        index                       = PVNodes(i);
        Jacobi(N + index,:)         = zeros(1,2*N);
        Jacobi(N + index, index)    = 2*f(index);
        Jacobi(N + index, N + index)= 2*e(index);
    end


    Jacobi(NOfBL, :)        = zeros(1,2*N);
    Jacobi(NOfBL+N,:)       = zeros(1,2*N);
    Jacobi(:,NOfBL)         = zeros(2*N,1);
    Jacobi(:,NOfBL+N)       = zeros(2*N,1);

    Jacobi(NOfBL,NOfBL)     = 1;
    Jacobi(NOfBL,NOfBL+N)   = 2;
    Jacobi(NOfBL+N,NOfBL)   = 3;
    Jacobi(NOfBL+N,NOfBL+N) = 4;

    Jacobi = sparse(Jacobi);

end