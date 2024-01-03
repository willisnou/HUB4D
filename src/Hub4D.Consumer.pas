unit Hub4D.Consumer;

interface

uses
  System.SyncObjs,
  System.Generics.Collections,
  System.Classes,
  Hub4D.Messages,
  Hub4D.Consumer.Interfaces;

type
  TConsumerManager<T> = class (TInterfacedObject, IConsumerManager<T>)
  strict private
    FConsumers  : TList<TCustomProc<T>>;
    FLocker     : TLightweightMREW;
    FEventAccess: TEvent;

  public
    function List: TList<TCustomProc<T>>;
    function Add(const AConsumer: TCustomProc<T>): IConsumerManager<T>;
    function Remove(const AConsumer: TCustomProc<T>): IConsumerManager<T>;
    function RemoveAll: IConsumerManager<T>;
    procedure Notify(const AData: T);

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TConsumerManager }

constructor TConsumerManager<T>.Create;
begin
  FConsumers:= TList<TCustomProc<T>>.Create;
  FEventAccess:= TEvent.Create(nil, True, True, '');
end;

destructor TConsumerManager<T>.Destroy;
begin
  FConsumers.Free;
  FEventAccess.Free;

  inherited;
end;

function TConsumerManager<T>.List: TList<TCustomProc<T>>;
var
  LEvent: TEvent;
begin
  {waits for access to perform}
  Result:= nil;
  LEvent:= TEvent.Create(nil, True, False, '');
  try
  TThread.CreateAnonymousThread(procedure
                                begin
                                  FEventAccess.WaitFor(INFINITE);
                                  FLocker.BeginRead;
                                  try
                                    FEventAccess.ResetEvent;
                                  finally
                                    FLocker.EndRead;
                                    FEventAccess.SetEvent;
                                    LEvent.SetEvent;
                                  end;
                                end).Start;
  finally
    LEvent.WaitFor(INFINITE);
    LEvent.Free;
  end;
  Result:= FConsumers;
end;

function TConsumerManager<T>.Add(const AConsumer: TCustomProc<T>): IConsumerManager<T>;
begin
  {waits for access to perform}
  Result:= Self;
  TThread.CreateAnonymousThread(procedure
                                begin
                                  FEventAccess.WaitFor(INFINITE);
                                  FLocker.BeginWrite;
                                  try
                                    FEventAccess.ResetEvent;
                                    FConsumers.Add(AConsumer);
                                  finally
                                    FLocker.EndWrite;
                                    FEventAccess.SetEvent;
                                  end;
                                end).Start;
end;

function TConsumerManager<T>.Remove(const AConsumer: TCustomProc<T>): IConsumerManager<T>;
begin
  {waits for access to perform}
  Result:= Self;
  TThread.CreateAnonymousThread(procedure
                                begin
                                  FEventAccess.WaitFor(INFINITE);
                                  FLocker.BeginWrite;
                                  try
                                    FEventAccess.ResetEvent;
                                    FConsumers.Remove(AConsumer);
                                  finally
                                    FLocker.EndWrite;
                                    FEventAccess.SetEvent;
                                  end;
                                end).Start;
end;

function TConsumerManager<T>.RemoveAll: IConsumerManager<T>;
var
  LEvent: TEvent;
begin
  {waits for access to perform}
  Result:= Self;
  LEvent:= TEvent.Create(nil, True, False, '');
  try
    TThread.CreateAnonymousThread(procedure
                                  begin
                                    FEventAccess.WaitFor(INFINITE);
                                    FLocker.BeginWrite;
                                    try
                                      FEventAccess.ResetEvent;
                                      FConsumers.Clear;
                                    finally
                                      FLocker.EndWrite;
                                      FEventAccess.SetEvent;
                                      LEvent.SetEvent;
                                    end;
                                  end).Start;
    LEvent.WaitFor(INFINITE);
  finally
    LEvent.Free;
  end;
end;

procedure TConsumerManager<T>.Notify(const AData: T);
begin
  {waits for other operations to notify}
  {calls ONLY from Dispatcher Thread, so already thread safe}
  FEventAccess.WaitFor(INFINITE);
  FLocker.BeginRead;
  try
    FEventAccess.ResetEvent;
    for var LConsumer in FConsumers do
      LConsumer(AData);
  finally
    FLocker.EndRead;
    FEventAccess.SetEvent;
  end;
end;

end.
