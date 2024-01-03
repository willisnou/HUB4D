unit Hub4D.Queue.Interfaces;

interface

uses
  Hub4D.Dispatcher.Interfaces;

type
  IQueue<T: Record> = interface ['{5B177361-F412-4A13-80B0-1EB8805ED3FA}']
    function ID: Cardinal;
    function Enqueue(const AData: T): IQueue<T>;
    function Dispatcher: IDispatcher<T>;
    function QueueSize: UInt64;
    function QueueTotalPushed: UInt64;
    function QueueTotalPopped: UInt64;
    procedure Finalize;
  end;

implementation

end.
