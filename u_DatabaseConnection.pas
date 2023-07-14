unit u_DatabaseConnection;

interface

uses
  System.SysUtils, System.Classes, ADODB, DB;

type
  TdmConnection = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    conApplication: TADOConnection;

    tblUsers, tblObjectives, tblLink, tblSignatures: TADOTable;
    dsrUsers, dsrObjectives, dsrLink, dsrSignatures, dsrSQL: TDataSource;
    qrQuery: TADOQuery;

  end;

var
  dmConnection: TdmConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TdmConnection.DataModuleCreate(Sender: TObject);
begin

  // Dynamically create modules on form. (TADOConnection)
  conApplication := TADOConnection.Create(dmConnection);

  // Dynamically create modules on form. (TADOTable)
  tblUsers := TADOTable.Create(dmConnection);
  tblObjectives := TADOTable.Create(dmConnection);
  tblLink := TADOTable.Create(dmConnection);
  tblSignatures := TADOTable.Create(dmConnection);

  // Dynamically create modules on form. (DataSource)
  dsrUsers := TDataSource.Create(dmConnection);
  dsrObjectives := TDataSource.Create(dmConnection);
  dsrLink := TDataSource.Create(dmConnection);
  dsrSignatures := TDataSource.Create(dmConnection);

  dsrSQL := TDataSource.Create(dmConnection);

  // Dynamically create modules on form. (TADOQuery)
  qrQuery := TADOQuery.Create(dmConnection);

  // Ready connection string.
  conApplication.Close;

  // Win32/Debug.
  conApplication.ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' +
    ExtractFilePath(ParamStr(0)) + 'dbmApplication.mdb' +
    '; Persist Security Info=False';

  // Define prop of connection.
  conApplication.LoginPrompt := False;
  conApplication.Open;

  // Link tables.
  tblUsers.Connection := conApplication;
  tblUsers.TableName := 'tblUsers';

  tblObjectives.Connection := conApplication;
  tblObjectives.TableName := 'tblObjectives';

  tblLink.Connection := conApplication;
  tblLink.TableName := 'tblLink';

  tblSignatures.Connection := conApplication;
  tblSignatures.TableName := 'tblSignatures';

  // SQL init.
  qrQuery.Connection := conApplication;
  dsrSQL.DataSet := qrQuery;

  // Set source of dataset.
  dsrUsers.DataSet := tblUsers;
  dsrObjectives.DataSet := tblObjectives;
  dsrLink.DataSet := tblLink;
  dsrSignatures.DataSet := tblSignatures;

  // Ready for use.
  tblUsers.Open;
  tblObjectives.Open;
  tblLink.Open;
  tblSignatures.Open;

end;

end.
