#' constrain a model of class pPCA
#'
#' constrain a model of class pPCA
#' @param model object of class pPCA
#' @param sample k x 3 matrix containing coordinates to constrain model to
#' @param pt either a matrix with each row containing points on the model's domain corresponding to the row in \code{sample} or an integer vector specifying the coordinates of the sample's mean corresponding to \code{sample} 
#' @param ptValueNoise can be a single value, if the same spherical noise is to be used for all points, or a vector specifying spherical noise per point or a k*3 x 3 matrix with the per-point covariance matrices concatenated by row. See note below.
#' @param computeScores if TRUE, the scores (if present) are projected into the updated model space.
#' @param pointer if TRUE an object of class pPCA_pointer is returned.
#' @note to specify per-point covariance matrices, one first has to setup the matrices at each point and then combine them via rbind.
#' @return a constrained model
#' @examples
#' require(Rvcg)
#' data(humface)
#' hummodel <- statismoModelFromRepresenter(humface)
#' GPmodConstUnif <- statismoConstrainModel(hummodel,humface.lm,humface.lm,ptValueNoise = 1)
#' \dontrun{
#' ## sample from model
#' for(i in 1:10) rgl::wire3d(DrawSample(GPmodConstUnif),col="red")
#' }
#' noise <- (0:6)*5
#' GPmodConst <- statismoConstrainModel(hummodel,humface.lm,humface.lm,ptValueNoise = noise)
#' \dontrun{
#' ## sample from model
#' for(i in 1:10) rgl::wire3d(DrawSample(GPmodConst),col="white")
#' }
#' ## and here an example where we assume spherical noise for each coordinate
#' ## except the first one
#' ## first constrain the model using the assumed covariance of the first coordinate
#' noise1 <- diag(3);noise1[1,1] <- 6
#' GPmodCov <- statismoConstrainModel(hummodel,humface.lm[1,,drop=FALSE],
#'                                    humface.lm[1,,drop=FALSE],ptValueNoise = 1)
#' ## now we constrain the rest
#' GPmodCov <- statismoConstrainModel(GPmodCov,humface.lm[-1,],humface.lm[-1,],ptValueNoise = 0.01)

#' @rdname statismoConstrainModel
#' @name statismoConstrainModel
#' @docType methods
#' @export
setGeneric("statismoConstrainModel",function(model,sample,pt,ptValueNoise,computeScores=TRUE,pointer=FALSE){
    standardGeneric("statismoConstrainModel")})

#' @rdname statismoConstrainModel
setMethod("statismoConstrainModel",signature(model="pPCA",sample="matrix",pt="matrix"), function(model,sample,pt,ptValueNoise, computeScores=TRUE, pointer=FALSE) {
    
    ptValueNoise <- checkpointValueNoise(ptValueNoise,sample)
    mean <- t(pt)
    sample <- t(sample)
    out <- .Call("PosteriorModel",model,sample, mean,ptValueNoise,computeScores,pointer)
    return(out)
})
#' @rdname statismoConstrainModel
setMethod("statismoConstrainModel",signature(model="pPCA",sample="matrix",pt="numeric"), function(model,sample,pt,ptValueNoise,computeScores=TRUE, pointer=FALSE) {
    ptValueNoise <- checkpointValueNoise(ptValueNoise,sample)
    mean <- t(GetDomainPoints(model))[,pt,drop=FALSE]
    sample <- t(sample)
    out <- .Call("PosteriorModel",model,sample, mean,ptValueNoise,computeScores,pointer)
    return(out)
})
#' @rdname statismoConstrainModel
setMethod("statismoConstrainModel",signature(model="pPCA",sample="numeric",pt="numeric"), function(model,sample,pt,ptValueNoise,computeScores=TRUE, pointer=FALSE) {
    ptValueNoise <- checkpointValueNoise(ptValueNoise,sample)
    sample <- matrix(sample,3,1)
    if (length(pt) == 3)
        mean <- matrix(pt,3,1)
    else if (length(pt) == 1)
        mean <- t(GetDomainPoints(model))[,pt,drop=FALSE]
    else
        stop("in this case pt must be a vector of length 3 or an integer")
    out <- .Call("PosteriorModel",model,sample, mean,ptValueNoise,computeScores,pointer)
    return(out)
})

