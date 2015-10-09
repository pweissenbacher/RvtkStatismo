#' create Isosurface from image
#'
#' create Isosurface from image
#'
#' @param file 3D-image file mha/nii.gz - depending of your system's VTK version
#' @param value isovalue
#' @param IJK2RAS 4x4 IJK2RAS transform
#' @return returns a triangular mesh of class mesh3d
#'
#' @export
vtkTriangulate <- function(file,value=1,IJK2RAS=diag(c(-1,-1,1,1))) {
    out <- .Call("vtkSegment2PolyData",file,value)
    class(out) <- "mesh3d"
    out$vb <- rbind(out$vb,1)
    out <- Morpho::applyTransform(out,IJK2RAS)
    return(out)
}