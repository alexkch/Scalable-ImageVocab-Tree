function scores = heirarchial_scoring2(db_vectors, db_norm, q_vector, q_norm)


    all_imgs_size = size(db_vectors, 2);
    scores = ones(all_imgs_size,2)*2;
    
    for im=1:all_imgs_size
        
        scores(im, 1) = im;
        
        di_norm = db_vectors(im).nodes(:) ./ db_norm(im);
        qi_norm = q_vector(:) ./ q_norm;
        diff = abs(qi_norm - di_norm) - abs(qi_norm) - abs(di_norm);
        
        scores(im, 2) = scores(im,2) + sum(diff);

    end
    
    scores = sortrows(scores, 2);
end




