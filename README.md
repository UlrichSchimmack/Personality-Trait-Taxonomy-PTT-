# Personality-Trait-Taxonomy-PTT-
Developing Hierarchical SEM Models of Personality Traits


# Many Analysts, One Personality Dataset
### Testing Competing Theories of Personality Trait Structure

## Background and Aim

The Big Five have been the dominant framework for describing personality differences for several decades. Their robustness has been established in numerous exploratory factor analyses (EFA) using different instruments and populations.

However, the replication of five broad dimensions does not establish that five latent common factors provide the best explanation of the hierarchical structure of personality.

Alternative theories have been proposed, including:

The Big Five: Five broad personality dimensions without higher-order factors.

Stability and Plasticity: Two higher-order factors underlying the Big Five (Digman, 1997; DeYoung, 2006).

HEXACO: Six broad personality dimensions, including Honesty–Humility (Ashton & Lee).

Other theoretical models proposing different numbers or organizations of broad and narrow personality traits.

Traditionally, researchers have evaluated these theories using different instruments, datasets, and analytical methods. This makes it difficult to compare their empirical support directly.

The aim of this project is to evaluate competing structural theories of personality using the same comprehensive dataset.

Rather than asking whether researchers can recover their preferred factors, we ask whether competing theoretical models can provide equally good or better explanations of the same observed covariance structure.

Source of the Data

The data come from the FacetMAP project, developed by Paul Irwing, David Hughes, and colleagues.

FacetMAP was designed to provide a comprehensive taxonomy of narrower personality traits, extending beyond the facet structures of conventional Big Five inventories.

The dataset contains self-report ratings of a broad range of personality characteristics, with multiple items measuring each facet.

The present analysis uses 210 items to represent 70 latent personality facets.

Please cite the original FacetMAP publication when using these data:

Irwing et al. (2024). Towards a Taxonomy of Personality Facets. [Full bibliographic details to be added.]

Reference Model

The repository provides a hierarchical structural equation model estimated with Mplus.

The reference model includes:

70 latent personality facets, each measured by three items.

Five broad personality factors: Neuroticism, Extraversion, Openness, Agreeableness, and Conscientiousness.

Two item-level method factors representing evaluative response tendencies (HALO) and response-set variance (RSET).

Secondary factor loadings to account for facets associated with multiple broad factors.

Correlated residuals between facets to account for relationships not explained by the five broad factors.

The five global personality factors are specified as independent. This does not imply that facets belonging to different domains are unrelated; cross-domain relationships can be represented by secondary loadings and correlated residuals.

The model provides a reasonably good approximation to the observed covariance structure.

Reference-model fit:

Statistic

Value

Sample size

1,087

Chi-square

36,743.69

Degrees of freedom

21,351

CFI

.899

TLI

.896

RMSEA

.026

SRMR

.046

Free parameters

1,014

The model was developed through iterative inspection of parameter estimates and modification indices. It is therefore an empirically refined reference model, not an independently confirmed theory.

The Many-Analysts Challenge

We invite personality researchers and structural equation modeling experts to develop alternative models using the same data.

The challenge is to produce a model that fits the data as well as or better than the reference model and leads to a substantively different conclusion about the structure of personality.

Possible approaches include:

Testing whether Stability and Plasticity provide a more parsimonious explanation of relationships among the Big Five.

Testing whether HEXACO's six broad dimensions fit better than five global factors, including whether Honesty–Humility is a separate global dimension.

Identifying alternative intermediate-level factors or different relationships among narrower personality traits.

Proposing another theoretically meaningful hierarchical structure.

The objective is not merely to improve fit by adding parameters. Alternative models should offer a coherent theoretical interpretation and explain which empirical findings distinguish them from the reference model.

Researchers may modify the structural model while retaining the existing item-level measurement model. Changes to the measurement model are also possible but should be clearly documented.

Model Evaluation

Alternative models will be evaluated on several criteria:

Absolute fit: How accurately does the model reproduce the observed covariance structure?

Relative fit and parsimony: Does it fit as well as or better than the reference model, considering model complexity?

Theoretical interpretation: Does it imply a meaningfully different organization of personality traits?

Local fit: Are important relationships among facets left unexplained?

Replicability: Does the model reproduce its results in an independent dataset?

An important objective is to determine whether different theoretical models are empirically distinguishable.

Models with similar fit but different substantive interpretations would demonstrate that the same covariance structure can support multiple theories. Conversely, failure of theoretically specified alternatives to reproduce the data would strengthen the evidence for the reference model.

Independent Replication

We are exploring the possibility of evaluating the competing models in an independent FacetMAP dataset.

The intention is to distinguish model development from model validation and to minimize the influence of data-driven modifications on the final conclusions.

Repository Materials

The repository will provide:

FacetMAP data and variable descriptions, subject to data-sharing permissions.

Mplus input files for the reference model.

Mplus output and parameter estimates.

Tables of standardized factor loadings and residual relationships.

Documentation of model specifications and modifications.

Alternative models submitted by participating researchers.

Participation

Researchers interested in participating are invited to examine the reference model and develop an alternative theoretical representation of the personality structure.

Submissions should include the model specification, estimation results, and a brief explanation of the theoretical conclusions supported by the model.

The broader goal is to promote comparative, reproducible testing of personality theories using common data rather than separate demonstrations of preferred theoretical structures.

Project Contact

Ulrich Schimmack
University of Toronto Mississauga
Department of Psychology

References

Ashton, M. C., & Lee, K. — Research introducing the HEXACO model of personality structure.

DeYoung, C. G. (2006). Higher-order factors of the Big Five in a multi-informant sample. Journal of Personality and Social Psychology, 91, 1138–1151.

Digman, J. M. (1997). Higher-order factors of the Big Five. Journal of Personality and Social Psychology, 73, 1246–1256.

Irwing, P., Hughes, D., et al. (2024). Towards a Taxonomy of Personality Facets. [Complete citation to be verified.]

Silberzahn, R., et al. (2018). Many analysts, one data set: Making transparent how variations in analytic choices affect results. Advances in Methods and Practices in Psychological Science, 1, 337–356.
