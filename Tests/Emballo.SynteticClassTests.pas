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

unit Emballo.SynteticClassTests;

interface

uses
  TestFramework;

type
  ISomeIntf = interface
    ['{C24CC8B5-BBE9-48CC-80D4-0367451D7329}']
    function GetX: Integer;
    procedure SetX(const X: Integer);
  end;

  ISomeSubIntf = interface(ISomeIntf)
    ['{74B68341-93F5-4625-AF92-4CFD3EA90E53}']
  end;

  TBaseClassWithIntf = class(TInterfacedObject, ISomeSubIntf)
  private
    FX: Integer;
  public
    function GetX: Integer;
    procedure SetX(const X: Integer);
  end;

  TBaseClass = class
    Test: Integer;
  protected
    function GetTest: Integer; virtual; abstract;
  end;

  TConcreteClass = class(TBaseClass)
  protected
    function GetTest: Integer; override;
  end;



  TSynteticClassTests = class(TTestCase)
  published
    procedure FinalizerShouldBeCalledWhenFreeIsCalled;
    procedure InstanceSizeShouldConsiderAditionalInstanceData;
    procedure InstanceSizeShouldConsiderImplementedInterfaceCount;
    procedure InterfaceTableShouldBeTheNumberOfImplementedInterfaces;
    procedure InterfaceTableEntriesMustBeTheImplementedInterfacesInTheSameOrder;
    procedure InterfaceTableIOffsetShouldBeSet;
    procedure InterfaceTableShouldBeNilIfNoInterfaceIsImplemented;
    procedure InterfaceTableIOffsetShouldBeSetCorrectlyWhenClassHasAditionalData;
    procedure AccessToAditionalInstanceDataShouldNotCorruptTheObject;
    procedure FreeSynteticClassWhenInstanceIsFreedIfOptionIsSet;
    procedure TestAditionalData;
    procedure TestSameTypeInfo;
    procedure TestVTable;
    procedure InterfacesImplementedOnBaseClass;
    procedure CallAbstractMethodsOfSynteticClassInstance;
  end;

implementation

uses
  Emballo.SynteticClass, SysUtils;

{ TSynteticClassTests }

procedure TSynteticClassTests.AccessToAditionalInstanceDataShouldNotCorruptTheObject;
var
  SynteticClass: TSynteticClass;
  Instance: TBaseClass;
  AditionalInstanceData: PInteger;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, SizeOf(Integer), Nil, False);
  try
    Instance := SynteticClass.Metaclass.Create as TBaseClass;
    try
      Instance.Test := 10;
      AditionalInstanceData := PInteger(GetAditionalData(Instance));
      AditionalInstanceData^ := 20;

      CheckEquals(10, Instance.Test);
    finally
      Instance.Free;
    end;
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.CallAbstractMethodsOfSynteticClassInstance;
var
  SynteticClass: TSynteticClass;
  Instance: TBaseClass;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TConcreteClass, 0, Nil, False);
  try
    Instance := SynteticClass.Metaclass.Create as TBaseClass;
    try
      Instance.Test := 10;
      CheckEquals(10, Instance.GetTest);
    finally
      Instance.Free;
    end;
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.FinalizerShouldBeCalledWhenFreeIsCalled;
var
  SynteticClass: TSynteticClass;
  CalledFinalizer: Boolean;
  Instance: TObject;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0, Nil, False);
  try
    SynteticClass.Finalizer := procedure(const Instance: TObject)
    begin
      CalledFinalizer := True;
    end;

    CalledFinalizer := False;

    Instance := SynteticClass.Metaclass.Create;
    Instance.Free;

    CheckTrue(CalledFinalizer, 'Finalizer should be called when an instance is Free''d');
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.FreeSynteticClassWhenInstanceIsFreedIfOptionIsSet;
var
  SynteticClass: TSynteticClass;
  Instance: TObject;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 10, Nil, True);
  Instance := SynteticClass.Metaclass.Create;
  Instance.Free;
end;

procedure TSynteticClassTests.InstanceSizeShouldConsiderAditionalInstanceData;
var
  SynteticClass: TSynteticClass;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 10, Nil, False);
  try
    CheckEquals(TBaseClass.InstanceSize + 10, SynteticClass.Metaclass.InstanceSize, 'SynteticClass'' Instance size should consider the aditional instance data size');
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.InstanceSizeShouldConsiderImplementedInterfaceCount;
var
  SynteticClass: TSynteticClass;
  Guids: TArray<TGuid>;
