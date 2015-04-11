
clear all;

addpath('.\src\code\');
addpath('.\src\functions\');


% Load labels
fid = fopen('labels.txt','rt');
tmp = textscan(fid,'%s','Delimiter','\n');
labels = tmp{1};
fclose(fid);

file = fopen('GPS_coordinates.txt');
tmp = textscan(file,'%s %s');
% labels = tmp{1};
monuments = [tmp{1} tmp{2}];
fclose(file);

% Load monument coordinates

%split by '\n'
%split by ' '
%convert to int  
% intArray = int8(array)

% Nº of pictures per monument
Pics_per_Monu = 100;
% Number of images chosen to represent the monument
n_images = 5;
% Number of monuments in the list
n_monuments = size(monuments,1);

% Parameters: GIST
clear param
param.imageSize = [256 256]; % it works also with non-square images
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;

% Convert labels from cells to array
labels_mat = zeros(size(labels,1),1);
for n=1:size(labels,1)
    labels_mat(n)=str2num(labels{n});
end
% labelsmat=cell2mat(labels);

% Drop unvalid registers if there are
% In this particular case we drop the first 3053 logs
for n=1:3053
    labels_mat(1)=[];
end

table_locator = 1;
for n=1:n_monuments

    % Find the number of monuments in the
    Pics_per_Monu = length(find(labels_mat == n))
    table_locator
    end_table = table_locator+Pics_per_Monu-1
%     table_locator = (1+(n-1)*Pics_per_Monu);
    
    clear gist_table;
%     table_size = ;
%     gist_table= zeros(Pics_per_Monu,table_length);

%     for i = (1+(n-1)*Pics_per_Monu):1:n*Pics_per_Monu
    for i = (table_locator):1:end_table
    

        str = num2str(i);
        commandline = strcat('.\datafiles\imagesDB\',str,'.jpg');
        img = imread(commandline, 'jpg');
        imageSize = size(img,1);
        

         position_in_table = i-table_locator+1;
         [gist, param] = LMgist(img, '', param);
         gist_table(position_in_table,:)= gist(:);
%          
%         figure (1)
%         subplot(121)
%         imshow(img)
%         title('Input image')
%         subplot(122)
% %         showGist(gist, param)
%         plot(gist);
%         title('Descriptor')
%         
%         
        
    end


%     We must find now the "mean" parameter gist which describes the image
%     best.

%     Mean for each column
% 
% for j=1:length(gist)
%         mean_gist(j) = mean(gist(:,j));      
%     end
%     

%     mean_gist = mean(gist_table,1);
%     mean_gist = median(gist_table,1);

%     We take 3 closer images to the following
    [IDX,mean_gist,sumd] = kmeans(gist_table,n_images);
%     mean_gist = mode(gist_table,1);
%     figure (2)
%     plot(mean_gist)
%     s = std(gist);
%       Desviation from the mean (Cuadratic desviation)

%   Generate the 

    for j =1:n_images
        for i =1 : Pics_per_Monu

            diference_table(i,:) = abs(mean_gist(j,:) - gist_table(i,:));
            mean_diff_table(i) = mean(diference_table(i));
        end

    %     find the image with the smaller desviation
        [row,col]=find(mean_diff_table==min(min((mean_diff_table))));
        image_selected(n,j) = table_locator-1+col(1);

    end
    table_locator = (Pics_per_Monu+table_locator);
    

end