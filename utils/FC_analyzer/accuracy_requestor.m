classdef accuracy_requestor < handle
    %ACCURACY_REQUESTOR 
    %   Computes the accuracy of the geodesic and pearson values computed
    %   for two conditions. Saves the accuracy in SAVE_DIR
    
    properties
        condition1;
        condition2;
        DIR;
        SAVE_DIR;
        LOAD_DIR;
        TEMP_DIR;
        trim_method;
        N;
        kROI;
        tau_list;
        distance_matrices;
    end
    
    methods
        function obj = accuracy_requestor(condition1, condition2, trim_method, N, kROI, DIR)
            %DISTANCE_MATRIX_REQUESTOR 
            obj.condition1 = condition1;
            obj.condition2 = condition2;
            
            if nargin < 4
                obj.trim_method = 'demo';
                obj.N = 20;
                obj.kROI = 300;
            else
            % trim_method: 'full' or 'trim' or 'truncated'
                obj.trim_method = trim_method;
                obj.N = N;
                obj.kROI = kROI;
            end
            
            
            obj.LOAD_DIR = strcat(DIR, sprintf('/results/%s/N_%d_kROI_%d/whole_brain/distance_matrix', obj.trim_method, obj.N, obj.kROI));
            obj.SAVE_DIR = strcat(DIR, sprintf('/results/%s/N_%d_kROI_%d/whole_brain/accuracy', obj.trim_method, obj.N, obj.kROI));
            obj.TEMP_DIR = strcat(DIR, '/z_temp');
            
            obj.distance_matrices = [];
            
            rootdir = obj.LOAD_DIR;
            filelist = dir(fullfile(rootdir, '**/*.*'));
            files = strings(numel(filelist), 1);
            for i = 1:numel(filelist)
                if ~filelist(i).isdir
                    str = convertCharsToStrings(filelist(i).name);
                    files(i) = str;
                end
            end
            
            if ~exist(obj.SAVE_DIR, 'dir')
                mkdir(obj.SAVE_DIR);
            end
            
            if ~exist(obj.TEMP_DIR, 'dir')
                mkdir(obj.TEMP_DIR);
            end 
            
            for i = 1:size(files, 1)
                case1 = contains(files(i), obj.condition1);
                case2 = contains(files(i), obj.condition2);
                if case1 && case2
                    obj.distance_matrices = [obj.distance_matrices; files(i)];
                end
            end
                
        end
        
        function avg = compute_accuracy(obj, D)
            %COMPUTE_ACCURACY 
            %   Computes the accuracy of distance matrix D
            N_ = size(D, 1);
            [~, labels] = min(D, [], 2);
            
            true = ones(N_, 1);
            for i = 1:N_
                true(i) = i;
            end
            
            accuracy = ones(N_, 1);
            for i = 1:N_
                accuracy(i) = labels(i) == true(i);
            end
            
            avg = mean(accuracy);
        end
        
        function get_accuracy(obj, file)
            %GET_ACCURACY
            %   uses compute_accuracy to find the accuracy of geodesic or
            %   pearson methods
            [~, base_file, ~] = fileparts(file);
            
            save_path = obj.SAVE_DIR;
            
            to_load = sprintf('%s/%s', obj.LOAD_DIR, base_file);
            
            if ~exist(save_path, 'dir')
                mkdir(save_path);
            else
                D = load(to_load);
                
                if size(D, 1)
                    accuracy = obj.compute_accuracy(D.D);
                    
                    dest = sprintf('%s/%s', save_path, base_file);
                    save(dest, 'accuracy');
                end
            end
        end
        
        function make_accuracy_requests(obj)
            % MAKE_ACCURACY_REQUESTS
            %   Calls on function get_accuracy for each distance matrix in
            %   distance_matrices
            for i = 1:size(obj.distance_matrices)
                obj.get_accuracy(obj.distance_matrices(i));
            end
        end
        
        
        function accu = load_accuracy(obj)
            %LOAD_ACCURACY
            %   loads accuracy files into matrix accu
            geo_LR_files = [];
            geo_RL_files = [];
            pear_LR_files = [];
            pear_RL_files = [];
            
            LR = sprintf('train_%s_LR', obj.condition1);
            RL = sprintf('train_%s_RL', obj.condition1);
            
            files = dir(sprintf('%s/*.mat', obj.SAVE_DIR));
            for i = 1:size(files, 1)
                file = files(i).name;
                to_load = sprintf('%s/%s', obj.SAVE_DIR, file);
                acc = load(to_load);
                if ~contains(file, 'B_')
                    if contains(file, 'geodesic')
                        if contains(file, LR)
                            geo_LR_files = [geo_LR_files, acc.accuracy];
                        elseif contains(file, RL)
                            geo_RL_files = [geo_RL_files, acc.accuracy];
                        end
                    end
                    
                    if contains(file, 'pearson')
                        if contains(file, LR)
                            pear_LR_files = [pear_LR_files, acc.accuracy];
                        elseif contains(file, RL)
                            pear_RL_files = [pear_RL_files, acc.accuracy];
                        end
                    end
                end
            end
            geos = struct('LR', geo_LR_files, 'RL', geo_RL_files);
            pears = struct('LR', pear_LR_files, 'RL', pear_RL_files);
            accu = struct('geodesic', geos, 'pearson', pears);
        end
        
        
        function bgraph = plot_accuracy(obj)
            %PLOT_ACCURACY
            % plots the accuracy of pearson and geodesic methods for given
            % distance_matrices.
            dists = ["pearson"; "geodesic"];
            points = [];
            accuracy = obj.load_accuracy();
            for i = 1:2
                d = convertStringsToChars(dists(i));
                disp(d);
                a = (accuracy.(d).LR + accuracy.(d).RL) / 2;
                points = [points; a];
            end
            bgraph = bar(points);
            
            bgraph.FaceColor = 'flat';
            bgraph.CData(1, :) = [0 0 1];
            bgraph.CData(2, :) = [1 0 0];
            title('demo');
            xlabel('condition1');
            ylabel('Accuracy');
            set(gca,'xticklabel', dists);
            
        end
            
            
    end
end

