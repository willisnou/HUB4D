unit Hub4D.Hub.Interfaces;

interface

uses
  Hub4D.Messages;

type
  IHub<T> = interface ['{A301C4D7-9628-4982-8246-2860BE254087}']
    procedure Publish(const AData: TCustomMessage);
    function Subscribe(const AProc: TCustomProc<T>; const AMsgID: Cardinal): IHub<T>;
    function Unsubscribe(const AProc: TCustomProc<T>; const AMsgID: Cardinal): IHub<T>;
    function RegisterMessage(const AMsgID: Cardinal): IHub<T>;
    function UnregisterMessage(const AMsgID: Cardinal): IHub<T>;
    function QueueSize(const AMsgID: Cardinal): UInt64;
    function QueueTotalPushed(const AMsgID: Cardinal): UInt64;
    function QueueTotalPopped(const AMsgID: Cardinal): UInt64;
  end;

implementation

end.
