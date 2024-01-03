/// <summary>
///
/// I also don't like custom implementations of such things, but becomes necessary for some reasons:
///
/// <issues>
/// alot of (recent) related issues in System.Generics.Collections.TThreadedQueue<T> and TMonitor
/// -https://ideasawakened.com/post/revisting-tthreadedqueue-and-tmonitor-in-delphi
/// -https://en.delphipraxis.net/topic/2824-revisiting-tthreadedqueue-and-tmonitor/
/// </issues>
///
/// <performance improvements>
/// this implementation uses recent version of MREW (TLightweightMREW), which is MUCH faster and optimized
/// </performance improvements>
///
/// </summary>

unit Hub4D.CustomThreadSafeQueue;

interface

uses
  System.Generics.Collections,
  System.Types,
  System.SyncObjs;

type
  TCustomThreadedQueue<T> = class
  strict private
    FPopTimeout    : UInt64;
    FQueue         : TQueue<T>;
    FLocker        : TLightweightMREW;
    FEventPush     : TEvent;
    FEventNotFull  : TEvent;
    FQueueSize     : UInt64;
    FShutDown      : Boolean;
    FTotalPushed   : UInt64;
    FTotalPopped   : UInt64;

  private
    procedure DoShutDown;

  public
    procedure Push(const AItem: T);
    function Pop(out AQueueSize: UInt64; out AItem: T): TWaitResult; overload;
    function Pop(out AItem: T): TWaitResult; overload;
    function Pop: T; overload;
    function QueueSize: UInt64;

    property TotalPushed: UInt64 read FTotalPushed;
    property TotalPopped: UInt64 read FTotalPopped;

    constructor Create(const AMaxSize: UInt64; const APopTimeout: UInt64); overload;
    destructor Destroy; override;
  end;

implementation

{ TCustomThreadedQueue<T> }

constructor TCustomThreadedQueue<T>.Create(const AMaxSize: UInt64; const APopTimeout: UInt64);
begin
  inherited Create;

  FQueue         := TQueue<T>.Create;
  FEventPush     := TEvent.Create(nil, True, False, '');
  FEventNotFull  := TEvent.Create(nil, True, True, '');
  FShutDown      := False;
  FQueueSize     := AMaxSize;
  FQueue.Capacity:= FQueueSize;
  FPopTimeout    := APopTimeout;
  FTotalPushed   := 0;
  FTotalPopped   := 0;
end;

destructor TCustomThreadedQueue<T>.Destroy;
begin
  DoShutDown;
  FQueue.Free;
  FEventPush.Free;
  FEventNotFull.Free;

  inherited;
end;

procedure TCustomThreadedQueue<T>.DoShutDown;
begin
  FShutDown := True;
  FLocker.BeginWrite;
  try
    if FQueue.Count > 0 then
      FQueue.Clear;
  finally
    FLocker.EndWrite;
  end;
end;

procedure TCustomThreadedQueue<T>.Push(const AItem: T);
begin
  if FShutDown then
    Exit;

  // TODO
  // -PushTimeot
  // -PushAttempt

  {when is full wait for next Pop method signal this - threadsafe}
  FEventNotFull.WaitFor(INFINITE);

  FLocker.BeginWrite;
  try
    if FShutdown then
      Exit;
    FQueue.Enqueue(AItem);
    Inc(FTotalPushed);

    FEventPush.SetEvent;
    if FQueue.Count = FQueueSize then
      FEventNotFull.ResetEvent        {if is full blocks till next Pop}
    else
      FEventNotFull.SetEvent;         {if is NOT full continues}
  finally
    FLocker.EndWrite;
  end;
end;

function TCustomThreadedQueue<T>.Pop(out AQueueSize: UInt64; out AItem: T): TWaitResult;
begin
  if FShutDown then
    Exit(wrAbandoned);

  Result := FEventPush.WaitFor(FPopTimeout);

  AItem:= Default(T);
  if Result = wrSignaled then
  begin
    FLocker.BeginWrite;
    try
      if FShutdown then
        Exit(wrAbandoned);

      AQueueSize:=  FQueue.Count;
      if AQueueSize = 0 then
      begin
        FEventPush.ResetEvent;
        Exit(wrTimeout);
      end;

      AItem := FQueue.Extract;
      Inc(FTotalPopped);
    finally
      FLocker.EndWrite;
    end;
    {queue is not full, so Push method can proceed}
    FEventNotFull.SetEvent;
  end;
end;

function TCustomThreadedQueue<T>.Pop(out AItem: T): TWaitResult;
var
  LQueueSize: UInt64;
begin
  Result := Pop(LQueueSize, AItem);
end;

function TCustomThreadedQueue<T>.Pop: T;
begin
  Pop(Result);
end;

function TCustomThreadedQueue<T>.QueueSize: UInt64;
begin
  FLocker.BeginRead;
  try
    Result := FQueue.Count;
  finally
    FLocker.EndRead;
  end;

end;

end.
