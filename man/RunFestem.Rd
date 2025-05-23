% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RunFestem.R
\name{RunFestem}
\alias{RunFestem}
\alias{RunFestem.Seurat}
\alias{RunFestem.matrix}
\alias{RunFestem.Matrix}
\title{Festem feature selection and differential expression gene analysis}
\usage{
RunFestem(object, ...)

\method{RunFestem}{Seurat}(
  object,
  G = NULL,
  prior = "HVG",
  batch = NULL,
  prior.weight = 0.05,
  prior.weight.filter = 0.9,
  earlystop = 1e-04,
  outlier_cutoff = 0.9,
  min.percent = 0.01,
  min.cell.num = 30,
  seed = 321,
  num.threads = 1,
  FDR_level = 0.05,
  block_size = 40000,
  assay = "RNA",
  prior_parameters = list(HVG_num = 2000, PC_dims = 50, resolution = 0.7),
  ...
)

\method{RunFestem}{matrix}(
  object,
  G,
  prior = NULL,
  batch = NULL,
  prior.weight = 0.05,
  prior.weight.filter = 0.9,
  earlystop = 1e-04,
  outlier_cutoff = 0.9,
  min.percent = 0.01,
  min.cell.num = 30,
  block_size = 40000,
  seed = 321,
  num.threads = 1,
  FDR_level = 0.05,
  ...
)

\method{RunFestem}{Matrix}(
  object,
  G,
  prior = NULL,
  batch = NULL,
  prior.weight = 0.05,
  prior.weight.filter = 0.9,
  earlystop = 1e-04,
  outlier_cutoff = 0.9,
  min.percent = 0.01,
  min.cell.num = 30,
  block_size = 40000,
  seed = 321,
  num.threads = 1,
  FDR_level = 0.05,
  ...
)
}
\arguments{
\item{object}{A Seurat object, matrix or dgCMatrix containing the original count matrix. 
If a Seurat object is provided, further information on cells (such as pre-clustering and 
batches) can be included in the metadata slot and specified with parameters \code{prior} 
and \code{batch}. If a matrix or dgCMatrix is provided, its rows should represent different
genes and columns stand for cells. We recommend setting the rownames as the name of genes.
If row names are not specified, numerical indices will be created to represent genes
according to their order in the input matrix.}

\item{...}{other parameters}

\item{G}{An integer specifying number of mixing component (roughly speaking, number of clusters) 
used in EM-test. When \code{object} is a Seurat object and \code{G} is null, \code{G} will be automatically determined
by running Louvain clustering using parameters specified by \code{prior_parameters}.
Empirically, we recommend setting it slightly larger than the expected number
of clusters to gain more statistical power. Theoretically speaking, if \code{G} is larger than 
the actual number of clusters, the test is still valid and does not lose any power; however, if it 
is smaller than the actual number, the power might decrease slightly but the test is still valid 
(i.e. type I error can be controlled).}

\item{prior}{A string or vector specifying prior (pre-clustering label), can be "HVG" (default), "active.ident", the name of a column
in metadata storing the pre-clustering label for each cell or a vector containing labels for each cell.
If "HVG", pre-clustering will be automatically performed with parameters specified by \code{prior_parameters}.
If a vector is provided, it should have the same length as the number of cells.}

\item{batch}{A string or vector specifying batches for cells, can be \code{NULL} (default), the name of a column in metadata
storing batch indices, or a vector containing batch indices for cells. If \code{NULL}, all cells are assumed
coming from the same batch.}

\item{prior.weight}{Numerical, specifying prior weight used for EM-test (default = 0.05).}

\item{prior.weight.filter}{Numerical, specifying prior weight used to filter out genes that have expression patterns significantly 
conflict with the pre-clustering labels (default = 0.9).}

\item{earlystop}{Numerical, specifying threshold of absolute changes in penalized log-likelihood (See \sQuote{Details} in \code{\link{em_test}} ) for early-stopping. 
Empirically, if the data is far from homogeneously distributed, the penalized log-likelihood will increase rapidly in the early stage of 
iterations. Later iterations only increase the penalized likelihood marginally. Therefore, specifying an early-stopping threshold can save 
some time while still guarantee the validity of p-values.}

\item{outlier_cutoff}{Numerical, ranging from 0 to 1. Outliers are identified only in the largest \eqn{\alpha} proportion counts
specified by this parameter.}

\item{min.percent, min.cell.num}{Numerical, specifying the filtering threshold for a gene to be tested. If a gene has non-zero expression
in at most \code{min(n*min.percent,min.cell.num)} cells, where \code{n} is the total cell numbers, then this gene will not be tested.}

\item{seed}{Numerical, seed of the random number generator.}

\item{num.threads}{Integer, number of CPU cores to use.}

\item{FDR_level}{Numerical, nomical FDR level to determine number of selected features (i.e. differential expression genes).}

\item{block_size}{Integer, number of genes processed at a time when removing outliers. If parApply returns an out-of-memory error, try use a smaller block size.}

\item{assay}{Name of Assay used}

\item{prior_parameters}{A list containing parameters to do pre-clustering with HVG. \code{HVG_num} specified
number of HVG to use and \code{PC_dims} is the number of PC dimensions to use.}
}
\value{
Seurat (version 4) object. Selected features placed into
\code{var.features} object. Test statistics, p-values and ranks for genes are placed into columns of
\code{meta.data} in the slot, with column names "p", "EM", and "Festem_rank", respectively.  For downstream Seurat analyses,
use default variable features.

A list containing test results, gene ranks and selected gene list. The first element of 
the list is a data.frame whose columns are gene names, p-values and EM statistics for filtering.
The second element is a vector of genes ordered according to EM-test. The third element is a 
vector of selected genes.

A list containing test results, gene ranks and selected gene list. The first element of 
the list is a data.frame whose columns are gene names, p-values and EM statistics for filtering.
The second element is a vector of genes ordered according to EM-test. The third element is a 
vector of selected genes.
}
\description{
Run Festem algorithm with Seurat pipeline or original count matrix.
}
\details{
For details of Festem, see Chen, Wang, et al (2023).
}
\examples{
# Load example data
data("example_data")
example_data <- Seurat::CreateSeuratObject(example_data$counts,meta.data = example_data$metadata)
example_data <- RunFestem(example_data,2,prior = "labels")
Seurat::VariableFeatures(example_data)[1:10]
# Use smaller block size for memory issue
data("example_data")
example_data <- Seurat::CreateSeuratObject(example_data$counts,meta.data = example_data$metadata)
example_data <- RunFestem(example_data,2,prior = "labels",block_size = 50)
Seurat::VariableFeatures(example_data)[1:10]
}
\references{
Chen, Z., Wang, C., Huang, S., Shi, Y., & Xi, R. (2024). Directly selecting cell-type marker genes for single-cell clustering analyses. Cell Reports Methods, 4(7).
}
\seealso{
[em_test()]
}
