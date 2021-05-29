{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit gpb;

interface

uses
  GradientProgressBar, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('GradientProgressBar', @GradientProgressBar.Register);
end;

initialization
  RegisterPackage('gpb', @Register);
end.
