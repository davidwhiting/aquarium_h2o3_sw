###
### Lending Club Loan Default
###

## In this tutorial, we will go through a step-by-step workflow to determine
## loan deliquency. Predictions will be made based only on the information
## available at the time the loan was issued. Our data is a portion of the
## public Lending Club data set.

### Workflow

##  1. Start H2O-3 cluster
##  2. Import data
##  3. Clean data
##  4. Feature engineering
##  5. Model training
##  6. Examine model accuracy
##  7. Interpret model
##  8. Save and reuse model
##  9. AutoML (optional)
## 10. Stop H2O-3 cluster


#################################################################################
###
### Step 1 (of 10). Start H2O-3 cluster
###
#################################################################################

## The method you use for starting and stopping an H2O-3 cluster will depend on
## how H2O is set up on your system. The method we show here is the simplest and
## most straightforward. It is critical, however, that you properly shut down
## any H2O cluster that you start.

library(h2o)
h2o.init(bind_to_localhost = FALSE, context_path="h2o")

#################################################################################
###
### Step 2 (of 10). Import data
###
#################################################################################

## A full description of the complete Lending Club data is available here:
## https://www.kaggle.com/pragyanbo/a-hitchhiker-s-guide-to-lending-club-loan-data/notebook
##
## The data set we use below is a local copy of
## https://s3-us-west-2.amazonaws.com/h2o-tutorials/data/topics/lending/lending_club/LoanStats3a.csv.

### View and Inspect Data
##
## The loans data is loaded directly into H2O using the following command:

loans = h2o.importFile("../../data/lending_club/LoanStats3a.csv", 
                       col.types = c("int_rate" = "string",
                                     "revol_util" = "string",
                                     "emp_length" = "string",
                                     "verification_status" = "string"))


## Note that the h2o.importFile command completely bypassed R and loaded the
## data directly into H2O memory. Alternatively, one could load a dataset into a
## dataframe then pass it to H2O. The approach we use above is far more
## efficient and generally recommended, especially as data size increases. 

### Inspect the Data with H2O Flow
##
## Now is a good time to enable H2O Flow. Although H2O Flow can be used for
## everything from loading data to building models to creating production code,
## we use it here for data investigation and H2O system monitoring. 
##
## Note: the reported IP above
##
##     Connecting to H2O server at http://127.0.0.1:54321 ... successful.
##
## is the local IP within your particular cloud instance.
##
## To open H2O Flow in your own browser, copy your browser URL and replace the
## port with 54321. 
##
## For example, my RStudio URL is
##
##     http://52.202.98.125:8787.
##
## After opening a new browser tab or window, I copy the address and replace
## port 8787 with 54321: 
##
##    http://52.202.98.125:54321.

## A quick summary of the data size and data fields are shown below.

dim(loans)
head(loans)

### Editorial comment: Data preparation for modeling
##
## In this tutorial, we either omit or rush through some steps that a modeler
## normally would spend a considerable amount of time on. For example, we
## completely skip exploratory data analysis used in conjunction with
## modeling. Additionally, the process of defining the problem is often
## iterative and takes a lot of thought and effort. We make the assumption here
## that this work has already been done by the modeler.
##
## In reality, the majority of a modeler's time is spent on problem definition
## and data cleaning/wrangling/munging. Our speed at going through these steps
## to demonstrate the use of H2O-3 in no way minimizes the importance of careful
## and thoughtful data preparation for model building. 

#################################################################################
###
### Step 3 (of 10). Clean data
###
#################################################################################

## Part 1. Defining the problem and creating the response variable
##
## The total number of loans in our data is

num_unfiltered_loans = nrow(loans)
num_unfiltered_loans

## Because we are interested in loan default, we need to look at the loan_status
## column. 

head(h2o.table(loans$loan_status), 20)

## Like many real data sources, loan_status is messy and contains multiple
## (somewhat overlapping) categories. Before modeling, we will need to clean
## this up by (1) removing loans that are still ongoing, and (2) simplifying the
## response column. 

