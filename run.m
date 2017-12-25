
function findDvd
%% Author: Alex K. Chang 
%  ID: 1000064681
%  CSC420 Prj - 2
%
%% Setup vlfeat
run('vlfeat-0.9.20/toolbox/vl_setup');

%% Load Tree
load('precomp\K9L6\vtree.mat','vtree');

%% Load DB
load('precomp\K9L6\db_vectors.mat','db_vectors');
load('precomp\K9L6\db_norms.mat','db_norms');
load('precomp\K9L6\cumlative_wi.mat','cumlative_wi');

%% Load Query
load('weighted_q.mat','weighted_q');
load('q_norm.mat','q_norm');

%% Setup Parameters

K=9; % branching factor
L=6; % levels of the tree not including the root node
do_save = 1; % 0 is false, 1 is true

%% Setup DB

db_dir = 'dvd_covers/Reference';
db_imgs = dir([db_dir '/*.jpg']);
total_imgs = size(db_imgs,1);

%% Extract Descriptors

sift_descriptors = [];
for i = 1:total_imgs
    
    filename = fullfile(db_dir,db_imgs(i).name);
    img = imread(filename);
    img = single(rgb2gray(img));
    [~, sift_desc] = vl_sift(img);
    sift_descriptors = [sift_descriptors sift_desc];

end


%% Build Vocab and save tree

vtree = vl_hikmeans(uint8(sift_descriptors), K, K^L);
save('vtree.mat','vtree');

%% Traverse tree and build cumlative weights and db vectors / norms

type = 2;
% IMPROVEMENT 1, USING Cumlative weights 
[db_vectors, db_norms, wi, cumlative_wi] = build_dv(db_dir, vtree, type);

save('db_vectors.mat','db_vectors');
save('db_norms.mat','db_norms');
save('cumlative_wi.mat','cumlative_wi');

%% Setup Query

% Choose query image number
%qimg_num = 92; %RANK 2, can use homography
qimg_num = 17;

%query_dir='dvd_covers/Palm';
%query_dir='dvd_covers/E63';
query_dir='dvd_covers/Droid';
%query_dir='dvd_covers/Canon';

query_im_name = db_imgs(qimg_num).name;
query_dir = fullfile(query_dir,query_im_name);

% IMPROVEMENT 2 - RESIZING IMAGE

%regular size
%query_img = single(rgb2gray(imread(query_dir)));

%resized 75%
%query_img = single(rgb2gray(imresize(imread(query_dir), 0.75)));
%resized 50%
query_img = single(rgb2gray(imresize(imread(query_dir), 0.5)));
%resized 25%
%query_img = single(rgb2gray(imresize(imread(query_dir), 0.25)));


%for final output
q_img_display = imread(query_dir);


%% Compute Query Norms

[~, query_descriptors] = vl_sift(query_img);
[weighted_q, q_norm] = get_qnorm(query_descriptors, vtree, cumlative_wi);

save('weighted_q.mat','weighted_q');
save('q_norm.mat','q_norm');

%% Heirarchial Scoring
 
scores = heirarchial_scoring2(db_vectors, db_norms, weighted_q, q_norm);


% Obtain the top 10
candidates = zeros(10,1);
top_hscore_result = scores(1);
output_top10 = zeros(10,2);
for idx=1:10
    candidates(idx) = scores(idx);
    output_top10(idx,:) = scores(idx, :);
end
query_dir
output_top10
%% Run Homography

threshold = 2.9;
trials = 1000;
highest_score = -1;
k = 100;
for i=1:10
    candidate_dir = fullfile(db_dir,db_imgs(candidates(i)).name);
	candidate = rgb2gray(imread(candidate_dir));
	
	score = ransac_t(candidate, query_img, trials, k, threshold);
    
	if highest_score < score
        highest_score = score;
		match_idx = i;
	end
end

best_img = candidates(match_idx);

%% Display results

% Display Query Img
figure;imagesc(q_img_display);

% Display results from H-score & Ransac
%results1 = db_imgs(top_hscore_result).name;
results2 = db_imgs(best_img).name;
%r1 = imread(fullfile(db_dir, results1));
r2 = imread(fullfile(db_dir, results2));

%figure;imagesc(r1);
figure;imagesc(r2);
best_img

end


