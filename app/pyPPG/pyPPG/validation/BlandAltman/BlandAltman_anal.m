% The MIT License (MIT)
% 
% Copyright (c) 2023 Marton A. GODA, PhD.
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

function BlandAltman_anal(results_date,detector)
    % Set analysis: 
    if strcmp(detector, "pyPPG") || strcmp(detector, "PPGFeat") || strcmp(detector, "PulseAnal")
        isdet=1;
    else
        isdet=0;
    end
    
    % Get fiducial data
    [fps1,fps2]=get_fps(results_date, isdet, detector);
    all_names=fps1.Properties.VariableNames;
    names=[];
    for n=all_names
        if ~isnan(min(fps1.(n{1})))
            names=[names,n];
        end
    end
    
    % plot results 
    output_folder=plot_BA(fps1,fps2,isdet,names,results_date, detector);
    
    % crop BA plots
    crop_BA(names,results_date,output_folder);
end

function [fps1,fps2]=get_fps(output_folder,isdet,detector)
    % Load data
    if isdet
        load(strcat('..',filesep,'results',filesep,output_folder,filesep,detector,filesep,'MG_',detector,filesep,'MG_',detector,'.mat'))
        load(strcat('..',filesep,'results',filesep,output_folder,filesep,detector,filesep,'PC_',detector,filesep,'PC_',detector,'.mat'))
    else 
        load(strcat('..',filesep,'results',filesep,output_folder,filesep,detector,filesep,'MG_PC.mat'))
    end
    
    % define annotated fiducial points
    mg_fps=struct2table(MG_fps);
    mg_fps = removevars(mg_fps, 'dp');

    pc_fps=struct2table(PC_fps);
    pc_fps = removevars(pc_fps, 'dp');

    if isdet
        tmp_fps=(mg_fps{:,:} + pc_fps{:,:}) / 2;
        ref_fps = array2table(tmp_fps, 'VariableNames', mg_fps.Properties.VariableNames);
        
        ref_fps_on=ref_fps.on;
        tmp_fps=(ref_fps{:,:} - ref_fps.on)+1;
        ref_fps = array2table(tmp_fps, 'VariableNames', mg_fps.Properties.VariableNames);
        
        % define detected fiducial points
        det_fps=eval(['struct2table(',detector,'_fps)']);
        det_fps.('dp')=[];
        
        tmp_fps=(det_fps{:,:} - ref_fps_on)+1;
        det_fps = array2table(tmp_fps, 'VariableNames', det_fps.Properties.VariableNames);
        
        fps1=det_fps;
        fps2=ref_fps;
    else
        fps1=mg_fps;
        fps2=pc_fps;
    end
end

function output_folder=plot_BA(fps1,fps2,isdet,names,matlab_date,detector)
    % Check if the folder exists; if not, create it
    output_folder=strcat('..',filesep,'results',filesep,matlab_date,filesep,detector,filesep,'BlandAltman')
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    output_folder2=strcat(output_folder,filesep,'origin')
    if ~exist(output_folder2, 'dir')
        mkdir(output_folder2);
    end

    if detector=="MG_PC"
        range=20;
    elseif detector=="pyPPG"
        range=50;
    elseif detector=="PulseAnal"
        range=100;
    elseif detector=="PPGFeat"
        range=250;
    else
        range=120;
    end


    for fp_state = names        
        %% Example 1
        % data1
        data1(1:height(fps1),:,:) =  NaN;
        data1(1:height(fps1),:,:) =  table2array(fps1(:,fp_state));
        
        % data2
        data2(1:height(fps2),:,:) =  NaN;
        data2(1:height(fps2),:,:) =  table2array(fps2(:,fp_state));
        
        % BA plot paramters
        tit = strcat(fp_state); % figure title
        gnames = {fp_state}; % names of groups in data {dimension 1 and 2}
        
        if isdet
            label = {detector,'Reference','ms'}; % Names of data sets
        else
            label = {'MG','PC','ms'}; % Names of data sets
        end
        corrinfo = {'n','RMSE','r2','eq'};  % stats to display of correlation scatter plot
        BAinfo = {'n','RMSE'};     % stats to display on Bland-ALtman plot
        limits = 'auto';                    %'tight';%'tight';%'auto'; % how to set the axes limits
        colors = 'rbgmcky';                 % character codes
        colors = colors(1:length(fp_state));
        
        % Generate figure with symbols
        [cr, fig, statsStruct] = BlandAltman_func(data1,data2,label,tit,gnames,'corrInfo',corrinfo,'baInfo',BAinfo,'axesLimits',limits,'colors',colors,'markerSize',4,'showFitCI',' on', 'range',range);
        
        % Full file path
        outputFilename=strcat(fp_state,'.jpeg');
        outputFilePath = string(fullfile(output_folder2,outputFilename));

        % Save figure
        saveas(gcf, outputFilePath);

        % Close the figure
        close(gcf);
    end
end

function crop_BA(names,folder_name,output_folder)
    % Check if the folder exists; if not, create it
    output_folder2=strcat(output_folder,filesep,'cropped')
    if ~exist(output_folder2, 'dir')
        mkdir(output_folder2);
    end

    for i=1:length(names)
        tmp_fp=names(i);
    
        % Full file path
        Filename=strcat(tmp_fp,'.jpeg');
        originFolder=strcat(output_folder,filesep,'origin');
        FilePath = string(fullfile(originFolder, Filename));
    
        % Read the image file using imread
        imData = imread(FilePath);
    
        % Define the region to crop (in the format [xmin, ymin, width, height])
        [xmin, ymin, width, height]=deal(1200, 200, 900, 720);
        crop_region = [xmin, ymin, width, height];
    
        % Crop the specified region
        cropped_image = imcrop(imData, crop_region);
        imshow(cropped_image)

        % Calculate the position dynamically based on the size of the cropped image
        imageSize = size(cropped_image);
        titlePosition = [imageSize(2)/2, imageSize(1)*0.025]; % Middle of the width, 2.5% from the top

        % Add the title using the text function
        text(titlePosition(1), titlePosition(2), tmp_fp, Color='black', FontSize=20,FontWeight='bold');


        % Specify the desired resolution (DPI)
        desiredDPI = 300; % Adjust this value based on your requirements
        
        % Calculate the new pixel dimensions to achieve the desired DPI
        pixelWidth = round(desiredDPI * width / 25.4);
        pixelHeight = round(desiredDPI * height / 25.4);
        
        % Resize the cropped image to the desired pixel dimensions
        resizedImage = imresize(cropped_image, [pixelHeight, pixelWidth]);

        % Save the figure with high quality and added bold text
        outputFilePath=string(strcat(output_folder2,filesep,tmp_fp,'.jpeg'));
        imwrite(resizedImage, outputFilePath);
    end 
end

