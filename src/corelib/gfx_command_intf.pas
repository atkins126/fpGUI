unit gfx_command_intf;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface


type
  ICommand = interface(IInterface)
  ['{28D72102-D883-41A1-9585-D86B24D9C628}']
    procedure   Execute;
  end;
  
  
  ICommandHolder = interface(IInterface)
  ['{695BA6E1-1120-42D4-A2C3-54F98D5CDA46}']
    function    GetCommand: ICommand;
    procedure   SetCommand(ACommand: ICommand);
  end;
  

implementation


end.

