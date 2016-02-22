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

% Created by Beicun Li (John Resse) at 2016-01-04 20:10. Contact mister.resse@outlook.com.

fprintf(2,'*****************System of 14 nodes calculation: expecting no errors*************************************\n')
fprintf(2,'pf_example IEEE14.dat\n');
pf_example('IEEE14.dat');
fprintf('\n\n\n\n');


fprintf(2,'*****************System of 300 nodes calculation: expecting no errors*************************************\n')
fprintf(2,'pf_example IEEE300.dat\n');
pf_example('IEEE300.dat');
fprintf('\n\n\n\n');


fprintf(2,'******************System of 1047 nodes calculation: expecting no errors***********************************\n')
fprintf(2,'pf_example IEEE1047.dat\n');
pf_example('IEEE1047.dat');
fprintf('\n\n\n\n');



fprintf(2,'******************System of 5 nodes calculation: expecting error - file not found*************************\n')
fprintf(2,'pf_example IEEE5-NOT-FOUND.dat\n');
pf_example('IEEE5-NOT-FOUND.dat');
fprintf('\n\n\n\n');


fprintf(2,'******************System of 5 nodes calculation: expecting error - multi-balance-nodes is not supported***\n')
fprintf(2,'pf_example IEEE5-3B.dat\n');
pf_example('IEEE5-3B.dat');
fprintf('\n\n\n\n');


fprintf(2,'******************System of 5 nodes calculation: expecting error - invalid data found*********************\n')
fprintf(2,'pf_example IEEE5-IV.dat\n');
pf_example('IEEE5-IV.dat');
fprintf('\n\n\n\n');


fprintf(2,'******************System of 5 nodes calculation: expecting error - does not converge**********************\n')
fprintf(2,'pf_example IEEE5-NC.dat\n');
pf_example('IEEE5-NC.dat');
fprintf('\n\n\n\n');