#' calculate a posterior model but only use likely correspondences
#'
#' calculate a posterior model but only use likely correspondences
#' @param model object of class pPCA
#' @param sample matrix containing coordinates to constrain model to
#' @param pt either a k x 3 matrix with each row containing points on the model's domain corresponding to the row in \code{sample} or an integer vector specifying the coordinates of the sample's mean corresponding to \code{sample} 
#' @param ptValueNoise can be a single value, if the same spherical noise is to be used for all points, or a vector specifying spherical noise per point or a k*3 x 3 matrix with the per-point covariance matrices concatenated by row. See note below.
#' @param sdmax a measure in standard deviations to allow the likelihood of the correspondeces between sample and model. (using chi-square distribution)
#' @param computeScores if TRUE, the scores (if present) are projected into the updated model space.
#' @param pointer if TRUE an object of class pPCA_pointer is returned.
#' @note to specify per-point covariance matrices, one first has to setup the matrices at each point and then combine them via rbind.
#' @return a constrained model
#' @rdname statismoConstrainModelSafe
#' @name statismoConstrainModelSafe
#' @export
setGeneric("statismoConstrainModelSafe",function(model,sample,pt,ptValueNoise,sdmax=5,computeScores=TRUE, pointer=FALSE){
    standardGeneric("statismoConstrainModelSafe")})

#' @rdname statismoConstrainModelSafe
setMethod("statismoConstrainModelSafe",signature(model="pPCA",sample="matrix",pt="numeric"), function(model,sample,pt,ptValueNoise,sdmax=5,computeScores=TRUE, pointer=FALSE) {
    ptValueNoise <- checkpointValueNoise(ptValueNoise,sample)
    mean <- t(GetDomainPoints(model))[,pt,drop=FALSE]
    sample <- t(sample)
    mahamax <- sqrt(qchisq(1-2*pnorm(sdmax,lower.tail=F),df=3))
    out <- .Call("PosteriorModelSafe",model,sample, mean,ptValueNoise,mahamax,computeScores,pointer)
})

#' @rdname statismoConstrainModelSafe
setMethod("statismoConstrainModelSafe",signature(model="pPCA",sample="matrix",pt="matrix"), function(model,sample,pt,ptValueNoise,sdmax=5,computeScores=TRUE, pointer=FALSE) {
    ptValueNoise <- checkpointValueNoise(ptValueNoise,sample)
    mean <- t(pt)
    sample <- t(sample)
    mahamax <- sqrt(qchisq(1-2*pnorm(sdmax,lower.tail=F),df=3))
    out <- .Call("PosteriorModelSafe",model,sample, mean,ptValueNoise,mahamax,computeScores,pointer)
})

#' @rdname statismoConstrainModelSafe
setMethod("statismoConstrainModelSafe",signature(model="pPCA",sample="numeric",pt="numeric"), function(model,sample,pt,ptValueNoise,sdmax=5,computeScores=TRUE, pointer=FALSE) {
    ptValueNoise <- checkpointValueNoise(ptValueNoise,sample)
    
    sample <- matrix(sample,3,1)
    if (length(pt) == 3)
        mean <- matrix(pt,3,1)
    else if (length(pt) == 1)
        mean <- t(GetDomainPoints(model))[,pt,drop=FALSE]
    else
        stop("in this case pt must be a vector of length 3 or an integer")
    mahamax <- sqrt(qchisq(1-2*pnorm(sdmax,lower.tail=F),df=3))
    out <- .Call("PosteriorModelSafe",model,sample, mean,ptValueNoise,mahamax,computeScores,pointer)
})


checkpointValueNoise <- function(ptValueNoise,sample) {
    if (!is.matrix(sample))
        sample <- as.matrix(sample)
    if (length(ptValueNoise) == 1) {
        ptValueNoise <- max(1e-7,ptValueNoise)
    } else if (is.vector(ptValueNoise)) {
        if (length(ptValueNoise) != nrow(sample))
            stop("each entries in ptValueNoise != number of sample points")
        ptValueNoise[which(ptValueNoise < 1e-7)] <- 1e-7
    } else if (is.matrix(ptValueNoise)) {
        if (nrow(ptValueNoise) != (nrow(sample)*3))
            stop("each entries in ptValueNoise != number of sample points")
        ptValueNoise[which(ptValueNoise < 1e-7)] <- 1e-7
    }
    ptValueNoise <- as.matrix(ptValueNoise)
    return(ptValueNoise)
}


#' Get pointwise Mahalanobis Distances based on Per-Coordinate Covariance Matrices
#'
#' Get pointwise Mahalanobis Distances based on Per-Coordinate Covariance Matrices
#' @param model shape model
#' @param sample matrix with sample landmarks to be tested
#' @param pt matrix with coordinates on the model mean or indices
#' @return returns a vector of Mahalanobis distances
#' @examples
#' require(Morpho)
#' data(boneData)
#' align <- rigidAlign(boneLM)$rotated
#' mymod <- statismoBuildModel(align,representer=align[,,1],sigma=2,scale=TRUE)
#' mahadists <- GetMahalanobisForPointSets(mymod,align[,,1],1:10)
#' @export
GetMahalanobisForPointSets <- function(model,sample,pt) {
    if (is.vector(pt))
        mean <- t(GetDomainPoints(model))[,pt,drop=FALSE]
    else
        mean <- t(pt)
    sample <- t(sample)
    out <- .Call("GetMahalanobisForPointSets",model,sample,mean)
    return(out)
}
    
