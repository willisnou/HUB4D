unit Hub4D.Dispatcher;

interface

uses
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Hub4D.Dispatcher.Interfaces,
  Hub4D.Consumer.Interfaces,
  Hub4D.CustomThreadSafeQueue;

type
  TDispatcher<T> = class (TThread, IInterface, IDispatcher<T>)
  strict private
    FRefCount       : Integer;
    FConsumerManager: IConsumerManager<T>;
    FQueue          : TCustomThreadedQueue<T>;

  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    procedure Execute; override;

  private
    function DispatchMessage(const AData: T): IDispatcher<T>; overload;
    function ID: Cardinal;
    function Consumers: IConsumerManager<T>;
    procedure Finalize;

  public
    constructor Create(AConsumerManager: IConsumerManager<T>; AQueue: TCustomThreadedQueue<T>);
    destructor Destroy; override;

  end;

implementation

{ TDispatcher }

constructor TDispatcher<T>.Create(AConsumerManager: IConsumerManager<T>; AQueue: TCustomThreadedQueue<T>);
begin
  inherited Create(False);

  FConsumerManager:= AConsumerManager;
  FQueue          := AQueue;
end;

destructor TDispatcher<T>.Destroy;
begin
  inherited;
end;

function TDispatcher<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TDispatcher<T>._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TDispatcher<T>._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

function TDispatcher<T>.DispatchMessage(const AData: T): IDispatcher<T>;
begin
  FConsumerManager.Notify(AData);
end;

function TDispatcher<T>.ID: Cardinal;
begin
  Result:= Self.ThreadID;
end;

function TDispatcher<T>.Consumers: IConsumerManager<T>;
begin
  Result:= FConsumerManager;
end;

procedure TDispatcher<T>.Execute;
var
  LData: T;
begin
  while not (Terminated) do
  begin
    if FQueue.Pop(LData) = wrSignaled then
      Self.DispatchMessage(LData);
  end;
end;

procedure TDispatcher<T>.Finalize;
begin
  Self.FConsumerManager.RemoveAll;
end;

end.
