classdef distance_matrix_requestor < handle
    %DISTANCE_MATRIX_REQUESTOR
    %   Computes a matrix of distance values (geodesic & pearson)
    %   Saves matrix in SAVE_DIR
    
    properties
        condition1;
        condition2;
        DIR;
        SAVE_DIR;
        DATA_DIR;
        TEMP_DIR;
        trim_method;
        max_workers;
        N;
        kROI;
        tau_list;
        p1;
        p2;
        FC_list1;
        FC_list2;
    end
    
    methods
        function obj = distance_matrix_requestor(condition1, condition2, DIR, trim_method, N, kROI, tau_list)
            %DISTANCE_MATRIX_REQUESTOR Construct an instance of this class
            %   Detailed explanation goes here
            obj.condition1 = condition1;
            obj.condition2 = condition2;
            
            
            if nargin < 4
                obj.trim_method = 'demo';
                obj.N = 20;
                obj.kROI = 300;
                obj.tau_list = [0, 0.001, 0.01, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20];
            else
            % trim_method: 'full' or 'trim' or 'truncated'
                obj.trim_method = trim_method;
            
                obj.N = N;
                obj.kROI = kROI;
                obj.tau_list = tau_list;
            end 
            
            obj.DATA_DIR = strcat(DIR, '/data');
            obj.SAVE_DIR = strcat(DIR, sprintf('/results/%s/N_%d_kROI_%d/whole_brain/distance_matrix', obj.trim_method, obj.N, obj.kROI));
            obj.TEMP_DIR = strcat(DIR, '/z_temp');
            
            if ~exist(obj.SAVE_DIR, 'dir')
                mkdir(obj.SAVE_DIR);
            end
            if ~exist(obj.TEMP_DIR, 'dir')
                mkdir(obj.TEMP_DIR);
            end 
            
            % Add distance_FC class to path
            UTILS_DIR = strcat(DIR, '/utils/distance_FC'); 
            addpath(UTILS_DIR);
        end
        
          
        function [base_file, dist_path] = get_save_path(obj, tau, distance)
            %GET_SAVE_PATH
            %   returns the savepath for given inputs
            base_file = sprintf('%s_test_%s_%s_train_%s_%s_tau_%d.mat', distance, obj.condition1, obj.p1, obj.condition2, obj.p2, tau);
            dist_path = obj.SAVE_DIR;
        end
        
        
        function [base_file, dist_path] = get_save_path_symmetric(obj, tau, distance)
            %GET_SAVE_PATH_SYMMETRIC
            %   returns the savepath for given inputs for a symmetric
            %   matrix
            base_file = sprintf('%s_test_%s_%s_train_%s_%s_tau_%d.mat', distance, obj.condition2, obj.p2, obj.condition1, obj.p1, tau);
            dist_path = obj.SAVE_DIR;
        end  
        
        
        function save_dist(obj, D, tau, distance)
            %SAVE_DIST
            %   saves matrices D and symmetric of D in their respective
            %   save paths 
            [base_file, dist_path] = obj.get_save_path(tau, distance);
            temp_path = sprintf('%s/%s', obj.TEMP_DIR, base_file);
            save(temp_path, 'D');
            
            
            movefile(temp_path, dist_path);
            
            
            [base_file, dist_path] = obj.get_save_path_symmetric(tau, distance);
            temp_path = sprintf('%s/%s', obj.TEMP_DIR, base_file);
            D = D.';
            save(temp_path, 'D');
            movefile(temp_path, dist_path);
            
        end   
        
        function compute_dist_matrix(obj, tau, distance)
            %COMPUTE_DIST_MATRIX
            %   computes the matrix containing pearson and geodesic values
            %   for given FC matrices using tau_list and distance_FC class
            
            %[base_file, dist_path] = obj.get_save_path(tau, distance);
            
            D = [];
            for i = 1:size(obj.FC_list1, 3)
                T = [];
                for j = 1:size(obj.FC_list2, 3)
                    FCA = obj.FC_list1(:, :, i) + (tau * eye(obj.kROI));
                    FCB = obj.FC_list2(:, :, j) + (tau * eye(obj.kROI));
                    dist = distance_FC(FCA, FCB);
                    if strcmp(distance, 'geodesic')
                        T = [T; dist.geodesic()];
                    elseif strcmp(distance, 'pearson')
                        T = [T; dist.pearson()];
                    end
                end
                D = [D, T];
            end
            obj.save_dist(D, tau, distance);        
        end
        
        
        function get_dist_matrix(obj)
            %GET_DIST_MATRIX
            % calls on compute_dist_matrix to find pearson and geodesic
            % values of FC matrices
            tau = 0;
            
            distance = 'pearson';
            obj.compute_dist_matrix(tau, distance);
            
            distance = 'geodesic';
            obj.compute_dist_matrix(tau, distance);
        end
        
        
        function make_distance_requests(obj)
            %MAKE_DISTANCE_REQUESTS
            % for a given pair of conditions, gets the distance matrices
            
            file = sprintf('%s/%s/FC_N_%d_kROI_%d_%s_blocks.pkl', obj.DATA_DIR, obj.condition1, obj.N, obj.kROI, obj.trim_method);         
            fid = py.open(file, 'rb');
            data1 = py.pickle.load(fid);
            cdata1 = cell(data1);
            sdata1 = [];
            for i = 1:size(cdata1, 2)
                sdata1 = [sdata1; struct(cdata1{i})];
            end
            
            file = sprintf('%s/%s/FC_N_%d_kROI_%d_%s_blocks.pkl', obj.DATA_DIR, obj.condition2, obj.N, obj.kROI, obj.trim_method);
            fid = py.open(file, 'rb');
            data2 = py.pickle.load(fid);
            cdata2 = cell(data2);
            sdata2 = [];
            for i = 1:size(cdata2, 2)
                sdata2 = [sdata2; struct(cdata2{i})];
            end
            
            obj.p1 = 'LR1';
            obj.p2 = 'RL1';
            
            obj.FC_list1 = double(sdata1(1).LR1);
            for i = 2:size(cdata1, 2)
               obj.FC_list1(:, :, i) = double(sdata1(i).LR1);
            end
            
            obj.FC_list2 = double(sdata2(1).RL1);
            for i = 2:size(cdata2, 2)
               obj.FC_list2(:, :, i) = double(sdata2(i).RL1);
            end
            
            obj.get_dist_matrix();
        end
    end
end

