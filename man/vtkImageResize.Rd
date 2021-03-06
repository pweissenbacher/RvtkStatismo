% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vtkImageBlend.r
\name{vtkImageResize}
\alias{vtkImageResize}
\title{Resample an image and write to file.}
\usage{
vtkImageResize(image, outname, spacing = c(1, 1, 1), interpolate = 2)
}
\arguments{
\item{image}{character: path to image file}

\item{outname}{character: path to write resampled image to.}

\item{spacing}{integer vector: spacing of resampled image.}

\item{interpolate}{integer: 0=no interpolation, 1=linear,2=bicubic.}
}
\description{
Resample an image and write to file.
}

