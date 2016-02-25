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

% Created by Beicun Li (John Resse) at 2015-10-25 13:45. Contact mister.resse@outlook.com.

function om = pf_optimal_multiplier(deltafe, Y, N, deltaPQ, J)

%========================================================================================================================%    
%                                                                                                                        %
%                                                         计算最优步长。                                                 %
%                                                                                                                        %
%========================================================================================================================%
%                          |          |                                                                                  %
%        deltafe           | vector   | 包含节点电压修正量虚部、实部的列向量。第1-N个元素是电压修正量虚部，第N+1-N+N个元 %
%                          |          | 素是实部。                                                                       %
%      __________________________________________________________________________________________________________________%
%  参                      |          |                                                                                  %
%        Y                 | matrix   | 以G+jB形式表示的节点导纳矩阵。                                                   %
%      __________________________________________________________________________________________________________________%
%      　　　　　　　　    |          |                                                                                  %
%        N                 | integer  | 节点数。                                                                         %
%  数  __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        deltaPQ           | vector   | 包含节点功率修正量实部、虚部的列向量。第1-N个元素是实部P，第N+1-N+N个元          %
%                          |          | 素是虚部Q。                                                                      %
%      __________________________________________________________________________________________________________________%
%        J                 | matrix   | 包含平衡节点的雅各比矩阵。                                                       %
%========================================================================================================================%
%  返                      |          |                                                                                  %
%  回    om                | double   | 最优步长。                                                                       %                                       
%  值                      |          |                                                                                  %
%========================================================================================================================%

    E = ones(N, 1);
    
    deltae = deltafe(N+1:2*N);
    deltaf = deltafe(1:N);

    YAmp = abs(Y);
    YAngle = angle(Y);

    t1 = sparse(deltaf)*E.'-E*sparse(deltaf.')-sparse(YAngle);

    multiplier_a = deltaPQ;
    multiplier_b = - J * deltafe;
    multiplier_c = -[diag(deltae)*(YAmp.*cos(t1))*deltae;diag(deltae)*(YAmp.*sin(t1))*deltae];




    g0 = (multiplier_a.'*multiplier_b);
    g1 = (multiplier_b.'*multiplier_b) + 2*(multiplier_a.'*multiplier_c);
    g2 = 3 * ((multiplier_b.'*multiplier_c));
    g3 = 2 * ((multiplier_c.'*multiplier_c));
    
    mus = roots([g3 g2 g1 g0]);
    om = mus(mus == real(mus));
    
    [m, n] = size(om);
    if m ~= 1 || n ~= 1
        fprintf(2, '\n- WARN: cannot eveluate the optimal multiplier, returns default value 1.0000.\n');
        om = 1;
    end
end