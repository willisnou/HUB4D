unit Hub4D.Hub;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Hub4D.Hub.Interfaces,
  Hub4D.Queue,
  Hub4D.Queue.Interfaces,
  Hub4D.Consumer,
  Hub4D.Consumer.Interfaces,
  Hub4D.Messages;

type
  IHub = Hub4D.Hub.Interfaces.IHub<TCustomMessage>;

  TCustomMessage = Hub4D.Messages.TCustomMessage;

  THub = class(TInterfacedObject, IHub)
  strict private
    FQueueList: TDictionary<Cardinal, IQueue<TCustomMessage>>;
    FShutdown: Boolean;

    procedure CreateEmptyQueue(AMsgID: Cardinal);

  public
    procedure Publish(const AData: TCustomMessage);
    function Subscribe(const AProc: TCustomProc<TCustomMessage>; const AMsgID: Cardinal): IHub;
    function Unsubscribe(const AProc: TCustomProc<TCustomMessage>; const AMsgID: Cardinal): IHub;
    function RegisterMessage(const AMsgID: Cardinal): IHub;
    function UnregisterMessage(const AMsgID: Cardinal): IHub;
    function QueueSize(const AMsgID: Cardinal): UInt64;
    function QueueTotalPushed(const AMsgID: Cardinal): UInt64;
    function QueueTotalPopped(const AMsgID: Cardinal): UInt64;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ THub }

constructor THub.Create;
begin
  FQueueList:= TDictionary<Cardinal, IQueue<TCustomMessage>>.Create;
  FShutdown:= False;
end;

destructor THub.Destroy;
begin
  FShutdown:= True;
  for var LItem in FQueueList.ToArray do
    LItem.Value.Finalize;
  FQueueList.Free;

  inherited;
end;

procedure THub.CreateEmptyQueue(AMsgID: Cardinal);
begin
  if FQueueList.ContainsKey(AMsgID) and (not (FShutdown)) then
    Exit;
  FQueueList.Add(AMsgID, TQueue<TCustomMessage>.Create(AMsgID, TConsumerManager<TCustomMessage>.Create));
end;

procedure THub.Publish(const AData: TCustomMessage);
begin
  try
    if not (FShutdown) then
      FQueueList.Items[AData.MsgID].Enqueue(AData);
  except
    on EListError do
      raise Exception.Create('No active queue for this message, first you must register or consume a this message.');
  end;
end;

function THub.Subscribe(const AProc: TCustomProc<TCustomMessage>; const AMsgID: Cardinal): IHub;
begin
  Result:= Self;
  if not (FShutdown) then
  begin
    CreateEmptyQueue(AMsgID);
    FQueueList.Items[AMsgID].Dispatcher.Consumers.Add(AProc);
  end;
end;

function THub.Unsubscribe(const AProc: TCustomProc<TCustomMessage>; const AMsgID: Cardinal): IHub;
begin
  Result:= Self;
  if not (FShutdown) then
    FQueueList.Items[AMsgID].Dispatcher.Consumers.Remove(AProc)
end;

function THub.RegisterMessage(const AMsgID: Cardinal): IHub;
begin
  Result:= Self;
  if not (FShutdown) then
    CreateEmptyQueue(AMsgID);
end;

function THub.UnregisterMessage(const AMsgID: Cardinal): IHub;
begin
  Result:= Self;
  if not (FShutdown) then
  begin
    FQueueList.Items[AMsgID].Finalize;
    FQueueList.Remove(AMsgID);
  end;
end;

function THub.QueueSize(const AMsgID: Cardinal): UInt64;
begin
  Result:= 0;
  if FQueueList.ContainsKey(AMsgID) and (not (FShutdown)) then
    Result:= FQueueList.Items[AMsgID].QueueSize;
end;

function THub.QueueTotalPushed(const AMsgID: Cardinal): UInt64;
begin
  Result:= 0;
  if FQueueList.ContainsKey(AMsgID) and (not (FShutdown)) then
    Result:= FQueueList.Items[AMsgID].QueueTotalPushed;
end;

function THub.QueueTotalPopped(const AMsgID: Cardinal): UInt64;
begin
  Result:= 0;
  if FQueueList.ContainsKey(AMsgID) and (not (FShutdown)) then
    Result:= FQueueList.Items[AMsgID].QueueTotalPopped;
end;

end.
