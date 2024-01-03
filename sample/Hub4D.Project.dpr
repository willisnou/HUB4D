program Hub4D.Project;

uses
  Vcl.Forms,
  Hub4D.View.Sample in 'Hub4D.View.Sample.pas' {frmSample},
  Hub4D.Hub in '..\src\Hub4D.Hub.pas',
  Hub4D.Hub.Interfaces in '..\src\Hub4D.Hub.Interfaces.pas',
  Hub4D.Queue.Interfaces in '..\src\Hub4D.Queue.Interfaces.pas',
  Hub4D.Queue in '..\src\Hub4D.Queue.pas',
  Hub4D.Messages in '..\src\Hub4D.Messages.pas',
  Hub4D.Dispatcher.Interfaces in '..\src\Hub4D.Dispatcher.Interfaces.pas',
  Hub4D.Consumer.Interfaces in '..\src\Hub4D.Consumer.Interfaces.pas',
  Hub4D.Consumer in '..\src\Hub4D.Consumer.pas',
  Hub4D.Dispatcher in '..\src\Hub4D.Dispatcher.pas',
  Hub4D.CustomThreadSafeQueue in '..\src\Hub4D.CustomThreadSafeQueue.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown:= True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSample, frmSample);
  Application.Run;
end.