begin
  SetLength(Guids, 2);
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0, Guids, False);
  try
    CheckEquals(TBaseClass.InstanceSize + 2*SizeOf(Pointer), SynteticClass.Metaclass.InstanceSize, 'SynteticClass'' Instance size should consider the aditional instance data size');
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.InterfacesImplementedOnBaseClass;
var
  SynteticClass: TSynteticClass;
  Inst: TObject;
  Intf: ISomeSubIntf;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClassWithIntf, 0, Nil, False);
  try
    Inst := SynteticClass.Metaclass.Create;
    Supports(Inst, ISomeSubIntf, Intf);
    Intf.SetX(123);
    CheckEquals(123, Intf.GetX);
    Intf := Nil;
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.InterfaceTableEntriesMustBeTheImplementedInterfacesInTheSameOrder;
var
  SynteticClass: TSynteticClass;
  Guids: TArray<TGuid>;
begin
  SetLength(Guids, 2);
  Guids[0] := StringToGUID('{4F1D8AD9-AACB-4107-A6B4-38D558133076}');
  Guids[1] := StringToGUID('{AD855E31-C5BE-4C6C-94E0-7EB4173F0075}');

  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0, Guids, False);
  try
    CheckTrue(IsEqualGUID(Guids[0], SynteticClass.Metaclass.GetInterfaceTable.Entries[0].IID));
    CheckTrue(IsEqualGUID(Guids[1], SynteticClass.Metaclass.GetInterfaceTable.Entries[1].IID));
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.InterfaceTableIOffsetShouldBeSet;
var
  SynteticClass: TSynteticClass;
  Guids: TArray<TGuid>;
begin
  SetLength(Guids, 2);

  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0, Guids, False);
  try
    CheckEquals(TBaseClass.InstanceSize - SizeOf(Integer) + 0*SizeOf(Pointer), SynteticClass.Metaclass.GetInterfaceTable.Entries[0].IOffset);
    CheckEquals(TBaseClass.InstanceSize - SizeOf(Integer) + 1*SizeOf(Pointer), SynteticClass.Metaclass.GetInterfaceTable.Entries[1].IOffset);
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.InterfaceTableIOffsetShouldBeSetCorrectlyWhenClassHasAditionalData;
var
  SynteticClass: TSynteticClass;
  Guids: TArray<TGuid>;
begin
  SetLength(Guids, 2);

  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 5, Guids, False);
  try
    CheckEquals(TBaseClass.InstanceSize - SizeOf(Integer) + 0*SizeOf(Pointer) + 5, SynteticClass.Metaclass.GetInterfaceTable.Entries[0].IOffset);
    CheckEquals(TBaseClass.InstanceSize - SizeOf(Integer) + 1*SizeOf(Pointer) + 5, SynteticClass.Metaclass.GetInterfaceTable.Entries[1].IOffset);
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.InterfaceTableShouldBeNilIfNoInterfaceIsImplemented;
var
  SynteticClass: TSynteticClass;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0, Nil, False);
  try
    CheckTrue(SynteticClass.Metaclass.GetInterfaceTable = Nil);
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.InterfaceTableShouldBeTheNumberOfImplementedInterfaces;
var
  SynteticClass: TSynteticClass;
  Guids: TArray<TGuid>;
begin
  SetLength(Guids, 2);
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0, Guids, False);
  try
    CheckEquals(2, SynteticClass.Metaclass.GetInterfaceTable.EntryCount);
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.TestAditionalData;
var
  SynteticClass: TSynteticClass;
  Instance: TObject;
  Value: Integer;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, SizeOf(Integer), Nil, False);
  try
    Instance := SynteticClass.Metaclass.Create;
    try
      Value := 20;
      SetAditionalData(Instance, Value);
      Value := PInteger(GetAditionalData(Instance))^;
      CheckEquals(20, Value);
    finally
      Instance.Free;
    end;
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.TestSameTypeInfo;
var
  SynteticClass: TSynteticClass;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0, Nil, False);
  try
    CheckTrue(SynteticClass.Metaclass.ClassInfo = TBaseClass.ClassInfo);
  finally
    SynteticClass.Free;
  end;
end;

procedure TSynteticClassTests.TestVTable;
begin

end;

{ TBaseClassWithIntf }

function TBaseClassWithIntf.GetX: Integer;
begin
  Result := FX;
end;

procedure TBaseClassWithIntf.SetX(const X: Integer);
begin
  FX := X;
end;

{ TConcreteClass }

function TConcreteClass.GetTest: Integer;
begin
  Result := Test;
end;

initialization
RegisterTest('Emballo', TSynteticClassTests.Suite);

end.
