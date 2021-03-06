{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Emballo.
    If not, see <http://www.gnu.org/licenses/>. }

program Demo;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  Emballo.DI.Registry,
  UFrmMain in '..\Src\UFrmMain.pas' {FrmMain},
  UTimeService in '..\Src\UTimeService.pas',
  UTimeSerivceImpl in '..\Src\UTimeSerivceImpl.pas',
  UGreetingService in '..\Src\UGreetingService.pas',
  UGreetingServiceImpl in '..\Src\UGreetingServiceImpl.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  RegisterFactory(ITimeService, TTimeService).Done;

  { *************************************************************************
    * Each of these two IGreetingService implementation show a different    *
    * way for getting the ITimeService instance. Choose one.                *
    ************************************************************************* }
  RegisterFactory(IGreetingService, TGreetingServiceWithConstructorInjection).Done;
//  RegisterFactory(IGreetingService, TGreetingServiceManualyGetTimeService).Done;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
