unit Hub4D.Messages;

interface

uses
  System.SysUtils,
  Winapi.Messages;

type
  PCustomMessage = ^TCustomMessage; {safe way to work with memory management}
  TCustomMessage = record
    Data : TBytes;
    MsgID: Cardinal;
  end;

  TCustomProc<T> = procedure(AMsg: T) of object; {must be a procedure of object instead TProc<T> to hold reference id of subscribers}

const
  C_DEFAULT_MAX_QUEUE_SIZE = 40000; {40k messages in total}
  C_DEFAULT_POP_TIMEOUT    = 10;    {10ms Pop timeout check}

  WM_ENQUEUE = WM_USER + 1;

implementation

end.