## (1) Filter Loans
## In order to build a valid model, we have to remove loans that are not yet
## completely "good" or "bad". These ongoing loans have loan_status like
## "Current" and "In Grace Period". 

ongoing_status = c("Current", 
                   "In Grace Period", 
                   "Late (16-30 days)",
                   "Late (31-120 days)",
                   "Does not meet the credit policy.  Status:Current",
                   "Does not meet the credit policy.  Status:In Grace Period")
loans = loans[!loans$loan_status %in% ongoing_status, ]

## After filtering out ongoing loans, we now have

num_filtered_loans = nrow(loans)
num_filtered_loans

## loans whose final state is known, which means we filtered out 

num_loans_filtered_out = num_unfiltered_loans - num_filtered_loans
num_loans_filtered_out

## loans.
##
## These loans are now summarized by loan_status as

head(h2o.table(loans$loan_status), 20)

## (2) Create Response Column
## Let's name our response column bad_loan, which will be equal to one if the
## loan was not completely paid off. 

fully_paid = c("Fully Paid",
               "Does not meet the credit policy.  Status:Fully Paid"
               )
loans$bad_loan = !(loans$loan_status %in% fully_paid)

## Make the bad_loan column a factor so we can build a classification model, 

loans$bad_loan = as.factor(loans$bad_loan) 

## The percentage of bad loans is given by

bad_loan_dist = h2o.table(loans$bad_loan)
bad_loan_dist$Percentage = h2o.round(100 * bad_loan_dist$Count / nrow(loans))
bad_loan_dist

## Part 2. Convert strings to numeric
## Consider the data columns int_rate, revol_util, and emp_length:

head(loans[c("int_rate", "revol_util", "emp_length")], 10)

## Both int_rate and revol_util are inherently numeric but entered as
## percentages. Since they include a "%" sign, they are read in as strings. The
## solution for both of these columns is simple: strip the "%" sign and convert
## the strings to numeric. 
##
## The emp_length column is only slightly more complex. Besides removing the
## "year" or "years" word, we have to deal with "< 1" and "10+", which aren't
## directly numeric. If we define "< 1" as 0 and "10+" as 10, then emp_length
## can also be cast as numeric.
##
## We demonstrate the steps for converting these string variables into numeric
## values below. 

## Convert int_rate

loans$int_rate = h2o.gsub(pattern = "%", replacement = "", x = loans$int_rate) # strip %
loans$int_rate = h2o.trim(loans$int_rate) # trim whitespace
loans$int_rate = as.numeric(loans$int_rate) # change to numeric

## Convert revol_util

loans$revol_util = h2o.gsub(pattern = "%", replacement = "", x = loans$revol_util) # strip %
loans$revol_util = h2o.trim(loans$revol_util) # trim whitespace
loans$revol_util = as.numeric(loans$revol_util) # change to numeric 

## Convert emp_length

# Use gsub to remove " year" and " years"; also translate n/a to "" 
loans$emp_length = h2o.gsub(pattern = "([ ]*+[a-zA-Z].*)|(n/a)", replacement = "",
                            x = loans$emp_length) 
loans$emp_length = h2o.trim(loans$emp_length) # trim whitespace

loans$emp_length = h2o.gsub(pattern = "< 1", replacement = "0", x = loans$emp_length)
loans$emp_length = h2o.gsub(pattern = "10\\\\+", replacement = "10", x = loans$emp_length)
loans$emp_length = as.numeric(loans$emp_length)

## The converted results for the three former string variables are

head(loans[c("int_rate", "revol_util", "emp_length")], 10)

## Note: Interest rate distributions
## Now that we have converted interest rate to numeric, we can use the hist
## function to compare the interest rate distributions for good and bad loans. 

########### FIX THESE PLOTS ###########

# Bad Loans
h2o.hist(loans[loans$bad_loan == "1", "int_rate"])
# Good Loans
h2o.hist(loans[loans$bad_loan == "0", "int_rate"])

#########################################

