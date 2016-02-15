#include <vtkVersion.h>
#include <vtkSurfaceReconstructionFilter.h>
#include <vtkProgrammableSource.h>
#include <vtkContourFilter.h>
#include <vtkReverseSense.h>
#include <vtkPolyDataMapper.h>
#include <vtkProperty.h>
#include <vtkPolyData.h>
#include <vtkCamera.h>
#include <vtkRenderer.h>
#include <vtkBooleanOperationPolyDataFilter.h>
#include <vtkMath.h>
#include <vtkSmartPointer.h>
#include <cmath>
#include <vtkTransform.h>
#include <vtkTransformPolyDataFilter.h>
#include "RcppEigen.h"
#include "R2polyData.h"
#include "polyData2R.h"
#include "vtkpoly2unstruct.h"
#include "R2vtkPoints.h"
#include "vtkImageIO.h"


RcppExport SEXP vtkBooleanOp(SEXP mesh0_,SEXP mesh1_, SEXP optype_) {
try {
  List mesh0(mesh0_);
  List mesh1(mesh1_);
  int optype = as<int>(optype_);
  vtkSmartPointer<vtkPolyData> polydata0 = R2polyData(mesh0["vb"],mesh0["it"]);
  vtkSmartPointer<vtkPolyData> polydata1 = R2polyData(mesh1["vb"],mesh1["it"]);
  vtkSmartPointer<vtkBooleanOperationPolyDataFilter> booleanOperation =  vtkSmartPointer<vtkBooleanOperationPolyDataFilter>::New();
  booleanOperation->SetOperation(optype);
#if VTK_MAJOR_VERSION <= 5
 booleanOperation->SetInput(polydata0);
 booleanOperation->SetInput(polydata1);
#else
 booleanOperation->SetInputData(0,polydata0);
 booleanOperation->SetInputData(1,polydata1);
#endif
 
 booleanOperation->Update(); 
  return polyData2R(booleanOperation->GetOutput());
 } catch (std::exception& e) {
  ::Rf_error( e.what());
 } catch (...) {
  ::Rf_error("unknown exception");
 }
}

