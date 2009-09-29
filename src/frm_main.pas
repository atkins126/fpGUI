unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, fpg_base, fpg_main, fpg_form, fpg_panel, fpg_tab,
  fpg_tree, fpg_splitter, fpg_menu, fpg_memo, fpg_button, HelpFile;

type

  TMainForm = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: MainForm}
    bvlStatusBar: TfpgBevel;
    bvlBody: TfpgBevel;
    PageControl1: TfpgPageControl;
    tsContents: TfpgTabSheet;
    tsIndex: TfpgTabSheet;
    tsSearch: TfpgTabSheet;
    tsHistory: TfpgTabSheet;
    tvContents: TfpgTreeView;
    tvIndex: TfpgTreeView;
    Splitter1: TfpgSplitter;
    Memo1: TfpgMemo;
    MainMenu: TfpgMenuBar;
    miFile: TfpgPopupMenu;
    miSettings: TfpgPopupMenu;
    miBookmarks: TfpgPopupMenu;
    miHelp: TfpgPopupMenu;
    btnIndex: TfpgButton;
    {@VFD_HEAD_END: MainForm}
    FHelpFile: TfpgString;
    Files: TList; // current open help files.
    procedure   MainFormShow(Sender: TObject);
    procedure   miFileQuitClicked(Sender: TObject);
    procedure   miFileOpenClicked(Sender: TObject);
    procedure   miHelpProdInfoClicked(Sender: TObject);
    procedure   miHelpAboutFPGui(Sender: TObject);
    procedure   SetHelpFile(const AValue: TfpgString);
    procedure   btnShowIndex(Sender: TObject);
    procedure   FileOpen;
    function    OpenFile(const AFileNames: string): boolean;
    procedure   OnHelpFileLoadProgress(n, outof: integer; AMessage: string);
    procedure   LoadNotes(AHelpFile: THelpFile);
    procedure   LoadContents;
    // Used in loading contents
    procedure AddChildNodes(AHelpFile: THelpFile; AParentNode: TfpgTreeNode; ALevel: longint; var ATopicIndex: longint );

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   AfterCreate; override;
//    property    HelpFile: TfpgString read FHelpFile write SetHelpFile;
  end;

{@VFD_NEWFORM_DECL}

const
  cTitle = 'fpGUI Help Viewer';

implementation

uses
  fpg_dialogs, fpg_constants, nvUtilities, HelpTopic;


{@VFD_NEWFORM_IMPL}

procedure TMainForm.MainFormShow(Sender: TObject);
begin
  bvlBody.Realign;

end;

