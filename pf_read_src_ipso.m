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

% Created by Beicun Li (John Resse) at 2015-11-10 10:25. Contact mister.resse@outlook.com.

function    [err,nodeNbr,branchNbr,baseCapacity,maxIterTimes,centralParam ,precision,functionClass, blNodeNbr, blNodeIndexies, ...
            transmissionLineParams, groundedLineParams, transformerParams, nodeParams,pvAndBlNodeParams, generatorParams]...
            = pf_read_src_ipso(srcFilePath)

%========================================================================================================================%    
%                                                                                                                        %
%                                    读取使用iPso内部格式编写的潮流计算源数据文件。                                      %
%                                                                                                                        %
%========================================================================================================================%
%  参                      |          |                                                                                  %
%        srcFilePath       | string   | 包含源数据的文本文件的绝对或相对路径。                                           %
%  数                      |          |                                                                                  %   
%========================================================================================================================%
%                          |          |                                                                                  %
%                          |          | 错误代码，指出该函数是否正确返回。___________________________________________    %        
%                          |          |                   ________________| 0        - 正常返回                      |   %        
%        errCode           | integer  |                   |                 1        - 具有多平衡节点                |   %           
%                          |          |                   |  错误代码含义   2        - PV节点运行参数表未包含平衡节点|   %                  
%                          |          |                   |_______________  其它数值 - 发生未知错误（未使用）        |   %                                     
%                          |          |                                   |__________________________________________|   %       
%                          |          | 除非 errCode == 0，否则所有其他返回值无效。                                      %                           
%      __________________________________________________________________________________________________________________%
%  返                      |          |                                                                                  %
%        nodeNbr           | interger | 总节点数目。                                                                     %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        branchNbr         | interger | 总支路数目。                                                                     %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%  回    baseCapacity      | float    | 基准容量。                                                                       %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        maxIterTimes      | interger | 最大迭代次数。                                                                   %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        centralParam      | float    | 中心参数。                                                                       %
%  值  __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        precision         | float    | 精度。                                                                           %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        functionClass     | interger | 目标函数类别。                                                                   %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        blNodeNbr         | interger | 平衡节点数。                                                                     %
%      __________________________________________________________________________________________________________________%
%                          |          |                                                                                  %
%        blNodeIndexies    | vector   | 平衡节点编号表。                                                                 %
%________________________________________________________________________________________________________________________%
%                                     |              |                 |                                                 %
%        transmissionLineParams       | struct array | 线路参数表。    |  __________________struct域列表_________________%                   
%                                                                      |  \ branchNo   - 线路所属支路编号                %
%                                                                      |   \ nodei     - 线路端节点编号                  %
%                                                                      |    \ nodej    - 线路端节点编号                  %
%                                                                      |     \ R       - 线路等值电阻（标幺值）          %
%                                                                      |      \ X      - 线路等值电抗（标幺值）          %
%                                                                      |       \ bDiv2 - pi型等值电路的线路电纳（标幺值）%
%                                                                      |        \________________________________________%
%      ________________________________________________________________|_________________________________________________%
%                                     |              |                 |  __________________struct域列表_________________%                                                  
%        groundedLineParams           | struct array | 接地支路参数表。|  \ G          - 接地支路等值电导（标幺值）      %                                            
%                                                                      |   \ nodeNo    - 接地支路端节点编号              %
%                                                                      |    \____________________________________________%
%      ________________________________________________________________|_________________________________________________%
%                                     |              |                 |  __________________struct域列表_________________%                                                  
%  返    transformerParams            | struct array | 变压器参数表。  |  \ k0         - 原始变比                        %                           
%                                                                      |   \ kMax      - 最大变比                        %
%                                                                      |    \ kMin     - 最小变比                        %
%                                                                      |     \ nodei   - 端节点编号                      %
%                                                                      |      \ nodej  - 端节点编号                      %
%                                                                      |       \ R     - 变压器等值电阻（标幺值）        %
%                                                                      |        \ X    - 变压器等值电抗（标幺值）        %
%                                                                      |         \_______________________________________%
%      ________________________________________________________________|_________________________________________________%
%  回                                 |              |                 |  __________________struct域列表_________________%
%        groundedLineParams           | struct array | 接地支路参数表。|  \ G          - 接地支路电导（标幺值）          %
%                                                                      |   \ nodeNo    - 接地支路端节点编号              %
%                                                                      |    \____________________________________________%
%      ________________________________________________________________|_________________________________________________%
%                                     |              |                 |  __________________struct域列表_________________%
%        nodeParams                   | struct array | 运行参数表。    |  \ nodeNo     - 节点编号                        %
%                                                                      |   \ Pg        - 电源有功                        %
%                                                                      |    \ Qg       - 电源无功                        %
%  值                                                                  |     \ Pl      - 负荷有功                        %
%                                                                      |      \ Ql     - 负荷无功                        %
%                                                                      |       \_________________________________________%                                                                      
%      ________________________________________________________________|_________________________________________________%
%                                     |              |                 |  __________________struct域列表_________________%                                                  
%        pvAndBlNodeParams            | struct array | PV和平衡节点    |  \ nodeNo     - 节点编号                        %
%                                                      运行参数表。    |   \ QMax      - 最大无功出力                    %
%                                                                      |    \ QMin     - 最小无功出力                    %
%                                                                      |     \ u       - 电压幅值（标幺值）              %
%                                                                      |      \__________________________________________%
%      ________________________________________________________________|_________________________________________________%
%                                     |              |                 |  __________________struct域列表_________________%                                                  
%        generatorParams              |struct array  |发电机耗量参数表。  \ a -                                          %
%                                                                      |   \ b -                                         %
%                                                                      |    \ c -                                        %
%                                                                      |     \ nodeNo  - 所在节点编号                    %
%                                                                      |      \ PgMax  - 最大有功出力                    %
%                                                                      |       \ PgMin - 最小有功出力                    %
%                                                                      |        \________________________________________%
%========================================================================================================================%

    err = [];
    fp  = fopen(srcFilePath, 'r');
    if (fp == -1)
        err = common_err(3, mfilename(), 'CANNOT find the specified data file in your file system: %s.', srcFilePath);
        nodeNbr = 0;branchNbr = 0;baseCapacity = 0;maxIterTimes  = 0;centralParam =0;precision=0;functionClass=0;blNodeNbr=0;blNodeIndexies=0;transmissionLineParams=0;groundedLineParams=0;transformerParams=0;nodeParams=0;pvAndBlNodeParams=0;generatorParams=0;
        return ;
    end

    blNodeIndexies          = [];
    blNodeNbr               = 0;
    transmissionLineParams  = {};
    transmissionLineNbr     = 0;
    groundedLineParams      = {};
    groundedLineNbr         = 0;
    transformerParams       = {};
    transformerNbr          = 0;
    nodeParams              = {};
    nodeNbr                 = 0;
    pvAndBlNodeParams       = {};
    pvAndBlNodeNbr          = 0;
    generatorParams         = {};
    generatorNbr            = 0;

    %% Get the header of IEEE standard file.
    [throws_, branchNbr, baseCapacity, maxIterTimes, centralParam] = common_spilt(textscan(fp,'%d %d %f %d %f',1));
    [precision, functionClass]                                     = common_spilt(textscan(fp, '%f %d',1));
    % Done.


    %% Get the Bl Node parameters.
    nodeNoi     = common_spilt(textscan(fp, '%d',1));
    while (nodeNoi ~= 0)
        blNodeNbr                                           = blNodeNbr + 1;
        nodeNoj                                             = common_spilt(textscan(fp, '%d',1));
        blNodeIndexies(blNodeNbr)                           = nodeNoj;
        nodeNoi                                             = common_spilt(textscan(fp,'%d',1));
    end    
    % Done.

    %% Get the parameters of Lines.
    branchNo    = common_spilt(textscan(fp, '%d',1) );
    i_linep     = 0;
    while (branchNo ~= 0)
        transmissionLineNbr                                 = transmissionLineNbr + 1;
        [nodeNoi, nodeNoj, r, x, bb]                        = common_spilt(textscan(fp, '%d %d %f %f %f',1));
        transmissionLineParams(transmissionLineNbr).bDiv2   = bb;
        transmissionLineParams(transmissionLineNbr).branchNo= branchNo;
        transmissionLineParams(transmissionLineNbr).nodei   = nodeNoi;
        transmissionLineParams(transmissionLineNbr).nodej   = nodeNoj;
        transmissionLineParams(transmissionLineNbr).R       = r;
        transmissionLineParams(transmissionLineNbr).X       = x;
        branchNo                                            = common_spilt(textscan(fp, '%d',1));
    end
    % Done.

    %% Get the parameters of Grounded Lines.
    nodeNoi     = common_spilt(textscan(fp, '%d',1));
    i_glinep    = 0;
    while (nodeNoi ~= 0)
        groundedLineNbr                             = groundedLineNbr + 1;
        gij                                         = common_spilt(textscan(fp, '%f',1));
        groundedLineParams(groundedLineNbr).G       = gij;
        groundedLineParams(groundedLineNbr).nodeNo  = nodeNoi;
        nodeNoi                                     = common_spilt(textscan(fp, '%d',1));
        i_glinep                                    = i_glinep + 1;
    end
    % Done.


    %% Get the parameters of Transformers.
    branchNo    = common_spilt(textscan(fp, '%d',1));
    i_tp        = 0;
    while (branchNo ~= 0)
        transformerNbr = transformerNbr + 1;
        [nodeNoi, nodeNoj, r, x, k0, kmin, kmax]    = common_spilt(textscan(fp, '%d %d %f %f %f %f %f',1));
        transformerParams(transformerNbr).branchNo  = branchNo;
        transformerParams(transformerNbr).k0        = k0;
        transformerParams(transformerNbr).kMax      = kmax;
        transformerParams(transformerNbr).kMin      = kmin;
        transformerParams(transformerNbr).nodei     = nodeNoi;
        transformerParams(transformerNbr).nodej     = nodeNoj;
        transformerParams(transformerNbr).R         = r;
        transformerParams(transformerNbr).X         = x;
        branchNo                                    = common_spilt(textscan(fp, '%d',1));
        i_tp = i_tp + 1;
    end
    % Done.

    %% Get the Node Parameters.
    nodeNoi     = common_spilt(textscan(fp, '%d',1));
    i_run       = 0;
    while (nodeNoi ~= 0)
        nodeNbr                                 = nodeNbr + 1;
        [Pg, Qg, Pl, Ql]                        = common_spilt(textscan(fp, '%f %f %f %f',1));
        nodeParams(nodeNbr).nodeNo              = nodeNoi;
        nodeParams(nodeNbr).Pg                  = Pg;
        nodeParams(nodeNbr).Qg                  = Qg;
        nodeParams(nodeNbr).Pl                  = Pl;
        nodeParams(nodeNbr).Ql                  = Ql;
        nodeNoi                                 = common_spilt(textscan(fp, '%d',1));
        i_run                                   = i_run + 1;
    end
    % Done.

    %% Get the PV and BL Node parameters.
    nodeNoi     = common_spilt(textscan(fp, '%d',1));
    i_pvp       = 0;
    while (nodeNoi ~= 0)
        pvAndBlNodeNbr                          = pvAndBlNodeNbr + 1;
        [u, pvQmin, pvQmax]                     = common_spilt(textscan(fp, '%f %f %f',1));
        pvAndBlNodeParams(pvAndBlNodeNbr).nodeNo= nodeNoi;
        pvAndBlNodeParams(pvAndBlNodeNbr).QMax  = pvQmax;
        pvAndBlNodeParams(pvAndBlNodeNbr).QMin  = pvQmin;
        pvAndBlNodeParams(pvAndBlNodeNbr).u     = u;
        nodeNoi                                 = common_spilt(textscan(fp, '%d',1));
        i_pvp                                   = i_pvp +  1;
    end
    % Done.

    %% Get the Generator Parameters.
    nodeNoi     = common_spilt(textscan(fp, '%d',1));
    i_gcp       = 0;
    while (nodeNoi ~= 0)
        generatorNbr                            = generatorNbr + 1;
        [c, b, a, gcPgmin, gcPgmax]             = common_spilt(textscan(fp, '%f %f %f %f %f',1));
        generatorParams(generatorNbr).a         = a;
        generatorParams(generatorNbr).b         = b;
        generatorParams(generatorNbr).c         = c;
        generatorParams(generatorNbr).nodeNo    = nodeNoi;
        generatorParams(generatorNbr).PgMax     = gcPgmax;
        generatorParams(generatorNbr).PgMin     = gcPgmin;
        nodeNoi                                 = common_spilt(textscan(fp, '%d',1));
        i_gcp                                   = i_gcp + 1;
    end
    % Done.

    fclose(fp);
end

