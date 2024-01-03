unit Hub4D.Dispatcher.Interfaces;

interface

uses
  Hub4D.Consumer.Interfaces;

type
  IDispatcher<T> = interface ['{82A7FCF2-8AAA-460D-8516-2EC5EFCF5C28}']
    function DispatchMessage(const AData: T): IDispatcher<T>;
    function ID: Cardinal;
    function Consumers: IConsumerManager<T>;
    procedure Finalize;
  end;

implementation

end.
