%% Credit Rating
%
% One of the fundamental tasks in credit risk management is to assign a
% credit grade to a borrower. Grades are used to rank customers according
% to their perceived creditworthiness: better grades mean less risky
% customers; similar grades mean similar level of risk. Grades come in two
% categories: credit ratings and credit scores. Credit ratings are a small
% number of discrete classes, usually labeled with letters, such as 'AAA',
% 'BB-', etc. Credit scores are numeric grades such as '640' or '720'.
% Credit grades are one of the key elements in regulatory frameworks, such
% as Basel II.
%
% Assigning a credit grade involves analyzing information on the borrower.
% If the borrower is an individual, information of interest could be the
% individual's income, outstanding debt (mortgage, credit cards), household
% size, possibly zip code, etc. For corporate borrowers, one may consider
% certain financial ratios (e.g., sales divided by total assets), industry,
% etc. Here, we refer to these pieces of information about a borrower as
% _features_ or _predictors_. Different institutions use different
% predictors, and they may also have different rating classes or score
% ranges to rank their customers. For relatively small loans offered to a
% large market of potential borrowers (e.g., credit cards), it is common to
% use credit scores, and the proces of grading a borrower is usually
% automated. For larger loans, accessible to small- to medium-sized
% companies and larger corporations, credit ratings are usually used, and
% the grading process may involve a combination of automated algorithms and
% expert analysis.
%
% There are rating agencies that keep track of the creditworthiness of
% companies. Yet, most banks develop an internal methodology to assign
% credit grades for their customers. Rating a customer internally can be a
% necesity if the customer has not been rated by a rating agency, but even
% if a third-party rating exists, an internal rating offers a complementary
% assessment of a customer's risk profile.
%
% This demo shows how MATLAB can help with the automated stage of a
% credit rating process. In particular, we take advantage of one of the
% statistical learning tools readily available in the Statistics
% Toolbox, a _tree bagger_.
%
% Implementing credit rating policies and procedures from scratch is a
% complex endeavor, beyond the scope of this demo. One needs to determine
% what features or predictors to use (financial ratios, industry sector,
% geographical location, etc.), how these features will impact the credit
% rating of a particular borrower, and even how many rating categories to
% use. Many challenges that may arise in the process are specific to each
% particular institution or portfolio.
%
% Here we assume that historical information is available in the form of a
% data set where each record contains the features of a borrower and the
% credit rating that was assigned to it. These may be internal ratings,
% assigned by a committee that followed policies and procedures already in
% place. Alternatively, the ratings may come from a rating agency, whose
% ratings are being used to "jump start" a new internal credit rating
% system, in the sense that the initial internal ratings are expected to
% closely agree with the third-party ratings while the internal policies
% and procedures are assimilated and fine tuned.
%
% The existing historical data is the starting point of this demo, and it
% is used to _train_ an automated classifier; in the vocabulary of
% statistical learning, this process falls in the category of _supervised
% learning_. The classifier is then used to assign ratings to new
% customers. In practice, these automated or _predicted_ ratings would most
% likely be regarded as tentative, until a credit committee of experts
% reviews them. The type of classifier we use in this demo can also
% facilitate the revision of these ratings, because it provides a measure
% of certainty, a _classification score_, for the predicted ratings.

