# Amazon Reviews

### Goal

The raw data contains 10 years of Amazon fine food reviews (~500,000 reviews).  There are 4 different warehouse locations.  The goal is to predict whether or not a user liked the product they are reviewing based on the summary of the review, the text of the review, the user, and the product.  This is a NLP use case since the most informative features in the data are text features.


### Data Cleaning

The raw data consists of the Score the user gave the product.  The scores range from 1 - 5.  To convert this problem to a binary supervised learning problem, we added a new column called: `PositiveReveiew`.  We considered the review positive, if the Score was 4 or 5. 

**Steps**

1. Add `PositiveReview` column based on review score
2. Randomly sample the data from ~500k reviews to 100k reviews 

### References

* Original Dataset: <https://www.kaggle.com/snap/amazon-fine-food-reviews>