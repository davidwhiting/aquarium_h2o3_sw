

library(h2o)
h2o.init()

filename = "http://s3.amazonaws.com/h2o-public-test-data/smalldata/gbm_test/titanic.csv"
df <- h2o.importFile(path = filename)

df$survived <- as.factor(df$survived)
df$ticket <- as.factor(df$ticket)
# Set predictors and response variable
response <- "survived"
predictors <- colnames(df)[!(colnames(df) %in% c("survived", "name"))]

# Split the data for machine learning
splits <- h2o.splitFrame(
  data = df, 
  ratios = c(0.6,0.2),   ## only need to specify 2 fractions, the 3rd is implied
  destination_frames = c("train.hex", "valid.hex", "test.hex"), seed = 1234
)
train <- splits[[1]]
valid <- splits[[2]]
test  <- splits[[3]]

gbm_model <- h2o.glm(x = predictors, y = response, training_frame = train, validation_frame = valid,
                     family = "binomial", model_id = "glm_default.hex")

xgboost_model <- h2o.xgboost(x = predictors, y = response, training_frame = train, validation_frame = valid,
                             model_id = "glm_default.hex")

baseline_results <- data.frame('model' = c("GBM", "XGBoost"),
                               'training auc' = c(h2o.auc(gbm_model, train = T), h2o.auc(xgboost_model, train = T)),
                               'validation_auc' = c(h2o.auc(gbm_model, valid = T), h2o.auc(xgboost_model, valid = T)))
print(baseline_results)

## Looks like H2OXGBoost default gives us a better result.  Let's use gridsearch with early stopping on both models to see if we can improve their performance.

hyper_params = list( max_depth = seq(1, 25, 2))

grid <- h2o.grid(
  ## hyper parameters
  hyper_params = hyper_params,
  
  ## full Cartesian hyper-parameter search
  search_criteria = list(strategy = "Cartesian"),
  
  ## which algorithm to run
  algorithm="gbm",
  
  ## identifier for the grid, to later retrieve it
  grid_id="depth_grid",
  
  ## standard model parameters
  x = predictors, 
  y = response, 
  training_frame = train, 
  validation_frame = valid,
  
  ## more trees is better if the learning rate is small enough 
  ## here, use "more than enough" trees - we have early stopping
  ntrees = 5000,                                                            
  
  ## smaller learning rate is better
  ## since we have learning_rate_annealing, we can afford to start with a bigger learning rate
  learn_rate = 0.05,                                                         
  
  ## learning rate annealing: learning_rate shrinks by 1% after every tree 
  ## (use 1.00 to disable, but then lower the learning_rate)
  learn_rate_annealing = 0.99,                                               
  
  ## sample 80% of rows per tree
  sample_rate = 0.8,                                                       
  
  ## sample 80% of columns per split
  col_sample_rate = 0.8, 
  
  ## fix a random number generator seed for reproducibility
  #  seed = 1234,                                                             
  
  ## early stopping once the validation AUC doesn't improve by at least 0.01% for 5 consecutive scoring events
  stopping_rounds = 5,
  stopping_tolerance = 0.001,
  stopping_metric = "AUC", 
  
  ## score every 10 trees to make early stopping reproducible (it depends on the scoring interval)
  score_tree_interval = 10                                                
)

grid                                                                       

## sort the grid models by decreasing AUC
sorted_grid <- h2o.getGrid("depth_grid", sort_by="auc", decreasing = TRUE)    
sorted_grid@summary_table[c(1:5), ]

## find the range of max_depth for the top 5 models
topDepths = sorted_grid@summary_table$max_depth[1:5]                       
minDepth = min(as.numeric(topDepths))
maxDepth = max(as.numeric(topDepths))

