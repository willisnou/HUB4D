unit Hub4D.Queue;

interface

uses
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Hub4D.Queue.Interfaces,
  Hub4D.Messages,
  Hub4D.Dispatcher,
  Hub4D.Dispatcher.Interfaces,
  Hub4D.Consumer,
  Hub4D.Consumer.Interfaces,
  Hub4D.CustomThreadSafeQueue;

type
  TQueue<T: Record> = class(TThread, IInterface, IQueue<T>)
    strict private
      FRefCount  : Integer;
      FMsgID     : Cardinal;
      FQueue     : TCustomThreadedQueue<T>;
      FDispatcher: IDispatcher<T>;

    protected
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;

      procedure Execute; override;

    public
      function ID: Cardinal;
      function Enqueue(const AData: T): IQueue<T>;
      function Dispatcher: IDispatcher<T>;
      function QueueSize: UInt64;
      function QueueTotalPushed: UInt64;
      function QueueTotalPopped: UInt64;
      procedure Finalize;

      constructor Create(const AMsgID: Cardinal; AConsumers: IConsumerManager<T>);
      destructor Destroy; override;
  end;

implementation

{ TQueue }

constructor TQueue<T>.Create(const AMsgID: Cardinal; AConsumers: IConsumerManager<T>);
begin
  inherited Create(False);

  Self.FreeOnTerminate:= True;
  FQueue              := TCustomThreadedQueue<T>.Create(C_DEFAULT_MAX_QUEUE_SIZE, C_DEFAULT_POP_TIMEOUT);
  FMsgID              := AMsgID;
  FDispatcher         := TDispatcher<T>.Create(AConsumers, FQueue);
  AConsumers          := AConsumers;
end;

destructor TQueue<T>.Destroy;
begin
  FQueue.Free;
  Self.Terminate;

  inherited;
end;

function TQueue<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TQueue<T>._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TQueue<T>._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;


procedure TQueue<T>.Execute;
var
  LMsg: TMsg;
begin
  while GetMessage(LMsg, 0, 0, 0) and not (Terminated) do
  begin
    case LMsg.message of
      WM_ENQUEUE: begin
                    FQueue.Push(PCustomMessage(LMsg.wParam)^);
                    Dispose(PCustomMessage(LMsg.wParam));
                  end;

      WM_QUIT:    begin
                    FDispatcher.Finalize;
                    PostQuitMessage(0);
                  end;
    end;
  end;
end;

function TQueue<T>.ID: Cardinal;
begin
  Result:= Self.ThreadID;
end;

function TQueue<T>.Enqueue(const AData: T): IQueue<T>;
var
  LData: PCustomMessage;
begin
  New(LData);
  {we need to use a internal pointer message for memory management, generics can make things complicated}
  LData^:= TCustomMessage((@AData)^);
  PostThreadMessage(Self.ID, WM_ENQUEUE, wParam(LData), 0);
end;

function TQueue<T>.Dispatcher: IDispatcher<T>;
begin
  Result:= FDispatcher;
end;

function TQueue<T>.QueueSize: UInt64;
begin
  Result:= FQueue.QueueSize;
end;

function TQueue<T>.QueueTotalPushed: UInt64;
begin
  Result:= FQueue.TotalPushed;
end;

function TQueue<T>.QueueTotalPopped: UInt64;
begin
  Result:= FQueue.TotalPopped;
end;

procedure TQueue<T>.Finalize;
begin
  PostThreadMessage(Self.ID, WM_QUIT, 0, 0);
end;

end.