## As expected, the bad loan distribution contains a higher proportion of high
## interest rates than the distribution for good loans. Likewise, the good loan
## distribution contains a higher proportion of low interest rates than that for
## bad loans. It is a truism to say that interest rate should be a good
## predictor of default. 
##
## Financial institutions typically determine a loan's interest rate based
## largely on risk and customer demand. If the underwriting rules are any good
## at all, then we would expect that interest rate would be a strong predictor
## of default. In fact, we should be surprised if int_rate is not one of the top
## two or three variables in our model regardless of algorithm.

## Part 3. Clean up messy categorical columns
##
## Much as we did with the loan_status column to create our response variable,
## the verification_status column needs cleaning

head(loans["verification_status"], 10)

## Note that there are multiple values that mean verified: "VERIFIED - income"
## and "VERIFIED - income source". We will replace these values with "verified",

loans$verification_status = h2o.sub(pattern = "VERIFIED - income source",
                                    replacement = "verified",
                                    x = loans$verification_status)
loans$verification_status = h2o.sub(pattern="VERIFIED - income",
                                    replacement="verified",
                                    x = loans$verification_status)
loans$verification_status = as.factor(loans$verification_status)

## resulting in

h2o.table(loans$verification_status)

#################################################################################
###
### Step 4 (of 10). Feature engineering
###
#################################################################################

## Now that we have cleaned our data, we can extract information from our
## current columns to create new features. This process is referred to as
## feature engineering. The general idea is to express information found in our
## data in a manner that is most understandable to the algorithms we employ,
## with the goal of improving the performance of our supervised learning
## models. 
##
## Feature engineering can be considered the "secret sauce" in building a
## superior predictive model: it is often (although not always) more important
## than the choice of machine learning algorithm. A very good summary of feature
## engineering recipes can be found in the online Driverless AI Documentation
## http://docs.h2o.ai/driverless-ai/latest-stable/docs/userguide/transformations.html.  
##
## We will do some basic feature engineering using the date fields in our data,
## and then use NLP (natural language processing) to create word embedding
## features from the loan description text field in our data. 
##
## The new columns we will create are:
##
## credit_length: the number of years someone has had a credit history
## issue_d_year and issue_d_month: the year and month from the loan issue date
## word embeddings from the loan description

## Credit Length
##
## We can extract the credit length by subtracting the year of their earliest
## credit line from the year they were issued the loan. 

loans$credit_length = h2o.year(loans$issue_d) - h2o.year(loans$earliest_cr_line)
head(loans$credit_length, 10)

## Issue Date Expansion
##
## We next extract the year and month from the issue date. We may find that the
## month or the year when the loan was issued will impact the probability of a
## bad loan. We will treat issue_d_month as a factor, since months are cyclical. 

loans$issue_d_year = h2o.year(loans$issue_d)
loans$issue_d_month = as.factor(h2o.month(loans$issue_d))

head(loans[c("issue_d_year", "issue_d_month")], 10)

## Word Embeddings
## 
## One of the columns in our dataset is a user-provided description of why the
## loan was requested. The first few descriptions in the dataset are shown
## below.

head(loans$desc)

## The descriptions above may contain information that would assist in
## predicting default, but supervised learning algorithms in general have a hard
## time understanding text. We need to convert these strings into a numeric
## representation of the text in order for our algorithms to utilize it. There
## are multiple choices for doing so, in this example we will use the Word2Vec
## algorithm. 
##
## We start by defining stop words (terms that are considered too frequent to
## carry much information) 

STOP_WORDS = c("ax","i","you","edu","s","t","m","subject","can","lines","re","what",
               "there","all","we","one","the","a","an","of","or","in","for","by","on",
               "but","is","in","a","not","with","as","was","if","they","are","this","and","it","have",
               "from","at","my","be","by","not","that","to","from","com","org","like","likes","so")

## We next tokenize the descriptions by breaking the text into individual words

