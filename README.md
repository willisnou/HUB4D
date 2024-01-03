<p align="center">
  <img src="https://github.com/willisnou/Mailer4D/blob/main/resources/logo%20JPG.jpg"><br>
  <b>Hub4D</b> is a simple message hub concept to exchange data over message events (like <a href="https://learn.microsoft.com/en-us/windows/win32/learnwin32/window-messages">Windows Messages</a>), being multithread and thread-safe.
</p>

## Considerations
`[Older Delphi]` For older Delphi versions (RAD Studio 10.4.1 and before) adaptations are needed because of [`TLightweightMREW`](https://docwiki.embarcadero.com/Libraries/Sydney/en/System.SyncObjs.TLightweightMREW) and other minor stuffs.

## Instalation
`[Optional]` [**Boss**](https://github.com/HashLoad/boss) instalation:
```
boss install github.com/willisnou/Hub4D
```
`[Manual]` For manual installation add the `../Hub4D/src` directory on library path in **Tools** > **Options** > **Language** > **Delphi** > **Library** > **Library Path** _or_ add the files manually to the project in **Project** > **Add to Project...** menu.

## Getting started
```delphi
uses Hub4D.Hub;

var
  MessageHub: IHub;

const
  WM_CUSTOM_MESSAGE = WM_USER + 1025;

begin
  MessageHub:= THub.Create;
end;
```

## Custom data types
To improve memory managment, avoid memory leaks and work with ref. counter, the following custom types (for concept) is used:
```delphi
type
  PCustomMessage = ^TCustomMessage;
  TCustomMessage = record
    Data : TBytes;
    MsgID: Cardinal;
  end;

  TCustomProc<T> = procedure(AMsg: T) of object; {must be a procedure of object instead TProc<T> to hold reference id of subscribers}
```
Check [`Hub4D.Messages`](https://github.com/willisnou/Hub4D/blob/main/src/Hub4D.Messages.pas).

## Register a message (to create entry queue)
```delphi
begin
  MessageHub.RegisterMessage(WM_CUSTOM_MESSAGE);
end;
```

## Subscribe (a method) to receive incoming data
Define a procedure which receive `TCustomMessage` and apply then to `Subscribe` method.
```delphi
procedure OnCustomMessage(AMsg: TCustomMessage);
begin
  //TODO
end;

begin
  MessageHub.Subscribe(OnCustomMessage, WM_CUSTOM_MESSAGE);
end;
```

## Publish a message (to all subscribed methods)
```delphi
var
  LMsg: TCustomMessage;
begin
  LMsg.Data:= System.SysUtils.TEncoding.UTF8.GetBytes('A data to transfer');
  LMsg.MsgID:= WM_CUSTOM_MESSAGE;
  MessageHub.Publish(LMsg);
end;
```
The above example will send an asynchronous message to all subscribed methods.

## Sample code
Check out the sample code available with a simple user case.
<p align="left">
  <img src="https://github.com/willisnou/Hub4D/blob/main/resources/sample-project.png"><br>
</p>
Issues, questions or suggestions are apreciated.
