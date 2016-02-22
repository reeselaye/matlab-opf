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

% Created by Beicun Li (John Resse) at 2015-10-20 08:40. Contact mister.resse@outlook.com.

function [err,initialFe,Y,P,QAndU2,BLVoltages,U,N,BLNodes,PQNodes, PVNodes, QLimits, precision,maxIterTimes] = pf_build_data_structure(srcFilePath)

%========================================================================================================================%    
%                                                                                                                        %
%                                    读取潮流计算源数据文件，并构造特定的数据格式。                                      %
%                                                                                                                        %
%========================================================================================================================%
%  参                      |          |                                                                                  %
%        srcFilePath       | string   | 包含源数据的文本文件的绝对或相对路径。                                           %
%  数                      |          |                                                                                  %   
%========================================================================================================================%
%                          |          |                                                                                  %
%                          |          | 错误代码，指出该函数是否正确返回。___________________________________________    %        
%                          |          |                   ________________| 0        - 正常返回                      |   %        
%        err               | struct   |                   |                 1        - 具有多平衡节点                |   %           
%                          |          |                   |  错误代码含义   2        - PV节点运行参数表未包含平衡节点|   %                  
%                          |          |                   |_______________  其它数值 - 发生未知错误（未使用）        |   %                                     
%                          |          |                                   |__________________________________________|   %       
%                          |          | 除非 errCode == 0，否则所有其他返回值无效。                                      %                           
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        Y                 | matrix   | 节点导纳矩阵（标幺值）。                                                         %
%  返  __________________________________________________________________________________________________________________%
%                          |          |                                                               |                  %
%        P                 | vector   | 给定有功向量（标幺值）。                                      |                  %
%      _______________________________________________________________________________________________| 平衡节点处为 0。 %
%                          |          |                                                               |                  %
%        QAndU2            | vector   | 给定无功（对于PQ节点）或电压平方（对于PV节点）向量（标幺值）。|                  %
%      _______________________________________________________________________________________________|__________________%
%  回                      |          |                                                                                  %
%        BLVoltages        | vector   | 平衡节点电压向量（标幺值）。                                                     %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        U                 | vector   | PV节点给定电压幅值（标幺值）。                                                   %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%  值    N                 | integer  | 总节点数目。                                                                     %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        BLNodes           | vector   | 平衡节点（编号）列表。                                                           %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        PQNodes           | vector   | PQ节点（编号）列表。                                                             %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        PVNodes           | vector   | PV节点（编号）列表。                                                             %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        precision         | float    | 收敛精度。                                                                       %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        maxIterTimes      | integer  | 最大迭代次数。                                                                   %
%========================================================================================================================%
    [err,nodeNbr,branchNbr,baseCapacity,maxIterTimes,centralParam ,precision,functionClass, ...
    blNodeNbr, blNodeIndexies, transmissionLineParams, groundedLineParams, transformerParams, nodeParams,pvAndBlNodeParams, generatorParams] ...
                                    = pf_read_src_ipso(srcFilePath);

    if(isstruct(err))
        initialFe = 0;Y=0;P=0;QAndU2=0;BLVoltages=0;U=0;N=0;BLNodes=0;PQNodes=0;PVNodes=0;precision=0;maxIterTimes=0;QLimits=0;
        return;
    end

    sizeOfTransmissionLineParams    = common_element_count(transmissionLineParams);
    sizeOfGroundedLineLineParams    = common_element_count(groundedLineParams);
    sizeOfNodeParams                = common_element_count(nodeParams);
    sizeOfpvAndBlNodeParams         = common_element_count(pvAndBlNodeParams);
    sizeOfGeneratorParams           = common_element_count(generatorParams);
    sizeOfTransformerParams         = common_element_count(transformerParams);

    blNodeNbr                       = 0;
    pvNodeNbr                       = 0;
    pqNodeNbr                       = 0;
    

