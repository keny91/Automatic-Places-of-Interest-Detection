function [ parameters_meanF, parameters_thF] = Find_Best_Parameter( Analysis_table , THn)
% Find_Best_Parameter: checks for the maximum F value given an analysis
% table and the threshold row prefered. 




table_size = length(Analysis_table);
table_wide = size(Analysis_table,2);
meanF = zeros(table_size,1);

table = [Analysis_table(:,1:table_wide-4)]; % -2 because the 2 rightmost columns are reserved to inform of data 

for i=1:length(Analysis_table)
meanF(i) = mean(table(i,:));
end
% meanF=meanF.';

rowmean =  find(meanF(:)==max(meanF(:)));
rowmTHn = find(Analysis_table(:,THn)==max(Analysis_table(:,THn)));

parameters_meanF = [Analysis_table(rowmean,table_wide-1) Analysis_table(rowmean,table_wide)]
parameters_thF = [Analysis_table(rowmTHn,table_wide-1) Analysis_table(rowmTHn,table_wide)]


end

