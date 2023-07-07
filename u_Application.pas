unit u_Application;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels,
  Vcl.WinXCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TfrmApplication = class(TForm)
    svSide: TSplitView;
    btnLogin: TBitBtn;
    btnRegister: TBitBtn;
    pnlApplication: TPanel;
    imgMenu: TImage;
    btnAdmin: TBitBtn;
    stName: TStaticText;
    redInform: TRichEdit;
    btnReset: TButton;
    procedure FormCreate(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);

  private
  public
    { Public declarations }
    bShown: Boolean;
  end;

var
  frmApplication: TfrmApplication;

implementation

{$R *.dfm}

uses u_Functions, u_Register, u_Login, u_DatabaseConnection;

procedure TfrmApplication.btnLoginClick(Sender: TObject);
begin
  // Move form.
  frmApplication.Hide;
  frmLogin.Show;
end;

procedure TfrmApplication.btnRegisterClick(Sender: TObject);
begin
  // Move between forms.
  frmApplication.Hide;
  frmRegister.Show;
end;

procedure TfrmApplication.btnResetClick(Sender: TObject);
begin
  // Run db reset.
  Functions.resetDB;
end;

procedure TfrmApplication.FormCreate(Sender: TObject);
begin

  // Don't allow resize.
  Functions.disableSize(frmApplication);

  // Set some basics.
  redInform.Enabled := false;

  stName.Alignment := taCenter;
  redInform.Alignment := taCenter;

end;

procedure TfrmApplication.FormShow(Sender: TObject);
begin
  // New window should be centre.
  Functions.sizeCentre(frmApplication);

  // Set
  bShown := true;
end;

procedure TfrmApplication.imgMenuClick(Sender: TObject);
begin

  // Sliding panel logic.
  if (bShown = true) then
  begin

    svSide.Opened := false;

    pnlApplication.BevelInner := bvNone;
    pnlApplication.BevelKind := bkNone;
    pnlApplication.BevelOuter := bvNone;
    bShown := false;

  end
  else
  begin

    svSide.Opened := true;

    pnlApplication.BevelInner := bvNone;
    pnlApplication.BevelKind := bkNone;
    pnlApplication.BevelOuter := bvRaised;
    bShown := true;

  end;
end;

end.