procedure TMainForm.miFileQuitClicked(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.miFileOpenClicked(Sender: TObject);
begin
  FileOpen;
end;

procedure TMainForm.miHelpProdInfoClicked(Sender: TObject);
begin
  TfpgMessageDialog.Information('Product Information', 'Created by Graeme Geldenhuys');
end;

procedure TMainForm.miHelpAboutFPGui(Sender: TObject);
begin
  TfpgMessageDialog.AboutFPGui;
end;

procedure TMainForm.SetHelpFile(const AValue: TfpgString);
begin
  if FHelpFile = AValue then
    Exit; //==>
  FHelpFile := AValue;
end;

procedure TMainForm.btnShowIndex(Sender: TObject);
var
  Count: integer;
  i: integer;
  s: TfpgString;
begin
//
end;

procedure TMainForm.FileOpen;
var
  dlg: TfpgFileDialog;
begin
  dlg := TfpgFileDialog.Create(nil);
  try
    dlg.WindowTitle := 'Open Help File';
    dlg.Filter := 'Help Files (*.hlp, *.inf)|*.inf;*.hlp ';
    // and a catch all filter
    dlg.Filter := dlg.Filter + '|(' + rsAllFiles + ' (*)|*';

    if dlg.RunOpenFile then
    begin
//      FHelpFile := dlg.FileName;
      OpenFile(dlg.Filename);
      { TODO -oGraeme : Add support for multiple files. }
//      OpenFile( ListToString( dlg.FileNames, '+' ) );
    end;
  finally
    dlg.Free;
  end;
end;

function TMainForm.OpenFile(const AFileNames: string): boolean;
var
  lFilename: string;
  FullFilePath: string;
  HelpFile: THelpFile;
  FileIndex: integer;
begin
  ProfileEvent('OpenFile');
  lFilename := AFilenames;
  ProfileEvent( 'File: ' + lFileName );
  FullFilePath := ExpandFileName(lFilename);
  ProfileEvent( '  Full path: ' + FullFilePath );
  ProfileEvent( '  Loading: ' + lFilename );

  HelpFile := THelpFile.Create(lFileName, @OnHelpFileLoadProgress);
  Files.Add(HelpFile);

//  WindowTitle := cTitle + ' - ' + THelpFile( Files[ 0 ] ).Title;
  WindowTitle := cTitle + ' - ' + HelpFile.Title;
  fpgApplication.ProcessMessages;

  for FileIndex:= 0 to Files.Count - 1 do
  begin
    HelpFile := THelpFile(Files[ FileIndex ]);
    LoadNotes( HelpFile );
  end;

  LoadContents;
end;

procedure TMainForm.OnHelpFileLoadProgress(n, outof: integer; AMessage: string);
begin
  //
end;

procedure TMainForm.LoadNotes(AHelpFile: THelpFile);
begin
//  NotesFileName:= ChangeFileExt( HelpFile.FileName, '.nte' );

end;

procedure TMainForm.LoadContents;
var
  FileIndex: integer;
  HelpFile: THelpFile;
  TopicIndex: integer;
  Node: TfpgTreeNode;
  Topic: TTopic;
begin
  ProfileEvent( 'Load contents outline' );

  tvContents.RootNode.Clear;

  ProfileEvent( 'Loop files' );

  Node := nil;

  for FileIndex:= 0 to Files.Count - 1 do
  begin
    HelpFile:= THelpFile(Files[ FileIndex ]);
    ProfileEvent( 'File ' + IntToStr( FileIndex ) );
    TopicIndex:= 0;
    while TopicIndex < HelpFile.TopicCount do
    begin
      Topic := HelpFile.Topics[ TopicIndex ];
      if Topic.ShowInContents then
      begin
        if Topic.ContentsLevel = 1 then
        begin
          Node := tvContents.RootNode.AppendText(Topic.Title);
          Node.Data := Topic;
          inc( TopicIndex );
        end
        else
        begin
          // child nodes
          AddChildNodes( HelpFile,
                         Node,
                         Topic.ContentsLevel,
                         TopicIndex );
          Node := nil;

        end;
      end
      else
      begin
        inc( TopicIndex );
      end;
    end;
  end;
end;

procedure TMainForm.AddChildNodes(AHelpFile: THelpFile; AParentNode: TfpgTreeNode;
  ALevel: longint; var ATopicIndex: longint);
var
  Topic: TTopic;
  Node: TfpgTreeNode;
begin
  ProfileEvent('SubNode with TopicIndex of ' + IntToStr(ATopicIndex));

  Node := nil;
  while ATopicIndex < AHelpFile.TopicCount do
  begin
    Topic := AHelpFile.Topics[ ATopicIndex ];
    if Topic.ShowInContents then
    begin
      if Topic.ContentsLevel < ALevel then
        break;

      if Topic.ContentsLevel = ALevel then
      begin
        Node := AParentNode.AppendText(Topic.Title);
        Node.Data := Topic;
        inc( ATopicIndex );
      end
      else
      begin
        AddChildNodes( AHelpFile,
                       Node,
                       Topic.ContentsLevel,
                       ATopicIndex );
        Node := nil;
      end
    end
    else
    begin
      inc( ATopicIndex );
    end;
  end;  { while }
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnShow  := @MainFormShow;
  Files := TList.Create;
end;

destructor TMainForm.Destroy;
begin
  Files.Free;
  inherited Destroy;
end;

procedure TMainForm.AfterCreate;
begin
  {%region 'Auto-generated GUI code' -fold}
  {@VFD_BODY_BEGIN: MainForm}
  Name := 'MainForm';
  SetPosition(602, 274, 560, 360);
  WindowTitle := 'fpGUI Help Viewer';
  WindowPosition := wpUser;

  bvlStatusBar := TfpgBevel.Create(self);
  with bvlStatusBar do
  begin
    Name := 'bvlStatusBar';
    SetPosition(0, 340, 559, 20);
    Anchors := [anLeft,anRight,anBottom];
    Style := bsLowered;
  end;

  bvlBody := TfpgBevel.Create(self);
  with bvlBody do
  begin
    Name := 'bvlBody';
    SetPosition(0, 31, 559, 308);
    Anchors := [anLeft,anRight,anTop,anBottom];
    Shape := bsSpacer;
  end;

  PageControl1 := TfpgPageControl.Create(bvlBody);
  with PageControl1 do
  begin
    Name := 'PageControl1';
    SetPosition(0, 0, 222, 300);
    ActivePageIndex := 1;
    TabOrder := 0;
    Align := alLeft;
  end;

  tsContents := TfpgTabSheet.Create(PageControl1);
  with tsContents do
  begin
    Name := 'tsContents';
    SetPosition(3, 24, 216, 273);
    Text := 'Contents';
  end;

  tsIndex := TfpgTabSheet.Create(PageControl1);
  with tsIndex do
  begin
    Name := 'tsIndex';
    SetPosition(3, 24, 216, 273);
    Text := 'Index';
  end;

  tsSearch := TfpgTabSheet.Create(PageControl1);
  with tsSearch do
  begin
    Name := 'tsSearch';
    SetPosition(3, 24, 216, 273);
    Text := 'Search';
  end;

  tsHistory := TfpgTabSheet.Create(PageControl1);
  with tsHistory do
  begin
    Name := 'tsHistory';
    SetPosition(3, 24, 216, 273);
    Text := 'History';
  end;

  tvContents := TfpgTreeView.Create(tsContents);
  with tvContents do
  begin
    Name := 'tvContents';
    SetPosition(23, 44, 158, 172);
    FontDesc := '#Label1';
    ShowImages := True;
    TabOrder := 0;
    Align := alClient;
  end;

  tvIndex := TfpgTreeView.Create(tsIndex);
  with tvIndex do
  begin
    Name := 'tvIndex';
    SetPosition(16, 28, 182, 196);
    FontDesc := '#Label1';
    TabOrder := 0;
    Align := alClient;
  end;

  Splitter1 := TfpgSplitter.Create(bvlBody);
  with Splitter1 do
  begin
    Name := 'Splitter1';
    SetPosition(228, 4, 8, 284);
    Align := alLeft;
  end;

  Memo1 := TfpgMemo.Create(bvlBody);
  with Memo1 do
  begin
    Name := 'Memo1';
    SetPosition(276, 36, 244, 232);
    FontDesc := '#Edit1';
    TabOrder := 2;
    Align := alClient;
  end;

  MainMenu := TfpgMenuBar.Create(self);
  with MainMenu do
  begin
    Name := 'MainMenu';
    SetPosition(0, 0, 560, 24);
    Anchors := [anLeft,anRight,anTop];
  end;

  miFile := TfpgPopupMenu.Create(self);
  with miFile do
  begin
    Name := 'miFile';
    SetPosition(244, 28, 132, 20);
    AddMenuItem('Open...', '', @miFileOpenClicked);
    AddMenuitem('-', '', nil);
    AddMenuItem('Quit', '', @miFileQuitClicked);
  end;

  miSettings := TfpgPopupMenu.Create(self);
  with miSettings do
  begin
    Name := 'miSettings';
    SetPosition(244, 52, 132, 20);
    AddMenuItem('Options...', '', nil);
  end;

  miBookmarks := TfpgPopupMenu.Create(self);
  with miBookmarks do
  begin
    Name := 'miBookmarks';
    SetPosition(244, 76, 132, 20);
    AddMenuItem('Add..', '', nil);
    AddMenuItem('Show', '', nil);
  end;

  miHelp := TfpgPopupMenu.Create(self);
  with miHelp do
  begin
    Name := 'miHelp';
    SetPosition(244, 100, 132, 20);
    AddMenuItem('Contents...', '', nil);
    AddMenuItem('Help using help', '', nil);
    AddMenuItem('-', '', nil);
    AddMenuItem('About fpGUI Toolkit', '', @miHelpAboutFPGui);
    AddMenuItem('Product Information...', '', @miHelpProdInfoClicked);
  end;

  btnIndex := TfpgButton.Create(tsIndex);
  with btnIndex do
  begin
    Name := 'btnIndex';
    SetPosition(120, 0, 80, 24);
    Text := 'Show';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 1;
    OnClick := @btnShowIndex;
  end;

  {@VFD_BODY_END: MainForm}
  {%endregion}

  // hook up the sub-menus.
  MainMenu.AddMenuItem('&File', nil).SubMenu := miFile;
  MainMenu.AddMenuItem('&Settings', nil).SubMenu := miSettings;
  MainMenu.AddMenuItem('&Bookmarks', nil).SubMenu := miBookmarks;
  MainMenu.AddMenuItem('&Help', nil).SubMenu := miHelp;

  // correct default visible tabsheet
  PageControl1.ActivePageIndex := 0;
end;


end.
