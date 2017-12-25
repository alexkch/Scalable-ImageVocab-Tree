
function [weighted_q, q_norm] = get_qnorm(query_descriptors, vtree, cumlative_wi)


    K = vtree.K;
    L = vtree.depth;
    depth = L+1;

    total_descriptors=size(query_descriptors,2);
    total_nodes = ((K^depth) - 1) / (K-1);
    
    q_vector = zeros(1, total_nodes-1);

    for i=1:total_descriptors

        query_desc = query_descriptors(:,i); 
        search_tree = vtree;   

        leaf_idx = 1;
        node_idx = 0;
        for level=1:L
            
            best_sub = 1; 
            best_center_score = inf;

            for branch=1:size(search_tree.centers, 2)
            
                current_center = search_tree.centers(:, branch);

                result = single(current_center) - single(query_desc);
                result = sum(result.^2);
    
                if result < best_center_score
                    best_sub = branch;
                    best_center_score = result;
                end
            end
            
            
            leaf_idx = ((leaf_idx - 1) * K) + best_sub;
            node_idx = node_idx + leaf_idx;            
            q_vector(node_idx) = q_vector(node_idx) + 1;
            
            if level ~= L
                search_tree = search_tree.sub(best_sub);
            end
            
            node_idx = K^level;
        end
    end
        
    weighted_q = q_vector .* cumlative_wi;
    q_norm = norm(weighted_q, 1);
    
end
        
        
        
        
        
        
        
        
        
        
