
function [db_vector, db_norm, wi, cumlative_wi] = build_dv(db_dir, vocabulary_tree, type)

    db_im_names = dir([db_dir '/*.jpg']);
    total_imgs = size(db_im_names, 1);
     
    K = vocabulary_tree.K;
    L = vocabulary_tree.depth;
    depth = L+1;
    total_leaves=K^L;
    total_nodes = ((K^depth) - 1) / (K-1);
    
    N = total_imgs;
    
    
    db_vector(N) = struct;
    db_norm = zeros(1, N);
    for i=1:N
        db_vector(i).nodes = zeros(1, total_nodes-1);
    end
    
    for i=1:total_nodes-1
        Ni.count(i) = 0;
        Ni.last_img(i) = 0;
    end

    for n_img=1:total_imgs


        img=imread(fullfile(db_dir,db_im_names(n_img).name));
        img=single(rgb2gray(img));

        [~, sift_desc] = vl_sift(img);
        total_descriptors = size(sift_desc,2);

        for j=1:total_descriptors 
            
            sift_descriptor = sift_desc(:, j); 
            search_tree = vocabulary_tree;   
            
            leaf_idx = 1;
            node_idx = 0;
            for level=1:L
                best_sub = 1; 
                best_center_score = inf;

                for branch=1:size(search_tree.centers, 2)
                    current_center = search_tree.centers(:, branch);

                    %get branch with min edist
                    result = single(current_center) - single(sift_descriptor);
                    result = sum(result.^2);

                    if result < best_center_score
                        best_sub = branch;
                        best_center_score = result;
                    end
                end
 
                leaf_idx = ((leaf_idx - 1) * K) + best_sub;
                node_idx = node_idx + leaf_idx;
                db_vector(n_img).nodes(node_idx) = db_vector(n_img).nodes(node_idx) + 1;

                if level ~= L %leaf level
                    search_tree = search_tree.sub(best_sub);
                end

                if n_img ~= Ni.last_img(node_idx)
                    Ni.last_img(node_idx) = n_img;
                    Ni.count(node_idx) = Ni.count(node_idx) + 1;
                end             
                node_idx = K^level;
            end
        end
    end
 
    % get the weights
    wi = log((N)./Ni.count(1, :));
    wi(Ni.count(1,:) == 0) = 0; 

    
    % IMPROVEMENT PART - THIS IS TO WEIGH UP THE leaf nodes and the nodes
    % in the bottom level more, thus a database vectore having different
    % paths down the tree compared to a query vector will have the difference
    % of score futhur down the path of tree weighted up
    
    cumlative_wi = zeros(1, total_nodes-1); %dont count root node
    for idx=1:K
        cumlative_wi(idx) = wi(i);
    end

    total_intermediate = total_nodes - total_leaves - 1; %dont count root node
    for idx=1:total_intermediate
        fnode = 1 + (idx*K);
        lnode = (fnode-1+K);
        for cidx=fnode:lnode
            cumlative_wi(cidx) = wi(cidx) + cumlative_wi(idx);
        end
    end
    
    % Compute the db vector for each db image
    if type == 1
        for im_idx=1:N
            db_vector(im_idx).nodes = db_vector(im_idx).nodes .* wi;
            weighted_d = db_vector(im_idx).nodes;
            db_norm(im_idx) = norm(weighted_d, 1);
        end
    else %type = 2
        for im_idx=1:N
            db_vector(im_idx).nodes = db_vector(im_idx).nodes .* cumlative_wi;
            weighted_d = db_vector(im_idx).nodes;
            db_norm(im_idx) = norm(weighted_d, 1);
        end    
    end
    
    
end
    
    
 


