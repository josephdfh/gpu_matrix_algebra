Attribute VB_Name = "exceldll_example"
'in source.cpp:
'#include <Windows.h>'
'double WINAPI myfun(const double* a, long n) {
'  double s = 0.;
'  for(int i = 0; i < n; ++i) {
'    s += a[ i ];
'  }
'  return s;
'}
'
'in source.def:
'EXPORT
'  myfun
'
'also: check linker's input field MDF is set to source.def
'project should be created as Win32 project, dll, empty

Declare Function myfun Lib "c:/temp/d.dll" (a As Double, ByVal n As Long) As Double

Sub test()
  Dim a(1 To 3) As Double
  a(1) = 1
  a(2) = 2
  a(3) = 3
  MsgBox myfun(a(LBound(a)), 3) '6
End Sub
