{%mainunit Agg2D.pas}

{$ifdef uses_interface}
  // CocoaAll,
{$endif}


{$ifdef agg_platform_interface}
  protected
    // nothing here
{$endif}


{$ifdef uses_implementation}
  fpg_cocoa,
  fpg_impl,
  fpg_fontcache,
{$endif}


{$ifdef agg_platform_implementation}

type
  // to get access to protected methods (seeing that FPC doesn't support Friend-classes)
  TImageHack = class(TfpgImage);

function FontCacheItemFromFontDesc(const desc: string; var asize: double): TFontCacheItem;
var
  facename: string;
  cp: integer;
  c: char;
  token: string;
  prop, propval: string;

  function NextC: char;
  begin
    Inc(cp);
    if cp > length(desc) then
      c := #0
    else
      c := desc[cp];
    Result := c;
  end;

  procedure NextToken;
  begin
    token := '';
    while (c <> #0) and (c in [' ', 'a'..'z', 'A'..'Z', '_', '0'..'9', '.']) do
    begin
      token := token + c;
      NextC;
    end;
  end;

begin
  Result := TFontCacheItem.Create('');

  cp := 0;
  NextC;
  NextToken;

  facename := token;
  // Add known substites
  if lowercase(facename) = 'times' then
    facename := 'Times New Roman'
  else if lowercase(facename) = 'courier' then
    facename := 'Courier New'
  else if lowercase(facename) = 'monospace' then
    facename := 'Courier New';
  Result.FamilyName := facename;

  if c = '-' then
  begin
    NextC;
    NextToken;
    asize := StrToIntDef(token, 0);
  end;

  while c = ':' do
  begin
    NextC;
    NextToken;

    prop    := UpperCase(token);
    propval := '';

    if c = '=' then
    begin
      NextC;
      NextToken;
      propval := UpperCase(token);
    end;

    if prop = 'BOLD' then
      Result.IsBold := True
    else if prop = 'ITALIC' then
      Result.IsItalic := True
    else if prop = 'ANGLE' then
      Result.Angle := StrToFloatDef(propval, 0.0);
//    else if prop = 'ANTIALIAS' then
//      if propval = 'FALSE' then
//        lf.lfQuality := NONANTIALIASED_QUALITY else
//      if propval = 'DEFAULT' then
//        lf.lfQuality := DEFAULT_QUALITY;
  end;
end;

type
  TWindowHack = class(TfpgCocoaWindow);

procedure TAgg2D.DoPutBufferToScreen(x, y, w, h: TfpgCoord);
var
  // drawgc: Tgc;
  // GcValues: TXGcValues;
  // X11Handle: TfpgWinHandle;
  win: TWindowHack;
{$IFDEF CStackDebug}
  itf: IInterface;
{$ENDIF}
begin
  {$IFDEF CStackDebug}
  itf := DebugMethodEnter('TAgg2D.DoPutBufferToScreen - ' + ClassName);
  DebugLn(Format('x:%d  y:%d  w:%d  h:%d', [x, y, w, h]));
  {$ENDIF}
  // win := TWindowHack(TfpgWidgetBase(FWidget).Window);
  // X11Handle := win.WinHandle;
  // if X11Handle <= 0 then
  // begin
    // debugln('TAgg2D/X11 DoPutBufferToScreen:  No WinHandle available.');
    // exit;
  // end;
 
  // FImg.UpdateImage;
  // drawgc := XCreateGc(fpgApplication.Display, X11Handle, 0, @GcValues);
 
  // finally dump the image to screen!
  // XPutImage(fpgApplication.Display, X11Handle,
      // drawgc, TImageHack(FImg).XImage, x,y,x,y, w, h);
 
  // XFreeGc(fpgApplication.Display, drawgc);
  // win.TriggerSyncCounter;
end;


{$endif}

