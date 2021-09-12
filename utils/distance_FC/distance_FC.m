classdef distance_FC
    % DISTANCE_FC 
    % gives the geodesic distance and pearson dissimilarity of two matrices
    % FC1 and FC2
    properties
        FC1;
        FC2;
        
        % minimum threshold for eigenvalues. DEFAULT 1E-3
        eig_thresh;
        
    end
    
    methods
        function obj = distance_FC(FC1,FC2,eig_thresh)           
            obj.FC1 = FC1;
            obj.FC2 = FC2;
            
            if nargin < 3
                obj.eig_thresh = 0.001;
            else
                obj.eig_thresh = eig_thresh;
            end
            
            % ensures matrices are symmetric
            obj.FC1 = obj.ensure_symmetric(obj.FC1);
            obj.FC2 = obj.ensure_symmetric(obj.FC2);
            
            addpath(strcat(DIR, '/utils/FC_analyzer'));
        end
        
        
        function Qsymm = ensure_symmetric(obj, Q)
            Qsymm = (Q + Q') / 2;
        end 
        
        % takes all unique elements of the matrix and stores them in a 1D
        % array
        function vec = vectorise(obj, Q)
            tri = tril(Q, -1);
            
            vec = [];
            
            for i = 2:size(tri)
                for j = 1:(i-1)
                   vec = [vec; tri(i, j)];
                end
            end
        end     
        
        % returns the geodesic distance between two matrices
        function dist = geodesic(obj)
            
            % dist = sqrt(trace(log^2(M)))
            % M = Q_1^{-1/2}*Q_2*Q_1^{-1/2}
            
            [u, s, ~] = svd(obj.FC1);
            
            sd = diag(s);
            for i = 1:size(sd)
                if sd(i) < obj.eig_thresh
                    sd(i) = obj.eig_thresh;
                end
            end
            s = diag(sd);
            
            FC1_mod = u * s^(-1/2) * u';
            M = FC1_mod * obj.FC2 * FC1_mod;
            
            [~, s, ~] = svd(M);
            sd = diag(log(s));
            
            dist = sqrt(sum(sd.^2));
        end
    
        % returns the pearson dissimilarity of two matrices
        function pdsim = pearson(obj)
            
            r = corr(obj.vectorise(obj.FC1), obj.vectorise(obj.FC2));
            pdsim = (1-r)/2;
        end
        
        
        function hmap = get_minimal_fig(obj, Q)
            
            [~, kROI] = size(Q);
            
            hmap = heatmap(Q);
            
            ax = gca; 
            ax.XDisplayLabels = nan(size(ax.XDisplayData));
            ax.YDisplayLabels = nan(size(ax.YDisplayData));
            hmap.GridVisible = 'off';
            hmap.Colormap = redbluecmap;
        end
        
    end 
end