tokenize = function(sentences, stop_word = STOP_WORDS) {
  tokenized = h2o.tokenize(sentences, "\\\\W+")
  tokenized_lower = h2o.tolower(tokenized)
  tokenized_filtered = tokenized_lower[(h2o.nchar(tokenized_lower) >= 2) | is.na(tokenized_lower), ]
  tokenized_words = tokenized_filtered[h2o.grep("[0-9]", tokenized_filtered, invert=T, output.logical=T), ]
  tokenized_words = tokenized_words[is.na(tokenized_words) | !(tokenized_words %in% STOP_WORDS), ]
  return(tokenized_words)
}

words = tokenize(h2o.ascharacter(loans$desc))

## We next train our Word2Vec model on the words extracted from our
## descriptions. We choose an output vector size of 100. 

## Aside: What does Word2Vec do? At a high level, it is a dimensionality
## reduction method for numerical representations of text. But it reduces
## dimensionality while preserving (and discovering?) relationships between
## words in the text.
##
## Suppose we were to create a dictionary of all the words in our descriptions,
## and suppose that dictionary contained 2500 unique words. At one extreme, we
## could create an indicator variable for each word (i.e., one-hot
## encoding). This would yield 2500 new features that would likely lead to
## massive overfitting of models.
##
## At the other extreme, suppose we had someone classify those words into
## different groups and create indicator variables for each: e.g., risky_words
## ("bankruptcy", "default", "forfeit", "lien", etc.), angry_words (profanity,
## "complaint", etc.), and so on. This reduces dimensionality by manually
## grouping words, but it is extremely labor intensive.
##
## Word2Vec starts with the entire dictionary size K as inputs and the selected
## vector size k as the target number of outputs. In the in-between layer(s) of
## the Word2Vec neural net, a k-dimensional numeric representation of each word
## is derived. 

w2v_model = h2o.word2vec(training_frame = words, vec_size = 100, model_id = 'w2v')

## Sanity check the Word2Vec model by finding synonyms for the word "car"
                                        
h2o.findSynonyms(w2v_model, "car", count = 5)

## Next calculate a vector for each description by averaging over all of the
## words in that description

desc_vecs = h2o.transform(w2v_model, words, aggregate_method = "AVERAGE")
head(desc_vecs)

## Add the aggregated word embeddings from the Word2Vec model to the loans data 

loans = h2o.cbind(loans, desc_vecs)

#################################################################################
###
### Step 5 (of 10). Model training 
###
#################################################################################

## Now that we have cleaned our data and added new columns, we will train a
## model to predict bad loans. First split our data into train and test.

frames = h2o.splitFrame(loans, ratios = .75, seed = 25)
train = frames[[1]]
test = frames[[2]]

cols_to_remove = c("initial_list_status",
                   "out_prncp",
                   "out_prncp_inv",
                   "total_pymnt",
                   "total_pymnt_inv",
                   "total_rec_prncp", 
                   "total_rec_int",
                   "total_rec_late_fee",
                   "recoveries",
                   "collection_recovery_fee",
                   "last_pymnt_d", 
                   "last_pymnt_amnt",
                   "next_pymnt_d",
                   "last_credit_pull_d",
                   "collections_12_mths_ex_med" , 
                   "mths_since_last_major_derog",
                   "policy_code",
                   "loan_status",
                   "funded_amnt",
                   "funded_amnt_inv",
                   "mths_since_last_delinq",
                   "mths_since_last_record",
                   "id",
                   "member_id",
                   "desc",
                   "zip_code")

## Next create a list of predictors as a subset of the columns of the loans H2O
## Frame

predictors = setdiff(colnames(loans), cols_to_remove)
predictors

## Now create an XGBoost model for predicting loan default. This model is being
## run with almost all of the values at their defaults. Later we may want to
## optimize the hyperparameters using a grid search.

xgboost_model = h2o.xgboost(x = predictors, 
                            y = "bad_loan",
                            training_frame = train,
                            validation_frame = test,
                            ntrees = 20,
                            model_id = "xgboost",
                            nfolds = 5
                            )

#################################################################################
###
### Step 6 (of 10). Examine model accuracy
###
#################################################################################

