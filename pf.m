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

% Created by Beicun Li (John Resse) at 2015-10-21 21:12. Contact mister.resse@outlook.com.

function [err, iterTimes, N, U, fy, S, QLimits] = pf(srcFilePath, options, hCallbackBeforeInitialize, hCallbackBeforeIterations, hCallbackBeforePerIteration, hCallbackAfterPerIteration, hCallbackWhenFinished)
    
%========================================================================================================================%    
%                                                                                                                        %
%                                       使用牛顿-拉夫逊法，执行一次稳态潮流计算。                                        %
%                                                                                                                        %
%========================================================================================================================%
%                          |          |                                                                                  %
%        srcFilePath       | string   | 包含必要源数据的文本文件的绝对或相对路径。                                       %
%      __________________________________________________________________________________________________________________%
%  参                      |          |                                                                                  %
%        options           | vector   | 指定算法选项（未使用）。                                                         %
%      __________________________________________________________________________________________________________________%
%      　　　　　　　　    |          |                                                                                  %
%        hCallbackBeforePerIteration  | 指定回调函数，在每一次迭代开始前被调用。                                         %
%                          | handle   | 回调函数格式为：function callback(iter)，iter为当前迭代次数。                    %
%  数  __________________________________________________________________________________________________________________%
%      　　　　　　　　    |          |                                                                                  %
%        hCallbackAfterPerIteration   | 指定回调函数，在每一次迭代结束后被调用。                                         %
%                          | handle   | 回调函数格式为：function callback(iter)，iter为当前迭代次数。                    %
%========================================================================================================================%
%                          |          |                                                                                  %
%                          |          | 错误信息，指出该函数是否正确返回。_______________err域定义_______________        %
%                          |          |                                      \ code     - 代码                           %
%                          |          |                                       \ msg     - 提示信息                       %
%                          |          |                                        \_source - 错误源_________________________%
%                          |          |                                   _______________________________________        %
%                          |          |                   ________________| 0        - 正常返回                 /        %
%        err               | struct   |                   |err.code含义     1        - 超出指定迭代次数未收敛  /         %                            
%                          |          |                   |_______________  其它数值 - 发生未知错误（未使用） /          %                              
%                          |          |                                   |__________________________________/           %
%                          |          | 除非 err == {}，否则 ：N, U, fy 及 S 为无效返回值，iterTimes为最大迭代次数。     %                           
%  返  __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        iterTimes         | interger | 实际迭代次数。                                                                   %
%  回  __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        N                 | interger | 总节点数目。                                                                     %
%  值  __________________________________________________________________________________________________________________%
%                          |          |                                          |                                       %                       
%        U                 | vector   | 所有节点的电压幅值（标幺值）。           |\                                      %
%      __________________________________________________________________________| \                                     %
%                          |          |                                          |  \                                    %
%        fy                | vector   | 所有节点的电压相角（标幺值）。           |---    数值列表按节点编号顺序。        %
%      __________________________________________________________________________|  /                                    %
%                          |          |                                          | /                                     %
%        S                 | vector   | 所有节点的复功率（标幺值），形如 P + Qi。|/                                      %
%========================================================================================================================%

%% 初始化。
    % 读取源数据文件并构造所需数据结构。
    % 并设置迭代变量初值。
    if(class(hCallbackBeforeInitialize) == 'function_handle')
        hCallbackBeforeInitialize(srcFilePath, options);
    end
    [err,fe,Y, P, QAndU2, BLVoltage, U, N, BLNodes, PQNodes, PVNodes, QLimits, precision, maxIterTimes] = pf_build_data_structure(srcFilePath);
    if(isstruct(err))
        iterTimes=0;N=0;U=0;fy=0;S=0;
        return;
    end
    % 检查是否所有源数据特性均受当前版本支持。
    err = pf_validate(Y, P, QAndU2, U, N, BLNodes, PQNodes, PVNodes, precision, maxIterTimes);
    if(isstruct(err))
        iterTimes=0;N=0;U=0;fy=0;S=0;
        return;
    end
    if(class(hCallbackBeforeIterations) == 'function_handle')
        hCallbackBeforeIterations();
    end

%% 迭代。
    % 使用迭代计数器。
    iterTimes = 0;
    while (1)
               
        % 若迭代次数超出指定最大值，返回错误。
        if(iterTimes > maxIterTimes)
            iterTimes=0;N=0;U=0;fy=0;S=0;
            err = common_err(1, mfilename(),'DOES NOT converge after specified MAX iterations: %d.', maxIterTimes); return;
        end
        
        % 若定义了前回调函数，发送通知。
        if(class(hCallbackBeforePerIteration) == 'function_handle')
            hCallbackBeforePerIteration(iterTimes);
        end

       
        % 计算不平衡量。
        % 构造雅各比矩阵。
        [deltaPQ, J] = pf_calc_delta_and_jacobi(N, PQNodes, PVNodes, BLNodes, P, QAndU2, Y, fe);
        % 求解修正方程组。
        deltafe = sparse(J\deltaPQ);

        % 若满足收敛条件，结束迭代。
        if(common_all_near_zero(deltafe, precision))
            break;
        end
        
        % 计算最优乘子。
        mu = pf_optimal_multiplier(deltafe, Y, N, deltaPQ, J);
        % 更新迭代变量。
        fe = fe + mu*deltafe;

        % 若定义了后回调函数，发送通知。
        if(class(hCallbackAfterPerIteration) == 'function_handle')
            hCallbackAfterPerIteration(iterTimes, J, deltafe, deltaPQ, mu);
        end

        iterTimes = iterTimes + 1;
        
    end

    % 计算节点功率和电压。
    [U, fy, S, u, l] = pf_build_node_datas(fe, Y, N);

    if(class(hCallbackWhenFinished) == 'function_handle')
        hCallbackWhenFinished();
    end    



end

