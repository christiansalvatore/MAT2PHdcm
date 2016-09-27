function output = mat2phdcm(varargin)
% mat2phdcm saves layered images to Dicom files (.dcm) that can be read
% using Photoshop for further manipulation.
%   Input arguments:
%   method        'folder' or 'workspace'
%                 This variable indicates whether the image files to be
%                 converted in dicom layers are all contained in an input
%                 folder (case 'folder') or they have already been saved as
%                 a 4-D matrix in the workspace (case 'workspace').
%
%   input         This variable indicates the folder that contains the
%                 images(if method == 'folder') or the name of the 4-D
%                 matrix (if method == 'workspace').
%
%   input_format  (to be used only if method == 'folder')
%                 This variable indicates the file format of the images
%                 contained in the input folder to be used as layers.
%                 Leave empty if the folder contains only the images.
%
%   Output arguments:
%   output        The output path of the .dcm file.
%                 Note that the output directory is always the current
%                 directory.
%
%   Examples
%
%   Input images contained in a "dedicated" folder:
%   output = mat2phdcm('folder', 'path/to/images');
%
%   Input images contained in a generic folder:
%   output = mat2phdcm('folder', 'path/to/images', 'jpg');
%
%   Input images saved as a 4-D matrix:
%   output = mat2phdcm('workspace', matrix_name);

% Author: Christian Salvatore

% Copyright (C) 2016, Christian Salvatore
% All rights reserved.
%
% This file made available under the terms of the MIT license
% (see the COPYING file).

% Parse input variables
if ( nargin < 2 || nargin > 3 )
    error( message('MATLAB:imagesci:validate:wrongNumberOfInputs') );
end
[method, input, input_format] = parse_inputs(varargin{:});

% Output coordinates
output_path = pwd;
output_filename = 'out';

switch method
    case 'folder'
        if isempty(input_format)
            input_format = '*';
        end
        files = dir( fullfile(input,['*.' input_format]) );
        files = {files.name}';
        for i = 1:numel(files)
            isfile(i,1) = 1-isdir( fullfile(input,files{i}) );
        end
        files = files(logical(isfile));
        data = cell(numel(files),1);
        for i = 1:numel(files)
            temp_file = fullfile(input,files{i});
            data{i} = imread(temp_file);
        end
        % Create a layered 4-D matrix
        [a,b,c] = size(data{1});
        l = size(data,1);
        L = zeros(a,b,c,l);
        for i = 1:l
            L(:,:,:,l-i+1) = data{i}; % Reverse order
        end
                
    case 'workspace'
        SL = size(input);
        L = zeros(SL);
        for i = 1:SL(4)
            L(:,:,:,(SL(4)-i+1)) = input(i);
        end
        L = input;
        
    otherwise
        error('Wrong input argument: "method" was not correctly chosen.');
end

% Save loaded images as layered dicom file
output = fullfile(output_path,[output_filename '.dcm']);
dicomwrite(uint8(L), output);

end

function [method, input, input_format] = parse_inputs(varargin)

    method = varargin{1};
    input = varargin{2};
    input_format = '';
    
    if strcmp(method,'folder') && nargin == 3
        input_format = varargin{3};
    end
    
end
