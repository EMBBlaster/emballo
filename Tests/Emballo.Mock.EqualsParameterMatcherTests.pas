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

unit Emballo.Mock.EqualsParameterMatcherTests;

interface

uses
  TestFramework;

type
  TEqualsParameterMatcherTests = class(TTestCase)
  published
    procedure ShouldMatchOnEqualValueInteger;
    procedure ShouldNotMatchOnDifferentValueInteger;
    procedure TestDateTime;
  end;

implementation

uses
  DateUtils,
  Emballo.Mock.EqualsParameterMatcher,
  Emballo.Mock.ParameterMatcher,
  Emballo.DynamicProxy.InvokationHandler;

type
  TFakeIntegerParameter = class(TInterfacedObject, IParameter)
  private
    FValue: Integer;
    function GetAsBoolean: Boolean; virtual; abstract;
    function GetAsByte: Byte; virtual; abstract;
    function GetAsDouble: Double; virtual; abstract;
    function GetAsInteger: Integer;
    function GetAsString: string; virtual; abstract;
    procedure SetAsBoolean(Value: Boolean); virtual; abstract;
    procedure SetAsByte(Value: Byte); virtual; abstract;
    procedure SetAsDouble(Value: Double); virtual; abstract;
    procedure SetAsInteger(Value: Integer);
    procedure SetAsString(const Value: String); virtual; abstract;
    function GetAsDateTime: TDateTime; virtual; abstract;
    procedure SetAsDateTime(Value: TDateTime); virtual; abstract;
  public
    constructor Create(const Value: Integer);
  end;

  TFakeDateTimeParameter = class(TInterfacedObject, IParameter)
  private
    FValue: TDateTime;
    function GetAsBoolean: Boolean; virtual; abstract;
    function GetAsByte: Byte; virtual; abstract;
    function GetAsDouble: Double; virtual; abstract;
    function GetAsInteger: Integer; virtual; abstract;
    function GetAsString: string; virtual; abstract;
    procedure SetAsBoolean(Value: Boolean); virtual; abstract;
    procedure SetAsByte(Value: Byte); virtual; abstract;
    procedure SetAsDouble(Value: Double); virtual; abstract;
    procedure SetAsInteger(Value: Integer); virtual; abstract;
    procedure SetAsString(const Value: String); virtual; abstract;
    function GetAsDateTime: TDateTime;
    procedure SetAsDateTime(Value: TDateTime);
  public
    constructor Create(const Value: TDateTime);
  end;

{ TEqualsParameterMatcherTests }

procedure TEqualsParameterMatcherTests.ShouldMatchOnEqualValueInteger;
var
  Matcher: IParameterMatcher;
  P: IParameter;
begin
  Matcher := TEqualsParameterMatcher<Integer>.Create(1);
  P := TFakeIntegerParameter.Create(1);
  CheckTrue(Matcher.Match(P));
end;

procedure TEqualsParameterMatcherTests.ShouldNotMatchOnDifferentValueInteger;
var
  Matcher: IParameterMatcher;
  P: IParameter;
begin
  Matcher := TEqualsParameterMatcher<Integer>.Create(1);
  P := TFakeIntegerParameter.Create(2);
  CheckFalse(Matcher.Match(P));

  Matcher := TEqualsParameterMatcher<Integer>.Create(11);
  P := TFakeIntegerParameter.Create(20);
  CheckFalse(Matcher.Match(P));
end;

procedure TEqualsParameterMatcherTests.TestDateTime;
var
  Matcher: IParameterMatcher;
  P: IParameter;
begin
  Matcher := TEqualsParameterMatcher<TDateTime>.Create(EncodeDateTime(2011, 9, 5, 20, 27, 11, 12));
  P := TFakeDateTimeParameter.Create(EncodeDateTime(2011, 9, 5, 20, 27, 11, 12));
  CheckTrue(Matcher.Match(P));
end;

{ TFakeIntegerParameter }

constructor TFakeIntegerParameter.Create(const Value: Integer);
begin
  FValue := Value;
end;

function TFakeIntegerParameter.GetAsInteger: Integer;
begin
  Result := FValue;
end;

procedure TFakeIntegerParameter.SetAsInteger(Value: Integer);
begin
  FValue := Value;
end;

{ TFakeDateTimeParameter }

constructor TFakeDateTimeParameter.Create(const Value: TDateTime);
begin
  FValue := Value;
end;

function TFakeDateTimeParameter.GetAsDateTime: TDateTime;
begin
  Result := FValue;
end;

procedure TFakeDateTimeParameter.SetAsDateTime(Value: TDateTime);
begin
  FValue := Value;
end;

initialization
RegisterTest('Emballo.Mock', TEqualsParameterMatcherTests.Suite);

end.
