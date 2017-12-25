function max_inliers = ransac_t(top_img, query_img, num_trials, k, threshold)

    [top_keypts,top_desc] = vl_sift(single(top_img));
    [query_keypts, query_desc] = vl_sift(single(query_img)) ;
    [matches, scores] = vl_ubcmatch(top_desc, query_desc);
    num_matches = size(matches, 2);

    % sort the matches by scores, we will use the k top matches
    sort_matches= zeros(num_matches, 3);
    sort_matches(:, 1:2) = matches';
    sort_matches(:, 3) = scores';
    sort_matches = sortrows(sort_matches, 3);

    if (num_matches < 4) 
        return;
    else
        num_matches = min(num_matches, k);
    end


    top_matches = sort_matches(:, 1);
    query_matches = sort_matches(:, 2);

    max_inliers = -1; 

    for i=1:num_trials 
     
        rand_idx = randperm(num_matches, 4);
        sample_q = query_matches(rand_idx);
        sample_t = top_matches(rand_idx);
        
        A = zeros(8, 9);
        homography_tr = zeros(3, 3);
        % Find the homography
        for i = 1:4 

            x1 = top_keypts(1, sample_t(i));
            x2 = query_keypts(1, sample_q(i));
            xx = -(x1*x2);

            y1 = top_keypts(2, sample_t(i));
            y2 = query_keypts(2, sample_q(i));
            yy = -(y1*y2);

            x2y = -(x2*y1);
            xy2 = -(y2*x1);

            A_idx = 2*(i-1) + 1;
            Aa_idx = 2*(i-1) + 2;
            A(A_idx, :) = [x1 y1 1 0 0 0 xx x2y -x2];
            A(Aa_idx, :) = [0 0 0 x1 y1 1 xy2 yy -y2];
        end
        
        M = A'*A;
        [V, D] = eig(M);
        ev_size = size(V, 2);
        min_eig = Inf;
        min_idx = 0;

        % finds the eigenvector with min eigen values
        % and uses it to compute Homegraphy H matrix
        for idx=1:ev_size 
            if D(idx,idx) < min_eig
                min_eig = D(idx,idx);
                min_idx = i;
            end
        end

        min_eigvect = V(:, min_idx);
        homography_tr(1, 1:3) = min_eigvect(1:3);
        homography_tr(2, 1:3) = min_eigvect(4:6);
        homography_tr(3, 1:3) = min_eigvect(7:9);
        
        inliers = 0;
        for j=1:num_matches

            coor = top_keypts(1:2, top_matches(j));

            x = coor(1);
            y = coor(2);
            x1 = query_keypts(1, query_matches(j));
            y1 = query_keypts(2, query_matches(j));

            Ph = homography_tr * [x;y;1];
            Pp = [Ph(1)/Ph(3), Ph(2)/Ph(3)]; 
            dist = sqrt((Pp(1)-x1 )^2 + (Pp(2)-y1)^2);

            if (dist <= threshold)
                inliers = inliers + 1;
            end

        end

        if inliers > max_inliers

            max_inliers = inliers;

        end 
    end

end