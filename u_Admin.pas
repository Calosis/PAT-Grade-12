unit u_Admin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls;

type
  TfrmAdmin = class(TForm)
    svSide: TSplitView;
    btnBack: TBitBtn;
    pnlApplication: TPanel;
    dbgSource: TDBGrid;
    btnSort: TButton;
    cbxSort: TComboBox;
    btnSearch: TButton;
    edtSearchTitle: TEdit;
    btnEditTitle: TButton;
    btnEditBody: TButton;
    dbtTitle: TDBText;
    dbtBody: TDBText;
    dbtID: TDBText;
    stName: TStaticText;
    btnTotalDonated: TButton;
    btnAverageSignatures: TButton;
    btnRecordDelete: TButton;
    btnOwner: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBackClick(Sender: TObject);
    procedure btnSortClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnEditTitleClick(Sender: TObject);
    procedure btnEditBodyClick(Sender: TObject);
    procedure btnTotalDonatedClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure btnAverageSignaturesClick(Sender: TObject);
    procedure btnRecordDeleteClick(Sender: TObject);
    procedure btnOwnerClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAdmin: TfrmAdmin;

implementation

{$R *.dfm}

uses u_DatabaseConnection, u_Functions, u_Application;

procedure TfrmAdmin.btnAverageSignaturesClick(Sender: TObject);
begin
  // Prevent errors with DBText.
  dbtID.DataSource.Enabled := false;

  Functions.openSQL('SELECT AVG(SignatureCount) AS AvgSig FROM tblObjectives');
  ShowMessage('Average amount of signatures in application: ' +
    IntToStr(dmConnection.qrQuery.Fields[0].AsInteger));

  // Re-enable.
  Functions.openSQL('SELECT * FROM tblObjectives');
  dbtID.DataSource.Enabled := true;
end;

procedure TfrmAdmin.btnBackClick(Sender: TObject);
begin
  // Move.
  frmAdmin.Hide;
  frmApplication.Show;
end;

procedure TfrmAdmin.btnEditBodyClick(Sender: TObject);
var
  sTemp: String;
begin
  // Grab from user.
  sTemp := InputBox('Impactify Admin', 'New Body:', '');

  if (sTemp = NullAsStringValue) then
  begin
    MessageDlg('Please enter a new body.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  Functions.execSQL('UPDATE tblObjectives SET Body = ' + '"' + sTemp + '"' +
    ' WHERE O_ID = ' + dbtID.Caption);
  Functions.openSQL('SELECT * FROM tblObjectives');
end;

procedure TfrmAdmin.btnEditTitleClick(Sender: TObject);
var
  sTemp: String;
begin
  // Grab from user.
  sTemp := InputBox('Impactify Admin', 'New Title:', '');

  if (sTemp = NullAsStringValue) then
  begin
    MessageDlg('Please enter a new title.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);

    Exit;
  end;
  Functions.execSQL('UPDATE tblObjectives SET Title = ' + '"' + sTemp + '"' +
    ' WHERE O_ID = ' + dbtID.Caption);
  Functions.openSQL('SELECT * FROM tblObjectives');
end;

procedure TfrmAdmin.btnOwnerClick(Sender: TObject);
var
  iID: Integer;
begin

  // Ready.
  dmConnection.tblUsers.First;
  dmConnection.tblObjectives.First;
  dmConnection.tblLink.First;

  while NOT(dmConnection.tblLink.Eof) do
  begin

    if dbtID.Caption = dmConnection.tblLink['Objective'] then
    begin

      // Grab owner of objective.\
      iID := dmConnection.tblLink['User'];

      // Find username.
      while NOT(dmConnection.tblUsers.Eof) do
      begin

        if (dmConnection.tblUsers['U_ID'] = iID) then
        begin
          // Notify.
          ShowMessage('Owner is: ' + dmConnection.tblUsers['Username']);

          // We are all done.
          Exit;
        end;
        // Move.
        dmConnection.tblUsers.Next;
      end;
      // Stop.
      Exit;
    end;
    // Move.
    dmConnection.tblLink.Next;
  end;

end;

procedure TfrmAdmin.btnRecordDeleteClick(Sender: TObject);
begin
  // Delete current record.
  Functions.execSQL('DELETE * FROM tblObjectives WHERE O_ID = ' +
    dbtID.Caption);
end;

procedure TfrmAdmin.btnSearchClick(Sender: TObject);
begin
  // Check first.
  if (edtSearchTitle.Text = NullAsStringValue) then
  begin
    MessageDlg('Please enter a title to search for.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    edtSearchTitle.SetFocus;

    Exit;
  end;

  Functions.openSQL('SELECT * FROM tblObjectives WHERE Title LIKE ' + '"%' +
    edtSearchTitle.Text + '%"');

  MessageDlg('Search completed.', TMsgDlgType.mtInformation,
    [TMsgDlgBtn.mbOK], 0);

end;

procedure TfrmAdmin.btnSortClick(Sender: TObject);
begin
  // Check first.
  if (cbxSort.Text = NullAsStringValue) then
  begin
    MessageDlg('Please select a value.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    cbxSort.SetFocus;

    Exit;
  end;

  // Sort.
  Functions.openSQL('SELECT * FROM tblObjectives ORDER BY O_ID ' +
    cbxSort.Text);
end;

procedure TfrmAdmin.btnTotalDonatedClick(Sender: TObject);
begin
  // Prevent errors with DBText.
  dbtID.DataSource.Enabled := false;

  // Sum.
  Functions.openSQL
    ('SELECT SUM(DonationAmount) AS TotalDonated FROM tblObjectives');
  // Notify.

  ShowMessage('Total donations in platform: ' +
    FloatToStrF(dmConnection.qrQuery.Fields[0].asFloat, ffCurrency, 8, 2));

  // Re-enable.
  Functions.openSQL('SELECT * FROM tblObjectives');
  dbtID.DataSource.Enabled := true;
end;

procedure TfrmAdmin.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // Set style sheet so Windows knows its another "window".

  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfrmAdmin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Fix multi form issues.
  Application.Terminate;
end;

procedure TfrmAdmin.FormCreate(Sender: TObject);
begin
  // Form setup.
  Functions.disableSize(frmAdmin);
  dbgSource.DataSource := dmConnection.dsrSQL;
end;

procedure TfrmAdmin.FormHide(Sender: TObject);
begin
  // Fix DBText error.
  dbtID.DataSource.Enabled := false;
end;

procedure TfrmAdmin.FormShow(Sender: TObject);
begin
  // Always should be centre.
  Functions.sizeCentre(frmAdmin);

  // Load.
  Functions.openSQL('SELECT * FROM tblObjectives');

  // Clear.
  edtSearchTitle.Clear;

  // Set.
  dbtTitle.DataSource := dmConnection.dsrSQL;
  dbtBody.DataSource := dmConnection.dsrSQL;
  dbtID.DataSource := dmConnection.dsrSQL;
  dbtTitle.DataField := 'Title';
  dbtBody.DataField := 'Body';
  dbtID.DataField := 'O_ID';
  dbtID.DataSource.Enabled := true;
end;

end.
