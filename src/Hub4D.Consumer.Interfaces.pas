unit Hub4D.Consumer.Interfaces;

interface

uses
  System.Generics.Collections,
  Hub4D.Messages;

type
  IConsumerManager<T> = interface ['{DBF8C530-425B-42F5-AC16-9FFEBE43E37C}']
    function List: TList<TCustomProc<T>>;
    function Add(const AConsumer: TCustomProc<T>): IConsumerManager<T>;
    function Remove(const AConsumer: TCustomProc<T>): IConsumerManager<T>;
    function RemoveAll: IConsumerManager<T>;
    procedure Notify(const AData: T);
  end;

implementation

end.
