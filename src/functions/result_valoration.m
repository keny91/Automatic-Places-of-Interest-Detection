function [ valoration , unused_cores, pairing_matrix,n_asignated] = result_valoration( monuments_XY , cores_XY, threshold, suboptimal_threshold, penalty )
%EVALUATION: known a list of monuments we will compare the proximity of the
%cluster cores to this monuments



%%% PARAMETERS

evaluation = 0;

%   Detailed explanation goes here

% PLOT in 3 diferent colours:
%     Green: Optimal estimation
%     Orange/Yellow: Suboptimal estimation
%     Red: This core does not have a proper estimation

% 1_ In meter find which cluster is closer

n_cores = size(cores_XY(:,1),1); % number of cores
n_monuments = size(monuments_XY(:,1),1);  % number of interest points in the city:

% this matrix represent:
%     Pairing_matrix(1), pairing_matrix(2) coordinatesXY of the core
%     Pairing_matrix(3), pairing_matrix(4) coordinatesXY of the associated
%     monument
%     pairing_matrix(5) distance between both points
%     pairing_matrix(6) asociated monument from a numered list

pairing_matrix = zeros(n_cores,6);

% min_dist_core2monu = threshold;
% distance = 0;  % value outside the threshold
selected_monument = 0;  % This Variable will be 0 if the method 

% PROBLEM: we might pair a node with a monumment when another could be
% closer to that monument 


%%%%%%%%%%%%%%%%%% Creating a Matrix to ease the evaluation  %%%%%%%%%%%%%%%%%%

for i = 1:n_cores % evalueate all cores 
   min_dist_core2monu = threshold;  % reset distance for each new core
   selected_monument = 0;
   pairing_matrix(i,1) = cores_XY(i,1); % register the node 
   pairing_matrix(i,2) = cores_XY(i,2);
   
    for j = 1:n_monuments % compare to all monuments 
        dx = monuments_XY(j,1) - cores_XY(i,1); 
        dy = monuments_XY(j,2) - cores_XY(i,2);
        distance = abs((dx^2 + dy^2).^(1/2)); % modulus
        
        if ((distance < min_dist_core2monu) && (distance < threshold))  % if is closer than any other previous
            min_dist_core2monu = distance;
            selected_monument = j;  
            pairing_matrix(i,3) = monuments_XY(j,1); % register the monument as selected
            pairing_matrix(i,4) = monuments_XY(j,2);
            pairing_matrix(i,5) = min_dist_core2monu; % register minimun distance
            pairing_matrix(i,6) = selected_monument;
            
        end
    end  % END monument search
    
%      At this point we have j registers made 
%      Right now more than 1 monument can be assigned to the same monument   
%      Now we have selected the minimal distance posible for that monument


        % INSERTAR AQUI COMPROBACIÓN DE MEJOR RESULTADO
    
  
    
end    





for i = 1:n_cores
%%%%%%%%%%%%% We give our results a numerical valoration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% depending on the number of monuments we have registered.
% The normal behaviour is to expect more cores than monuments. Having unasigned
% cores and multiple cores asocited to a monument 

selected_monument = pairing_matrix(i,6);
min_dist_core2monu = pairing_matrix(i,5);
% reset value

% IMPLIED THAT min_dist_core2monu < threshold

    % case 1: we paired a core-monument and is under ther optimal threshold
    if ((selected_monument ~= 0) && (min_dist_core2monu < suboptimal_threshold)) 
        % 100% modificator -> max=1, min = 0.5
%         modificator=1;
        evaluation = evaluation + 1*(0.5+(1-min_dist_core2monu/threshold)*0.5);
    % case 2: suboptimal case -> max=0.5, min = 0
    elseif ((selected_monument ~= 0) && (min_dist_core2monu < threshold) && (min_dist_core2monu > suboptimal_threshold))    
        % 50% modificator
%         modificator=0.5;
        evaluation = evaluation + 0.5*(1-min_dist_core2monu/threshold);
        
    % case 3: no monument associated  evaluation =  0 , NOW no penalty
    else
        
        evaluation = evaluation - penalty;

    end  % END of if  


end


%%%%%%%%%%%%%%%%%%%%%  Exporting Unidentified Cores %%%%%%%%%%%%%%%%%%%%%
% Matrix is now completed

%we create a 2 by n_unasigned for the unasined cores
%run and see if we can delete c and v
[r] = find(pairing_matrix(:,3)==0);
n_unasigned = size (r,1);
unused_cores = zeros(n_unasigned,2);

for k=1:1:n_unasigned
    
    %security check
    if ((pairing_matrix(r(k),3) == 0) && (pairing_matrix(r(k),4) == 0 && pairing_matrix(r(k),6)==0))
    unused_cores(k,1) = pairing_matrix(r(k),1);
    unused_cores(k,2) = pairing_matrix(r(k),2);
    end

end

%%%%%%%%%%%%%%%%%%%%%  Final valoration  %%%%%%%%%%%%%%%%%%%%%
        
% Apply modifications to de result here

% The max puntuation will be achived depending on the number of mnuments
% identified
% NOTES: if the value is over 100 mean that we are assigning more m
valoration = (evaluation/n_cores)*100;



% 5_ Print in a document 


fid = fopen('./evaluation.txt','wt'); 
fprintf(fid,'%4s %8i \n\n','valoration:  ',valoration);
fprintf(fid,'%4s %8s %16s %16s %16s %16s %16s\n','num','coreX','coreY','monuX','monuY','distance','Monument');
for i = 1:n_cores
    fprintf(fid,'%d :   %f        %f       %f      %f      %f      %f\n',i,pairing_matrix(i,:));
    % fprintf(fid,'%f\n',cores_COOR(i,2));  % The format string is applied to each element of a

end
fclose(fid);



fid = fopen('monument_asignation.txt','wt'); 
    fprintf(fid,'%4s %8s %16s  %16s \n','num','monuX','monuY','Nºcores asignated');

    n_asignated = zeros(n_monuments,1);
for i=1:n_monuments
    n_asignated(i) = size(find(pairing_matrix(:,6)==i),1);
    fprintf(fid,'%d :   %f        %f       %f   \n',i,monuments_XY(i,1),monuments_XY(i,2),n_asignated);
    
end
fclose(fid);
% 
% fid = fopen('./monument_asignation.txt','wt'); 
% fprintf(fid,'%4s %8i \n\n','valoration:  ',valoration);
% fprintf(fid,'%4s %8s %16s %16s %16s %16s %16s\n','num','coreX','coreY','monuX','monuY','distance','Monument');
% for i = 1:n_cores
%     fprintf(fid,'%d :   %f        %f       %f      %f      %f      %f\n',i,pairing_matrix(i,:));
%     % fprintf(fid,'%f\n',cores_COOR(i,2));  % The format string is applied to each element of a
% 
% end
% fclose(fid);



end