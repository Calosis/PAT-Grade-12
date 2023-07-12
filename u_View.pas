unit u_View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.WinXCtrls, Vcl.Imaging.pngimage;

type
  TfrmView = class(TForm)
    svSide: TSplitView;
    btnBack: TBitBtn;
    pnlHold: TPanel;
    imgMenu: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormShow(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmView: TfrmView;

implementation

{$R *.dfm}

uses u_Functions;

procedure TfrmView.CreateParams(var Params: TCreateParams);
begin
  inherited;

  // Set style sheet so Windows knows its another "window".
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfrmView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Fix multi form issues.
  Application.Terminate;
end;

procedure TfrmView.FormCreate(Sender: TObject);
begin
  // Form setup.
  Functions.disableSize(frmView);
end;

procedure TfrmView.FormShow(Sender: TObject);
begin
  // Always should be centre.
  Functions.sizeCentre(frmView);
end;

procedure TfrmView.imgMenuClick(Sender: TObject);
begin
  // Sliding panel logic.
  if (bShown = true) then
  begin
    svSide.Opened := false;

    rpHold.BevelInner := bvNone;
    rpHold.BevelKind := bkNone;
    rpHold.BevelOuter := bvNone;
    bShown := false;

    // Set new size
    rpHold.Width := 950;
    rpHold.Alignment := taCenter;
    rpHold.Align := alRight;

  end
  else
  begin
    svSide.Opened := true;

    rpHold.BevelInner := bvNone;
    rpHold.BevelKind := bkNone;
    rpHold.BevelOuter := bvRaised;
    bShown := true;

    // Set old size
    rpHold.Width := 600;
    rpHold.Alignment := taCenter;
    rpHold.Align := alClient;

  end;
end;

end.