%% 1. Loading the existing credit rating data
%
% We load the historical data from the database
% |HistoricalCreditRatings.accdb|. This is a fictitious data set; it was
% randomly generated with certain criteria that tried to ensure consistency
% between the features and the corresponding ratings.
%
% The data set contains financial ratios, industry sector, and credit  
% ratings for list of corporate customers. The first column is a customer
% ID. Then we have five columns of financial ratios (these are the same
% ratios used in Altman's z-score):
%
% * Working capital / Total Assets (WC_TA)
%
% * Retained Earnings / Total Assets (RE_TA)
%
% * Earnings Before Interests and Taxes / Total Assets (EBIT_TA)
%
% * Market Value of Equity / Book Value of Total Debt (MVE_BVTD)
%
% * Sales / Total Assets (S_TA)
%
% Next, we have an industry sector label, an integer value ranging from 1
% to 12. The last column has the credit rating assigned to the customer. We
% load the data into a MATLAB structure.

getdbdata

%%
% We copy the features into a matrix |X|, and the corresponding classes,
% the ratings, into a vector |Y|. This is not a required step, since we
% could access this information directly from the structure, but we do it
% here to simplify some repeated function calls below.
%
% The features to be stored in the matrix |X| are the five financial
% ratios and the industry label. Note that the |Industry| is a categorical
% variable, _nominal_ in fact, because there is no ordering in the industry
% sectors. The response variable, the credit ratings, is also categorical,
% though this is an _ordinal_ variable, because, by definition, ratings
% imply a _ranking_ of creditworthiness. We can use this variable "as is"
% to train our classifier, but it is convenient to copy it into an _ordinal
% array_, so that the classifier knows that these labels have an implicit
% ordering. The ordering of the ratings is established by the cell array we
% pass as a third argument in the definition of |Y|.

X = [historicalData.WC_TA, ... 
     historicalData.RE_TA, ...
     historicalData.EBIT_TA, ... 
     historicalData.MVE_BVTD, ...
     historicalData.S_TA, ...
     historicalData.Industry];
Y = ordinal(historicalData.Rating,[],{'AAA' 'AA' 'A' 'BBB' 'BB' 'B' 'CCC'});

%%
% We will also create a numerical equivalent of |Y| (where AAA = 1, AA = 2,
% etc.) for the benefit of some of the simpler regression functions.
Y_num = double(Y);

%% 2. Ad hoc data analysis: a linear regression
%
% MATLAB excels at data analysis, so it will be easy to explore multiple
% modeling approaches for this problem.  The first we will try is a linear
% regression.  This already poses a number of challenges:
%
%  1. Linear regressions map numbers onto other numbers.  Neither our bond
%  rating outputs nor our industry inputs fit this description.  As a first
%  attempt, we will simply map the bond ratings onto integers (AAA = 1, AA
%  = 2, etc.) and keep the numeric representation of our industries as they
%  are.
%
%  2. Linear regressions perform regressions onto continuous outputs, while
%  we need a mapping onto the integers 1 through 7.  We will work around
%  this issue by rounding all of our regressed outputs to the nearest
%  integer, with all outputs less than 1 rounded to 1 and all outputs
%  greater than 7 rounded to 7.
%
%  3. There is no reason to believe that this problem is linear.
%
% The final concern will prove to be this approach's undoing, regardless of
% how we choose to address items 1 and 2.  Even so, this exercise will show
% us how to perform an ad hoc analysis as well as how to evaluate its
% performance.

%%
% First, we will use the Statistics Toolbox's |regress| function to perform
% a linear regression of the predictor |X| onto the numerical response
% |Y_num|.  The output is simply the best-fitting linear coefficients:
coeff = regress(Y_num, X);

%%
% A necessary condition on any classifier is that is do a "respectable" job
% classifying the very data with which it was trained.  True, there are
% always concerns of overfitting to the training data, but if it cannot
% correctly classify its training set, then there is little reason to
% believe that it will perform well on new data, either.  Let's check.
Y_lr = X*coeff;

%%
% We will perform the categorical rounding according to item 2 above using
% MATLAB's logical indexing:
Y_lr = round(Y_lr);
Y_lr(Y_lr < 1) = 1;
Y_lr(Y_lr > 7) = 7;

%%
% Finally, we can do an element-by-element comparison of the actual outputs
% |Y_num| to the linear regression's predicted outputs |Y_lr|.  Ideally,
% they would be identical.  A confusion matrix is a convenient way to
% summarize such a comparison: each row corresponds to a level of the
% actual outputs (row 1 is AAA, row 2 is AA, etc.), while each column
% counts how the same outputs were predicted by the model (column 1 is AAA,
% etc.)  A perfect result would be nonzero counts occurring only on the
% main diagonal of the confusion matrix.  The linear regression's result is
% far from perfect:
C_lr = confusionmat(Y_num, Y_lr);

%%
% We could try a number of variations on this linear regression approach
% (different scales for the bond ratings and industries, introducing
% constant and/or interaction terms, etc.), but the root problem is that
% there is no reason to assume a linear, or a quadratic, or any other type
% of parametric model for this data.  We will next explore another option:
% a non-parametric classifier known as a _tree bagger_.

%% 3. The Tree Bagger
% We use the predictors |X| and the response |Y| to fit a particular type
% of classification ensemble called _tree bagger_. "Bagging," in this
% context, stands for "bootstrap aggregation." The methodology consists in
% generating a number of sub-samples, or _bootstrap replicas_, from the
% data set. These sub-samples are randomly generated, sampling with
% replacement from the list of customers in the data set. For each replica,
% a decision tree is grown. Each decision tree is a trained classifier on
% its own, and could be used in isolation to classify new customers. The
% predictions of two trees grown from two different bootstrap replicas may
% be different, though. What the tree bagger does is to _aggregate_ the 
% predictions of all the decision trees that are grown for all the
% bootstrap replicas. If the majority of the trees predict one particular
% class for a new customer, it is reasonable to consider that prediction to
% be more robust than the prediction of any single tree alone. Moreover, if
% a different class is predicted by a smaller set of trees, that
% information is useful, too. In fact, the proportion of trees that predict
% different classes is the base for the _classification scores_ that are
% reported by a tree bagger when classifying new data.

%% 3a. Constructing the tree bagger
%
% The first step to construct our classification ensemble is to find a good
% leaf size for the individual trees; here we try sizes of 1, 5 and 10. We
% start with a small number of trees, 25 only, because we mostly want to
% compare the initial trend in the classification error for different leaf
% sizes. (We recommend to look at the |TreeBagger| documentation and
% related demos to learn more about this tool.) For reproducibility and
% fair comparisons, we control the seed of the random number generator that
% is used to sample with replacement to build the classifier.

% TODO: Although I like the feature importance section next, I question
% whether this cell is necessary to our seminar.
leaf = [1 5 10];
nTrees = 25;
mySeed = 9876;

color = 'bgr';
figure(1);
for ii = 1:length(leaf)
   % This is to set the seed for the random number generator, so that the
   % random samples are the same for each leaf size
   s = RandStream('mt19937ar','seed',mySeed);
   RandStream.setDefaultStream(s);
   % Create a tree bagger object for each leaf size and plot out-of-bag
   % error 'oobError'
   b = TreeBagger(nTrees,X,Y,'oobpred','on','cat',6,'minleaf',leaf(ii));
   plot(b.oobError,color(ii));
   hold on;
end
xlabel('Number of grown trees');
ylabel('Out-of-bag classification error');
legend({'1', '5', '10'},'Location','NorthEast');
title('Classification Error for Different Leaf Sizes');
hold off;

clear ii color

%%
% The errors are comparable for the three leaf-size options. We will
% therefore work with a leaf size of 10, because it results in leaner trees
% and more efficient computations.
%
% Note that we did not have to split the data into _training_ and _test_
% subsets. This is done internally, it is implicit in the sampling
% procedure that underlies the method. At each bootstrap iteration, the
% bootstrap replica is the training set, and any customers left out
% ("out-of-bag") are used as test points to estimate the out-of-bag
% classification error reported above.
%
% Next, we want to find out whether all the features are important for the
% accuracy of our classifier. We do this by turning on the _feature
% importance_ measure (|oobvarimp|), and plot the results to visually find
% the most important features. We also try a larger number of trees now,
% and store the classification error, for further comparisons below.

nTrees = 50;
leaf = 10;
s = RandStream('mt19937ar','seed',mySeed);
RandStream.setDefaultStream(s);
b = TreeBagger(nTrees,X,Y,'oobvarimp','on','cat',6,'minleaf',leaf);

figure(2);
bar(b.OOBPermutedVarDeltaError);
xlabel('Feature number');
ylabel('Out-of-bag feature importance');
title('Feature importance results');

oobErrorFullX = b.oobError;

%%
% Features 2, 4 and 6 stand out from the rest. Feature 4, market value of
% equity / book value of total debt (|MVE_BVTD|), is the most important
% predictor for this data set. Note that this ratio is closely related to
% the predictors of creditworthiness in structural models, such as Merton's
% model, where the value of the firm's equity is compared to its
% outstanding debt to determine the default probability.
%
% Information on the industry sector, feature 6 (|Industry|), is also
% relatively more important than other variables to assess the
% creditworthiness of a firm for this data set.
%
% Although not as important as |MVE_BVTD|, feature 2, retained earnings /
% total assets (|RE_TA|), stands out from the rest. There is a correlation
% between retained earnings and the age of a firm (the longer a firm has
% existed, the more earnings it can accumulate, in general), and in turn
% the age of a firm is correlated to its creditworthiness (older firms tend
% to be more likely to survive in tough times). 
%
% Let us fit a new classification ensemble using as predictors only
% |RE_TA|, |MVE_BVTD|, and |Industry|. We compare its classification error
% with the previous classifier, which uses all features.

X = [historicalData.RE_TA, ...
     historicalData.MVE_BVTD, ...
     historicalData.Industry];

s = RandStream('mt19937ar','seed',mySeed);
RandStream.setDefaultStream(s);
b = TreeBagger(nTrees,X,Y,'oobpred','on','cat',3,'minleaf',leaf);

oobErrorX246 = b.oobError;

figure(3);
plot(oobErrorFullX,'b');
hold on;
plot(oobErrorX246,'r');
xlabel('Number of grown trees');
ylabel('Out-of-bag classification error');
legend({'All features', 'Features 2, 4, 6'},'Location','NorthEast');
title('Classification Error for Different Sets of Predictors');
hold off;

%%
% The accuracy of the classification does not deteriorate significantly
% when we remove the features with relatively low importance (1, 3, and 5),
% so we will use the more parsimonious classification ensemble for our
% predictions.
%
% We can store the classifier for future use. For efficiency, one can store
% a compact version of it, which is more than enough to re-load it and
% classify new customers later on.

b = b.compact;
save CreditRatingClassifier.mat b;

clear s oobErrorFullX oobErrorX246 nTrees mySeed leaf

%% 3b. Is this an improvement?
%
% A thorough examination of the validity of this model can be performed via
% back-testing and is presented as an appendix below.  Here, we will
% quickly ask if this model is an improvement over our linear regression by
% performing the same confusion analysis.  Again, a confusion analysis on
% the training set is (in general) not sufficient to test a predictive
% model's validity due to concerns like overfitting, but it is a first step
% towards convincing ourselves that the model performs well.
%
% First, we use the TreeBagger to predict outputs for our training data and
% convert them to an ordinal array for direct comparison against the
% original Y.
Y_tb = predict(b, X);
Y_tb = ordinal(Y_tb,[],{'AAA' 'AA' 'A' 'BBB' 'BB' 'B' 'CCC'});

%%
% Then, we compare these predicted outputs to their actual values.
C_tb = confusionmat(Y, Y_tb);

%%
% This provides a much better result than the linear regression analysis.

%% 3c. Classifying new data
%
% Here we use the previously constructed classification ensemble to assign
% credit ratings to new customers. Note that the ratings of existing
% customers also need to be reviewed on a regular basis, especially when
% their financial information has substantially changed, so the data set
% could also contain a list of existing customers under review.
%
% We completely cleaned up the workspace at the end of the previous
% section, so the steps below could be followed after starting a brand new
% session of MATLAB as long as the following files are present:
%
% * The |*.mat| file that contains the classification ensemble; and
%
% * The data file that contains the financial ratios for the customers that
% need to be classified (or re-classified).
%
% We start by loading the classifier and the new data.  The |loadNewData|
% command is a version of the automatically-generated code from
% MATLAB's data importing wizard, modified to filter out the unneccessary
% predictor variables.
load CreditRatingClassifier;
[newData, IDs] = loadNewData('CreditPortfolio.xlsx');

%%
% To predit the credit rating for this new data, we call the |predict|
% method on the classifier. The method returns two arguments, the predicted
% class and the classification score. We certainly want to get both output
% arguments, since the classification scores contain information on how
% certain the predicted ratings seem to be.

[predClass,classifScore] = predict(b, newData);

%%
% At this point, we can create a report. Here we only display a small
% report for the first three customers on the screen, for illustration
% purposes, but a more detailed report could be written to a file as well.

for i = 1:3
   fprintf('Customer %d:\n',IDs(i));
   fprintf('   RE/TA    = %5.2f\n',newData(i,1));
   fprintf('   MVE/BVTD = %5.2f\n',newData(i,2));
   fprintf('   Industry = %2d\n',newData(i,3));
   fprintf('   Predicted Rating : %s\n',predClass{i});
   fprintf('   Classification score : \n');
   for j = 1:length(b.ClassNames)
      if (classifScore(i,j)>0)
         fprintf('      %s : %5.4f \n',b.ClassNames{j},classifScore(i,j));
      end
   end
end

%%
% Besides creating a report, we could just as easily save a copy of the
% predicted ratings and corresponding scores.  This would be useful for
% periodic assessments of the quality of the classifier. 

%% 4. Final remarks
%
% Though we used a tree bagger here to construct a classifier, note that
% MATLAB offers a range of machine learning tools. The Statistics Toolbox
% has statistical learning tools such as discriminant analysis, and naive
% Bayes classifiers. There is also a full Neural Networks Toolbox. This
% demo focused on a particular workflow, but MATLAB offers you great
% flexibility to adapt this workflow to your own preferences and needs.
%
% Similar tools can be used for credit scoring, instead of credit rating.
% The workflow would present some changes in that context. An important
% difference, for example, is that only two classes are used to train a
% classifier in credit scoring analyses, default and not-default. Another
% difference is that probabilities of default can be inferred directly from
% the classification process.
%
% Note that no probabilities of default have been computed in this demo.
% For credit ratings, the probabilities of default are usually computed
% based on historical information of credit ratings migrations; see the
% "Estimating Transition Probabilities" demo for more details.

%% Appendix: Back-testing: Profiling the classification process
%
% We are interested here in two different _back-testing_ analyses:
%
% * How accurate the predicted ratings that we obtain from the automated
% classification process are, as compared to the actual ratings assigned by
% a credit committee that takes into consideration the predicted ratings,
% the classification scores, and, of course, other information; and
%
% * How good the actual ratings are in ranking the customers according to
% their creditworthiness, in an _ex-post_ analysis perfomed, say, one year
% later, when its known which companies defaulted during the year.
%
% The file |ExPostData.dat| contains information on the actual
% ratings that the companies were assigned and a "default flag," where 1
% means that the company defaulted whithin one year of the rating process.

exPostDS = dataset('file','ExPostData.dat','delimiter',',');

%%
% *Comparing predicted ratings vs. actual ratings.* The rationale to train
% an automated classifier is to expedite the work of the credit committee.
% The more accurate the predicted ratings are, the less time the committee
% has to spend reviewing the predicted ratings. So it is conceivable that
% the committee wants to have regular checks on how closely the predicted
% ratings match the final ratings they assign, and to recommend re-training
% the automated classifier (and maybe include new features, for example) if
% the mismatch seems concerning.
%
% The first tool we can use to compare predicted vs. actual ratings is the
% confusion matrix:

C_ep = confusionmat(exPostDS.Rating,predClass,...
   'order',{'AAA' 'AA' 'A' 'BBB' 'BB' 'B' 'CCC'});

%%
% The rows in |C_ep| correspond to the predicted ratings, and the columns
% to the actual ratings. The amount in the position |(i,j)| in this matrix
% indicates how many customers were predicted as rating |i| and received an
% actual rating |j|. For example, position |(2,3)| tells us how many
% customers were predicted as 'AA' with the automated classifier, but
% received a rating of 'A' by the credit committee. One can also present
% this matrix in percentage form with a simple transformation:

C_perc = diag(sum(C_ep,2))\C_ep;

%%
% Good agreement between the predicted and the actual ratings would result
% in values in the main diagonal that dominate the rest of the values in a
% row, ideally values close to 1. In this case, we actually see an
% important disagreement for 'B,' since about half of the customers that
% were predicted as 'B' ended up with a rating of 'BB.' On the other hand,
% it is good to see that ratings differ in at most one notch in most cases,
% with the only exception of 'BBB.'
%
% Note that a confusion matrix could also be used to compare the internal
% ratings assigned by the institution against third-party ratings; this is
% often done in practice.
%
% For each specific rating, we can compute yet another measure of agreement
% between predicted and actual ratings. We can build a _Receiver Operating
% Characteristic (ROC) curve_ using the |perfcurve| function from the
% Statistics Toolbox, and check the _area under the curve (AUC)_. Let
% us do this for rating 'BBB.'
%
% The |perfcurve| function takes as an argument the actual ratings, and the
% _scores_ for 'BBB' that were determined by the automated process. In
% order to build the ROC curve, one varies the _threshold_ used to classify
% a customer as 'BBB;' if the threshold is |t|, we only classify customers
% as 'BBB' if their 'BBB' score is greater than or equal to |t|. As an
% example, suppose that company _XYZ_ had a 'BBB' score of 0.87. If the 
% actual rating of _XYZ_ (the information in |exPostDS.Rating|) is 'BBB,'
% then _XYZ_ would be correctly classified as 'BBB' for thresholds of up to
% 0.87, and it would be a _true positive_ (increasing the _sensitivity_ of
% the classifier). For larger thresholds, however, it would be a _false
% negative_. Now if, on the other hand, _XYZ_'s actual rating were 'BB,'
% then it would be correctly rejected as a 'BBB' for thresholds of more
% than 0.87, becoming a _true negative_ (increasing the _specificity_ of
% the classifier), but it would become a _false positive_ for smaller
% thresholds. The ROC curve is constructed by plotting the proportion of
% true positives (sensitivity), versus false positives (1-specificity), as
% the threshold varies from 0 to 1. The AUC is, literally, the area under
% the ROC curve; the closer the AUC is to 1, the more accurate the
% classifier (a perfect classifier would have an AUC of 1).
%
% Here is the ROC curve and AUC for rating 'BBB'.

[xVal,yVal,~,auc] = perfcurve(exPostDS.Rating,classifScore(:,4),'BBB');
plot(xVal,yVal);
xlabel('False positive rate');
ylabel('True positive rate');
text(0.5,0.25,strcat('AUC=',num2str(auc)),'EdgeColor','k');
title('ROC curve BBB, predicted vs. actual rating');

%%
% The AUC seems high enough, but it would be up to the committee to
% decide which level of AUC for the ratings should trigger a recommendation
% to update the automated classifier.

%%
% *Comparing actual ratings vs. defaults in the following year.* A common
% tool used to assess the ranking of customers implicit in the credit
% ratings is the _Cumulative Accuracy Profile (CAP)_, and the associated
% _accuracy ratio_ measure. The idea is to measure the relationship between
% the credit ratings assigned, and the number of defaults observed in the
% following year. One would expect that fewer defaults are observed for
% better rating classes. If the default rate were the same for all ratings,
% the rating system would be no different from a naive (and useless)
% classification system in which customers were randomly assigned a rating,
% independently of their creditworthiness.
%
% It is not hard to see that the |perfcurve| function can be used to
% construct the CAP. The class is not the rating, as before, but the
% default flag that we loaded from the |ExPost.dat| file. Moreover, we need
% to construct a "dummy score" to indicate the ranking in the ratings. The
% dummy score is like a "dummy probability that a customer will have a
% default flag of 1." A default probability could be used, of course, but
% we do not have them here, and in fact _we do not need to have estimates
% of the default probabilities to construct the CAP_, because all we are
% assessing is how well it _ranks_ the customers. The dummy score only
% needs to satisfy that better ratings get lower dummy scores, and that any
% two customers with the same rating get the same dummy score.
%
% The CAP is then the ROC that we obtain using the default flag and the
% dummy scores. Usually, one reports in the same plot the CAP of the
% "perfect rating system," in which the lowest rating includes all the
% defaulters, and no other customers. The area under this perfect curve is 
% the maximum possible AUC attainable by a rating system. By convention,
% the AUC is adjusted to subtract the area under the CAP of the "naive
% system," the one that randomly assigns ratings to customers, which is
% simply a straight line from the origin to (1,1), with an AUC of 0.5. The
% accuracy ratio for a rating system is defined as the ratio of the
% adjusted AUC (AUC of the system in consideration minus AUC of the naive
% system) to the maximum accuracy (AUC of the perfect system minus AUC of
% naive system).

ratingsList = {'AAA' 'AA' 'A' 'BBB' 'BB' 'B' 'CCC'};
Nratings = length(ratingsList);
dummyDelta = 1/(Nratings+1);
dummyRank = linspace(dummyDelta,1-dummyDelta,Nratings)';

D = exPostDS.Def_tplus1;
fracTotDef = sum(D)/length(D);
maxAcc = 0.5 - 0.5 * fracTotDef;

R = double(ordinal(exPostDS.Rating,[],ratingsList));
S = dummyRank(R);
[xVal,yVal,~,auc] = perfcurve(D,S,1);

accRatio = (auc-0.5)/maxAcc;
fprintf('Accuracy ratio for actual ratings: %5.3f\n',accRatio);

xPerfect(1) = 0; xPerfect(2) = fracTotDef; xPerfect(3) = 1;
yPerfect(1) = 0; yPerfect(2) = 1; yPerfect(3) = 1;
xNaive(1) = 0; xNaive(2) = 1;
yNaive(1) = 0; yNaive(2) = 1;

figure(4);
plot(xPerfect,yPerfect,'--k',xVal,yVal,'b',xNaive,yNaive,'-.k');
xlabel('Fraction of all companies');
ylabel('Fraction of defaulted companies');
title('Cumulative Accuracy Profile');
legend({'Perfect','Actual','Naive'},'Location','SouthEast');
hold on;

%%
% The key to read the information of the CAP is in the kinks. For example,
% the second kink is associated with the second lowest rating, 'B,' and in
% this case it is located at (0.097, 0.714); this means that 9.7% of the
% customers were ranked as 'B' _or lower_, and they account for 71.4% of
% the defaults observed in the past year.
%
% In practice, accuracy ratios of rating systems range between 50% and 90%.
% So the actual ratings seem to be doing a very good job in ranking the
% customers. Just to compare, we can add the CAP of the predicted ratings
% in the same plot, and compute its accuracy ratio.

Rpred = double(ordinal(predClass,[],ratingsList));
Spred = dummyRank(Rpred);
[xValPred,yValPred,~,aucPred] = perfcurve(D,Spred,1);

accRatioPred = (aucPred-0.5)/maxAcc;
fprintf('Accuracy ratio for predicted ratings: %5.3f\n',accRatioPred);

plot(xValPred,yValPred,':r');
legend({'Perfect','Actual','Naive','Predicted'},'Location','SouthEast');
hold off;

%%
% The accuracy ratio of the predicted rating is smaller, and its CAP is
% mostly below the CAP of the actual rating. This is reasonable, since the
% actual ratings are assigned by the credit committees that take into
% consideration the predicted ratings _and_ extra information that can be
% important to fine-tune the ratings.
