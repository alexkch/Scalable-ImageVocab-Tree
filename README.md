# Scalable-ImageVocab-Tree
by: Alex Chang

Scalable Image Vocabulary Tree
Implementing [1] using Stanford Mobile Visual Search imageset [2] as test and training dataset

[1] implementation details:

(a) Keypoint detection
(b) Keypoint description with rotation and scale in-variance
(c) Building and using the vocabulary tree (i.e. quantization)
(d) Hierarchical scoring
(e) Retrieval

STEP 1: For a test image, retrieve top 10 matches (DVD cover images from the database) returned
via the implemented approach. 

Then... using RANSAC:
STEP 2: Compute a homography with your implementation
from above for each retrieved DVD cover image and the test image.
STEP 3: Find the DVD cover image from (4) with the highest number of inliers. Plot the test
image with the localized DVD cover as well as the best retrieved DVD cover

Reference:

[1] Nister, Stewenius, Scalable Recognition with a Vocabulary Tree, CVPR 2006, 
http://www-inst.eecs.berkeley.edu/~cs294-6/fa06/papers/nister_stewenius_cvpr2006.pdf

[2] https://sites.google.com/site/chenmodavid/datasets
