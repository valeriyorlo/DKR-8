unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, MMSystem, DateUtils, LCLType;

type

  CompInfo=record
    index,top,left,width,height,fontsize:integer;
  end;
  complist=array of CompInfo;

  { TMform }

  TMform = class(TForm)
    Start_kino: TButton;
    Stop_Kino: TButton;
    Chistka: TButton;
    Minuts: TEdit;
    Secunds: TEdit;
    trimer: TLabel;
    Minuts_txt: TLabel;
    Secunds_txt: TLabel;
    Timer: TTimer;
    procedure Start_kinoClick(Sender: TObject);
    procedure Stop_KinoClick(Sender: TObject);
    procedure ChistkaClick(Sender: TObject);
    procedure MinutsChange(Sender: TObject);
    procedure MinutsKeyPress(Sender: TObject; var Key: char);
    procedure SecundsChange(Sender: TObject);
    procedure SecundsKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure PicClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { private declarations }
    TimerStarted: Boolean;
    DefWidth,defHeight:integer;
    clist:complist;
    FStartTime: TDateTime;
    FDuration: TDateTime;
    FStopTime: TDateTime;
    TargetTime: TDateTime;
    RemainingTime: TDateTime;
    FSoundFile: string;
  public
    { public declarations }
     procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

var
  Mform: TMform;

implementation
uses math;
{$R *.lfm}
{ TMform }

procedure TMform.FormCreate(Sender: TObject);
var i:integer;
begin
  defwidth:=width;
  defheight:=height;
  for i:= 0 to ComponentCount-1 do
    if (Components[i].Classname ='TCheckBox')
    or (Components[i].Classname ='TButton')
    or (Components[i].Classname ='TEdit')
    or (Components[i].Classname ='TComboBox')
    or (Components[i].Classname ='TLabel') then begin
      setlength(clist,Length(clist)+1);
      clist[Length(clist)-1].top:=(Components[i] as tcontrol).top;
      clist[Length(clist)-1].left:=(Components[i]as tcontrol).left;
      clist[Length(clist)-1].width:=(Components[i] as tcontrol).width;
      clist[Length(clist)-1].height:=(Components[i]as tcontrol).height;
      clist[Length(clist)-1].fontsize:=(Components[i]as tcontrol).font.Size;
      clist[Length(clist)-1].index:=i;
    end;
Minuts.MaxLength := 2;
Secunds.MaxLength := 2;
TimerStarted := False;
KeyPreview := True;
FSoundFile := 'ajjfon_-_budilnik_radar_76666078.wav';
  OnKeyDown := @FormKeyDown;
   RemainingTime := EncodeTime(23, 59, 59, 0);
   trimer.Caption := FormatDateTime('hh:nn:ss', RemainingTime);
end;

procedure TMform.PicClick(Sender: TObject);
begin

end;
procedure TMform.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Close;
  end;
end;
procedure TMform.FormResize(Sender: TObject);
var i:integer;
begin
  For i:=0 to length(clist)-1 do begin
    (components[clist[i].index] as tcontrol).Top:=round(clist[i].top*height/defheight);
    (components[clist[i].index] as tcontrol).height:=round(clist[i].height*height/defheight);
    (components[clist[i].index] as tcontrol).left:=round(clist[i].left*width/defwidth);
    (components[clist[i].index] as tcontrol).width:=round(clist[i].width*width/defwidth);
    (components[clist[i].index] as tcontrol).font.Size:=round(clist[i].fontsize*min(width/defwidth,height/defheight));
  end;
end;

procedure TMform.Start_kinoClick(Sender: TObject);
var
  Minutes, Seconds: Integer;
begin
  if (Minuts.Text = '') and (Secunds.Text = '') then
  begin
    ShowMessage('Пожалуйста, заполните хотя бы одно поле времени.');
  end;

  if TryStrToInt(Minuts.Text, Minutes) and TryStrToInt(Secunds.Text, Seconds) then
  begin
    FStartTime := Now;
    FDuration := Minutes / 1440 + Seconds / 86400;
    TargetTime := EncodeTime(0, Minutes, Seconds, 0);
    RemainingTime := TargetTime;
    Timer.Enabled := True;
    TimerStarted := True;
  end
  else
  begin
    ShowMessage('Пожалуйста, введите корректное время.');
  end;
end;

procedure TMform.Stop_KinoClick(Sender: TObject);
begin
  Timer.Enabled := False;
  FStopTime := Now;


  if FSoundFile <> '' then
  begin

    sndPlaySound(PChar(FSoundFile), SND_ASYNC);
  end;

  ShowMessage('Таймер остановлен');
end;

procedure TMform.ChistkaClick(Sender: TObject);
begin
  Minuts.Clear;
  Secunds.Clear;
end;

procedure TMform.MinutsKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', #46]) then
  begin
    Key := #0;
  end;
end;


procedure TMform.SecundsKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', #46]) then
  begin
    Key := #0;
  end;
end;

procedure TMform.MinutsChange(Sender: TObject);
var f : integer;
begin
  if Minuts.Text <> '' then
  begin
   f := strtoint(Minuts.text);
   if f <= 0 then
   f := 0;
   if f >= 59 then
   f := 59;
   Minuts.text := inttostr(f);
  end;
end;

procedure TMform.SecundsChange(Sender: TObject);
var i : integer;
begin
  if Secunds.Text <> '' then
  begin
   i := strtoint(Secunds.text);
   if i <= 0 then
   i := 0;
   if i >= 59 then
   i := 59;
   Secunds.text := inttostr(i);
  end;
  end;


procedure TMform.TimerTimer(Sender: TObject);
var
  ElapsedTime: TDateTime;
begin
  if not TimerStarted then
    Exit;

  ElapsedTime := Now - FStartTime;

  if MilliSecondsBetween(Now, FStartTime) < MilliSecondsBetween(0, FDuration) then
  begin
    RemainingTime := IncSecond(RemainingTime, -1);
    trimer.Caption := FormatDateTime('hh:nn:ss', RemainingTime);
  end
  else
  begin
    Timer.Enabled := False;
    TimerStarted := False;
    if FSoundFile <> '' then
    begin
      sndPlaySound(PChar(FSoundFile), SND_ASYNC or SND_NODEFAULT);
    end;
    ShowMessage('Время вышло!');
  end;
end;
end.