%% Build matrix Y.
    G = zeros(sizeOfNodeParams,sizeOfNodeParams);
    B = zeros(sizeOfNodeParams,sizeOfNodeParams);
    % Use the transmission line parameters.
    for i = 1:sizeOfTransmissionLineParams
       
        linedata            = transmissionLineParams(i);
        
        gij                 =  linedata.R/(linedata.R*linedata.R + linedata.X*linedata.X);
        bij                 = -linedata.X/(linedata.R*linedata.R + linedata.X*linedata.X);
        nodeNoi             = linedata.nodei;
        nodeNoj             = linedata.nodej;
        bDiv2               = linedata.bDiv2;

        G(nodeNoi, nodeNoj) = G(nodeNoi, nodeNoj) - gij;
        G(nodeNoj, nodeNoi) = G(nodeNoj, nodeNoi) - gij;
        G(nodeNoi, nodeNoi) = G(nodeNoi, nodeNoi) + gij;
        G(nodeNoj, nodeNoj) = G(nodeNoj, nodeNoj) + gij;
        B(nodeNoi, nodeNoj) = B(nodeNoi, nodeNoj) - bij;
        B(nodeNoj, nodeNoi) = B(nodeNoj, nodeNoi) - bij;
        B(nodeNoi, nodeNoi) = B(nodeNoi, nodeNoi) + bij + bDiv2;
        B(nodeNoj, nodeNoj) = B(nodeNoj, nodeNoj) + bij + bDiv2;

    end
    % Done.
    % Use the grounded line parameters.
    for i = 1:sizeOfGroundedLineLineParams
        
        glinedata           = groundedLineParams(i);

        nodeNoi             = glinedata.nodeNo;
        bij                 = glinedata.G;
        B(nodeNoi, nodeNoi) = B(nodeNoi, nodeNoi) + bij;

    end
    % Done.
    % Use the transformer parameters.
    for i = 1:sizeOfTransformerParams

        transdata           = transformerParams(i);

        nodeNoi             = transdata.nodei;
        nodeNoj             = transdata.nodej;
        kMin                = transdata.kMin;
        kMax                = transdata.kMax;
        k0                  = transdata.k0;
        r                   = transdata.R;
        x                   = transdata.X;
        gij                 = r/(r*r + x*x);
        bij                 = -x/(r*r + x*x);

        G(nodeNoi, nodeNoj) = G(nodeNoi, nodeNoj) - gij/k0;
        B(nodeNoi, nodeNoj) = B(nodeNoi, nodeNoj) - bij/k0;
        G(nodeNoj, nodeNoi) = G(nodeNoj, nodeNoi) - gij/k0;
        B(nodeNoj, nodeNoi) = B(nodeNoj, nodeNoi) - bij/k0;
        G(nodeNoi, nodeNoi) = G(nodeNoi, nodeNoi) + gij/k0/k0;
        B(nodeNoi, nodeNoi) = B(nodeNoi, nodeNoi) + bij/k0/k0;
        G(nodeNoj, nodeNoj) = G(nodeNoj, nodeNoj) + gij;
        B(nodeNoj, nodeNoj) = B(nodeNoj, nodeNoj) + bij;

    end
    Y = sparse(G) + sparse(B)*j;

%% Build vector P, QAndU2, BLNodes, PVNodes, PQNodes, BLVoltages.
    
    BLNodes = blNodeIndexies;
    BLVoltages = [];
    PQNodes = [];
    PVNodes = [];
   

    P       = [];
    QAndU2  = [];
    U       = [];

    for i = 1:sizeOfNodeParams
        node                    = nodeParams(i);
        P(node.nodeNo)          = (node.Pg - node.Pl)/baseCapacity;
        QAndU2(node.nodeNo)     = (node.Qg - node.Ql)/baseCapacity; 
        QMax(node.nodeNo)       = (node.Qg - node.Ql)/baseCapacity; 
        QMin(node.nodeNo)       = (node.Qg - node.Ql)/baseCapacity; 
    end

    for i = 1:sizeOfpvAndBlNodeParams
        node = pvAndBlNodeParams(i);
        if(~common_contain(BLNodes,node.nodeNo,0))
            pvNodeNbr               = pvNodeNbr + 1;
            PVNodes(pvNodeNbr)      = node.nodeNo;
            U(pvNodeNbr)            = node.u;
            QAndU2(node.nodeNo)     = (node.u)*(node.u);
            QMax(node.nodeNo)       = node.QMax/baseCapacity;
            QMin(node.nodeNo)       = node.QMin/baseCapacity;
        else
            blNodeNbr               = blNodeNbr + 1;
            BLVoltages(blNodeNbr)   = node.u;
            QMax(node.nodeNo)       = node.QMax/baseCapacity;
            QMin(node.nodeNo)       = node.QMin/baseCapacity;
        end
    end

    for i = 1:common_element_count(blNodeIndexies)
        P(blNodeIndexies(i))        = 0.0000;
        QAndU2(blNodeIndexies(i))   = 0.0000;
    end

    N = sizeOfNodeParams;

    for i = 1:N
        if(~common_contain(BLNodes,i,0))
            if(~common_contain(PVNodes,i,0))
                pqNodeNbr           = pqNodeNbr + 1;
                PQNodes(pqNodeNbr)  = i;
            end
        end
    end

    BLNodes     = BLNodes';
    BLVoltages  = BLVoltages';
    PVNodes     = PVNodes';
    PQNodes     = PQNodes';
    P           = P';
    QAndU2      = QAndU2';
    U           = U';
    QMin        = QMin';
    QMax        = QMax';
    QLimits     = [QMin,QMax];

    initialFe   = sparse(pf_set_init_values(N,1.0000,U,BLVoltages,PQNodes,PVNodes,BLNodes));

end



