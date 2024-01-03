unit Hub4D.View.Sample;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Hub4D.Hub;

type
  TSpamThread = class(TThread)
    protected
      procedure Execute; override;
    public
      constructor Create;
  end;

  TObserverThread = class(TThread)
    protected
      procedure Execute; override;
    public
      constructor Create;
  end;


  TfrmSample = class(TForm)
    btnSubscribe1: TButton;
    btnSubscribe2: TButton;
    mmSubscribe1: TMemo;
    mmSubscribe2: TMemo;
    mmSubscribe3: TMemo;
    lbSubscribe1: TLabel;
    lbSubscribe2: TLabel;
    lbSubscribe3: TLabel;
    btnSubscribe3: TButton;
    edtPublisher: TEdit;
    lbPublisher: TLabel;
    btnPublish: TButton;
    cbAutoPublish: TCheckBox;
    lbTotalPushed: TLabel;
    lbTotalPopped: TLabel;
    lbQueueSize: TLabel;
    cbStatistics: TCheckBox;
    btnUnsubscribe1: TButton;
    btnUnsubscribe2: TButton;
    btnUnsubscribe3: TButton;
    btnSubscribeGhost: TButton;
    procedure btnSubscribe1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPublishClick(Sender: TObject);
    procedure btnSubscribe2Click(Sender: TObject);
    procedure btnSubscribe3Click(Sender: TObject);
    procedure cbAutoPublishClick(Sender: TObject);
    procedure cbStatisticsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnUnsubscribe1Click(Sender: TObject);
    procedure btnUnsubscribe2Click(Sender: TObject);
    procedure btnUnsubscribe3Click(Sender: TObject);
  private
    FShutdown: Boolean;
  public
    procedure Subscribe1(AData: TCustomMessage);
    procedure Subscribe2(AData: TCustomMessage);
    procedure Subscribe3(AData: TCustomMessage);
  end;

var
  frmSample: TfrmSample;

const
  WM_PUBLISH = 1030;

implementation

var
  Router: IHub;
  FSpamThread: TSpamThread;
  FObserverThread: TObserverThread;

{$R *.dfm}

procedure TfrmSample.FormCreate(Sender: TObject);
begin
  Router:= THub.Create;
  Router.RegisterMessage(WM_PUBLISH);
  FSpamThread    := TSpamThread.Create;
  FObserverThread:= TObserverThread.Create;
  FShutdown:= False;
end;

procedure TfrmSample.FormDestroy(Sender: TObject);
begin
  FShutdown:= True;
  FSpamThread.Terminate;
  FSpamThread.Free;
  FObserverThread.Terminate;
  FObserverThread.Free;
end;

procedure TfrmSample.btnPublishClick(Sender: TObject);
var
  LPayload: TCustomMessage;
begin
  LPayload.Data:= TEncoding.UTF8.GetBytes(edtPublisher.Text);
  LPayload.MsgID:= WM_PUBLISH;
  Router.Publish(LPayload);
end;

procedure TfrmSample.btnSubscribe1Click(Sender: TObject);
begin
  Router.Subscribe(Subscribe1, WM_PUBLISH);
end;

procedure TfrmSample.btnSubscribe2Click(Sender: TObject);
begin
  Router.Subscribe(Subscribe2, WM_PUBLISH);
end;

procedure TfrmSample.btnSubscribe3Click(Sender: TObject);
begin
  Router.Subscribe(Subscribe3, WM_PUBLISH);
end;

procedure TfrmSample.Subscribe1(AData: TCustomMessage);
begin
  mmSubscribe1.Lines.Add((TEncoding.UTF8.GetString(AData.Data)));
end;

procedure TfrmSample.Subscribe2(AData: TCustomMessage);
begin
  mmSubscribe2.Lines.Add((TEncoding.UTF8.GetString(AData.Data)));
end;

procedure TfrmSample.Subscribe3(AData: TCustomMessage);
begin
  mmSubscribe3.Lines.Add((TEncoding.UTF8.GetString(AData.Data)));
end;

procedure TfrmSample.btnUnsubscribe1Click(Sender: TObject);
begin
  Router.Unsubscribe(subscribe1, WM_PUBLISH);
end;

procedure TfrmSample.btnUnsubscribe2Click(Sender: TObject);
begin
  Router.Unsubscribe(subscribe2, WM_PUBLISH);
end;

procedure TfrmSample.btnUnsubscribe3Click(Sender: TObject);
begin
  Router.Unsubscribe(subscribe3, WM_PUBLISH);
end;

procedure TfrmSample.cbAutoPublishClick(Sender: TObject);
begin
  if cbAutoPublish.Checked then
    FSpamThread.Resume
  else if not (cbAutoPublish.Checked) then
    FSpamThread.Suspend;
end;

procedure TfrmSample.cbStatisticsClick(Sender: TObject);
begin
  if cbStatistics.Checked then
    FObserverThread.Resume
  else if not (cbStatistics.Checked) then
    FObserverThread.Suspend;
end;

{ TSpamThread }

constructor TSpamThread.Create;
begin
  inherited Create(True);
end;

procedure TSpamThread.Execute;
var
  LMsg: TCustomMessage;
begin
  while not (Suspended) and not (Terminated) do
  begin
    if not (Hub4D.View.Sample.frmSample.FShutdown) then
    begin
      LMsg.Data:= TEncoding.UTF8.GetBytes(Random(1000).ToString);
      LMsg.MsgID:= WM_PUBLISH;
      Router.Publish(LMsg);
      Sleep(10);
    end;
  end;
end;

{ TObserverThread }

constructor TObserverThread.Create;
begin
  inherited Create(True);
end;

procedure TObserverThread.Execute;
begin
  while not (Suspended) and not (Terminated) do
  begin
    Synchronize(TThread.Current, procedure
                                 begin
                                   if not (Hub4D.View.Sample.frmSample.FShutdown) then
                                   begin
                                     Hub4D.View.Sample.frmSample.lbTotalPushed.Caption:= Format('Total pushed items: %d',
                                                                                            [Router.QueueTotalPushed(1030)]);

                                     Hub4D.View.Sample.frmSample.lbTotalPopped.Caption:= Format('Total popped items: %d',
                                                                                            [Router.QueueTotalPopped(1030)]);

                                     Hub4D.View.Sample.frmSample.lbQueueSize.Caption:= Format('Queue Size: %d',
                                                                                            [Router.QueueSize(1030)]);
                                   end;
                                 end);
  end;
end;

end.
