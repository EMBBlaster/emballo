unit Emballo.Mock.MockTests;

interface

uses
  TestFramework,
  SysUtils,
  Emballo.Mock.Mock;

type
  TMocked = class
  public
    procedure Foo; virtual;
    function FooWithIntegerReturn: Integer; virtual;
    function FooWithStringReturn: String; virtual;
    procedure FooWithParameters(const A: Integer); virtual;
    procedure StringParameters(const S: String); virtual;
    function FooWithBooleanReturn: Boolean; virtual;
  end;

  {$M+}
  IMockIntf = interface
    ['{D57E62EE-85B0-4AD0-8F1D-9AD480DAA1B5}']
    procedure Foo;
  end;
  {$M-}

  ETestException = class(Exception)
  end;

  TMockTests = class(TTestCase)
  private
    FMock: TMock<TMocked>;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ShouldFailOnUnexpectedParameters;
    procedure ShouldFailOnUnexpectedCalls;
    procedure ExpectedCallShouldNotFail;
    procedure ShouldRaiseConfiguredException;
    procedure VerifyUsageMustFailIfUsageWasNotAsExpected;
    procedure VerifyUsageMustNotFailIfUsageWasAsExpected;
    procedure MethodShouldReturnSpecifiedValue;
    procedure ShouldReturnStringValue;
    procedure ShouldBeAbleToCastTheMockToTheMockedType;
    procedure ShouldReturnBooleanValue;
    procedure ShouldMatchStringArguments;
  end;

  TInterfaceMockTests = class(TTestCase)
  private
    FMock: TMock<IMockIntf>;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCallMethod;
  end;

implementation

uses
  Emballo.Mock.UnexpectedUsage;

{ TMockTests }

procedure TMockTests.ExpectedCallShouldNotFail;
begin
  FMock.Expects.Foo;

  FMock.GetObject.Foo;
end;

procedure TMockTests.MethodShouldReturnSpecifiedValue;
var
  ReturnValue: Integer;
begin
  FMock.WillReturn(10).When.FooWithIntegerReturn;

  ReturnValue := FMock.GetObject.FooWithIntegerReturn;

  CheckEquals(10, ReturnValue, 'Mocked method should return the specified value');
end;

procedure TMockTests.SetUp;
begin
  inherited;
  FMock := TMock<TMocked>.Create;
end;

procedure TMockTests.ShouldBeAbleToCastTheMockToTheMockedType;
var
  Mocked: TMocked;
begin
  Mocked := FMock;
  CheckTrue(Mocked = FMock.GetObject);
end;

procedure TMockTests.ShouldFailOnUnexpectedCalls;
begin
  try
    FMock.GetObject.Foo;
    Fail('An unexpected usage of the mocked object should raise an EUnexpectedUsage');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockTests.ShouldFailOnUnexpectedParameters;
begin
  FMock.Expects.FooWithParameters(10);

  try
    FMock.GetObject.FooWithParameters(11);
    Fail('Calling an expected method with unexpected parameters should fail');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockTests.ShouldMatchStringArguments;
  { Returns a new string with the same contents of another string.
    This is make sure mocks compare strings based on it's contents, not on
    it's memory address }
  function CloneStr(const Str: String): String;
  begin
    SetLength(Result, Length(Str));
    Move(Str[1], Result[1], Length(Str)*SizeOf(Char));
  end;
begin
  FMock.Expects.StringParameters('Test');
  FMock.GetObject.StringParameters(CloneStr('Test'));

  FMock.Expects.StringParameters('Test');
  try
    FMock.GetObject.StringParameters('Test2');
    Fail('aaa');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockTests.ShouldRaiseConfiguredException;
begin
  FMock.WillRaise(ETestException).When.Foo;

  try
    FMock.GetObject.Foo;
    Fail('The configured exception should have been raised');
  except
    on ETestException do CheckTrue(True);
  end;
end;

procedure TMockTests.ShouldReturnBooleanValue;
begin
  FMock.WillReturn(True).When.FooWithBooleanReturn;
  CheckTrue(FMock.GetObject.FooWithBooleanReturn, 'Didn''t return the defined "True" value');

  FMock.WillReturn(False).When.FooWithBooleanReturn;
  CheckFalse(FMock.GetObject.FooWithBooleanReturn, 'Didn''t return the defined "False" value');
end;

procedure TMockTests.ShouldReturnStringValue;
var
  Str: String;
begin
  FMock.WillReturn('Test').When.FooWithStringReturn;

  Str := FMock.GetObject.FooWithStringReturn;
  CheckEquals('Test', Str);
end;

procedure TMockTests.TearDown;
begin
  inherited;
  FMock.Free;
end;

procedure TMockTests.VerifyUsageMustFailIfUsageWasNotAsExpected;
begin
  FMock.Expects.Foo;

  try
    FMock.VerifyUsage;
    Fail('Mock was expecting a call that didn''t happen. VerifyUsage should have failed');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockTests.VerifyUsageMustNotFailIfUsageWasAsExpected;
begin
  FMock.Expects.Foo;

  FMock.GetObject.Foo;

  FMock.VerifyUsage;
end;

{ TMocked }

procedure TMocked.Foo;
begin
end;

function TMocked.FooWithBooleanReturn: Boolean;
begin
  Result := False;
end;

function TMocked.FooWithIntegerReturn: Integer;
begin
  Result := 0;
end;

procedure TMocked.FooWithParameters(const A: Integer);
begin

end;

function TMocked.FooWithStringReturn: String;
begin
  Result := '';
end;

procedure TMocked.StringParameters(const S: String);
begin

end;

{ TInterfaceMockTests }

procedure TInterfaceMockTests.SetUp;
begin
  inherited;
  FMock := TMock<IMockIntf>.Create;
end;

procedure TInterfaceMockTests.TearDown;
begin
  inherited;

end;

procedure TInterfaceMockTests.TestCallMethod;
begin
  FMock.Expects.Foo;
  FMock.GetObject.Foo;
end;

initialization
RegisterTest('Emballo.Mock', TMockTests.Suite);
RegisterTest('Emballo.Mock', TInterfaceMockTests.Suite);

end.