## The plot below shows the performance of the model as more trees are
## built. This graph can help us see at what point our model begins
## overfitting. Our test data error rate stops improving at around 8-10 trees. 

# plot(xgboost_model) # Plotting in R not available for xgboost models

## The ROC curve of the training and testing data are shown below. The area
## under the ROC curve is much higher for the training data than the test data,
## indicating that the model may be beginning to memorize the training data. 

print(paste("AUC for training data:",
            h2o.auc(h2o.performance(xgboost_model, train = TRUE))))
plot(h2o.performance(xgboost_model, train = TRUE), main = 'Training Data')

print(paste("AUC for x-val data:",
            h2o.auc(h2o.performance(xgboost_model, xval = TRUE))))
plot(h2o.performance(xgboost_model, xval = TRUE), main = 'Cross-validation')

print(paste("AUC for test data:",
            h2o.auc(h2o.performance(xgboost_model, valid = TRUE))))
plot(h2o.performance(xgboost_model, valid = TRUE), main = 'Test Data')


#################################################################################
###
### Step 7 (of 10). Interpret model
###
#################################################################################

## The variable importance plot shows us which variables are most important to
## predicting bad_loan. We can use partial dependency plots to learn more about
## how these variables affect the prediction. 

h2o.varimp_plot(xgboost_model, 20)

## As suspected, interest rate appears to be the most important feature in
## predicting loan default. The partial dependency plot of the int_rate
## predictor shows us that as the interest rate increases, the likelihood of the
## loan defaulting also increases. 

pdp = h2o.partialPlot(xgboost_model, cols = "int_rate", data = train)

#################################################################################
###
### Step 8 (of 10). Save and reuse model
###
#################################################################################

## The model can either be embedded into a self-contained Java MOJO package or
## it can be saved and later loaded directly into an H2O-3 cluster. For
## production use, we recommend using MOJO as it is optimized for speed. See the
## guide http://docs.h2o.ai/h2o/latest-stable/h2o-docs/productionizing.html for
## further information.  

## Downloading MOJO

h2o.download_mojo(xgboost_model)

## Save and reuse the model
##
## We can save the model to disk for later use.

model_path = h2o.saveModel(xgboost_model, path = '.' , force=T)
print(model_path)

## At a later date, we can load the model for batch scoring in the H2O cluster. 

loaded_model = h2o.loadModel(path=model_path)

## We can also score new data using the predict function:

bad_loan_hat = predict(xgboost_model, test)
head(bad_loan_hat, 15)

#################################################################################
###
### Step 9 (of 10). AutoML (optional) 
###
#################################################################################

## AutoML can be used for automating the machine learning workflow, which
## includes automatic training and tuning of many models within a user-specified
## time-limit or user specified model build limit. 
##
## Stacked Ensembles will be automatically trained on collections of individual
## models to produce highly predictive ensemble models. 

# AutoML can be used for automating the machine learning workflow, which 
# includes automatic training and tuning of many models within a user-specified 
# time-limit. Stacked Ensembles will be automatically trained on collections of 
# individual models to produce highly predictive ensemble models.

aml = h2o.automl(x=predictors, 
                 y='bad_loan', 
                 training_frame=train,
                 max_models=5,
                 max_runtime_secs_per_model=60,
                 seed = 25)

## While the AutoML job is running, this is a good time to open H2O Flow and
## monitor the model building process. 
##
## Once complete, the leaderboard contains the performance metrics of the models
## generated by AutoML: 

aml@leaderboard

## Since we provided only the training H2O Frame during training, the models are
## sorted by their cross-validated performance metrics (AUC by default for
## classification). We can evaluate the best model (leader) on the test data: 

perf = h2o.performance(aml@leader, newdata = test)
plot(perf)
print(h2o.auc(perf))
print(perf)

## Another convenient use of H2O Flow is to explore the various models built by
## AutoML. 


#################################################################################
###
### Step 10 (of 10). Shutdown H2O cluster
###
#################################################################################

h2o.shutdown(prompt = FALSE)

### Bonus: H2O-3 documentation
### - http://docs.h2o.ai/
