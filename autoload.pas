{*
 * Example code - experimental/partial replacement implementation
 * of the original AutoLoad service with very verbose debug messages
 *
 * Copyright (c) 2022, Karoly Balogh <charlie@amigaspirit.hu>
 * See LICENSE file for details on the licensing of this file.
 *}


{$mode fpc}
{$packrecords 2}
program autoload;

uses
  janus, exec, amigados, icon, workbench;

const
  APPID = 123;
  LOCALID = 2;

var
  dbg: text;
  dbgb: byte;
  sig: longint;
  sigmask: DWord;
  servdata: PServiceData;
  servdatab: PServiceData; 

type
  TAutoLoadItem = record
    ali_AppID: DWord;
    ali_LocalID: Word;
  end;

  TAutoLoadBuf = record
    alb_ItemNum: Word;
    alb_Items: array[0..3] of TAutoLoadItem;
  end;

function do_autoload(const app_id, local_id: dword): boolean;
const
  SERVICES_PATH = 'SYS:PC/Services/';
var
  fib: PFileInfoBlock;
  dirlock: longint;
  p,l: longint;
  diskobj: PDiskObject;
  diskobjpath: string;
  toolstr: pchar;
  idstr: string;
  id: longint;
  code: word;
  appmatch,localmatch: boolean;
begin
  do_autoload:=false;

  new(fib);
  FillChar(fib^,sizeof(fib^),0);

  write(dbg,'Locking ',SERVICES_PATH,' ... ');
  dirlock:=Lock(SERVICES_PATH,SHARED_LOCK);
  if dirlock <> 0 then
    begin
      writeln(dbg,'OK');
      writeln(dbg,'Examining directory...');
      if Examine(dirlock, fib) and (fib^.fib_DirEntryType > 0) then
        while ExNext(dirlock, fib) do
          begin
            writeln(dbg,'Directory Entry: ',fib^.fib_FileName);
            l:=Length(PChar(@fib^.fib_FileName));
            p:=Pos('.info',fib^.fib_FileName);
            if (p > 0) and ((p - 1) = (l - Length('.info'))) then
              begin
                writeln(dbg,'Found .info file: ',PChar(@fib^.fib_fileName));
                write(dbg,'Trying to get Disk Object ... ');
                diskobjpath:=SERVICES_PATH + Copy(fib^.fib_filename, 0, l - length('.info'));
                diskobj:=GetDiskObject(diskobjpath);
                if diskobj <> nil then
                  begin
                    writeln(dbg,'OK');
                    write(dbg,'Checking for AUTOLOAD tooltype ... ');
                    toolstr:=FindToolType(diskobj^.do_ToolTypes,'AUTOLOAD');
                    if toolstr <> nil then
                      begin
                        writeln(dbg,'FOUND, contains: [',toolstr,']');
                        p:=Pos('/',toolstr);
                        if p > 0 then
                          begin
                            idstr:=Copy(toolstr,0,p-1);
                            Val(idstr,id,code);
                            writeln(dbg,'AppID: [',idstr,'] ID:',id,' Code:',code);
                            appmatch:=(id = app_id) and (code = 0);

                            idstr:=Copy(toolstr, p + 1, length(toolstr) - p);
                            Val(idstr,id,code);
                            writeln(dbg,'LocalID: [',idstr,'] ID:',id,' Code:',code);
                            localmatch:=(id = local_id) and (code = 0);

                            if appmatch and localmatch then
                              begin
                                writeln(dbg,'MATCH FOUND, EXECUTING SERVICE: ',diskobjpath);
                                Execute('Run <NIL: >NIL: '+diskobjpath+' <NIL: >NIL:',0,TextRec(output).Handle);
                                do_autoload:=true;
                                FreeDiskObject(diskobj);
                                break;
                              end
                            else
                              writeln(dbg,'Tooltype IDs don''t match.');
                          end
                        else
                          writeln(dbg,'Tooltype is in the wrong format!');
                      end
                    else
                      writeln(dbg,'NOT FOUND');

                    FreeDiskObject(diskobj);
                  end
                else
                  writeln(dbg,'FAILED!');
              end;
          end;

      writeln(dbg, 'Unlocking ',SERVICES_PATH);
      UnLock(dirlock);
    end
  else
    writeln(dbg,'FAILED!');

  dispose(fib);
end;

function init_autoload: boolean;
var
  jerr: DWord;
begin
  init_autoload:=false;

  write(dbg,'Allocating Signal: ');
  sig:=AllocSignal(-1);
  if sig = -1 then
    begin
      writeln(dbg,'FAILED!');
      exit;
    end;
  sigmask:=1 shl sig;
  writeln(dbg, sig, ' SigMask: %',BinStr(sigmask,32));

  servdata:=nil;
  write(dbg,'Adding Janus AutoLoad Service...');
  jerr:=AddService(@servdata, APPID, LOCALID, sizeof(TAutoLoadBuf), MEM_WORDACCESS or MEMF_BUFFER, sig, ADDS_LOCKDATA);
  if jerr <> JSERV_OK then
    begin
      writeln(dbg,'FAILED! code:',jerr);
      exit;
    end;
  writeln(dbg,'Success!');

  servdatab:=Pointer(MakeBytePtr(servdata));

  writeln(dbg,'Initializing the service buffer.');
  FillChar(servdata^.sd_AmigaMemPtr^,sizeof(TAutoLoadBuf),0);
  TAutoLoadBuf(servdata^.sd_AmigaMemPtr^).alb_ItemNum:=4;

  writeln(dbg,'Unlocking the service.');
  UnlockServiceData(servdatab);

  init_autoload:=true;
end;

procedure process_autoload;
var
  quit: boolean;
  i: longint;
begin
  quit:=false;
  repeat
    writeln(dbg,'Waiting for signal.');
    Wait(sigmask);
    writeln(dbg,'Signal received!');

    LockServiceData(servdatab);
    writeln(dbg,'Service data locked.');

    with TAutoLoadBuf(servdata^.sd_AmigaMemPtr^) do
      for i:=0 to alb_ItemNum-1 do
        if alb_Items[i].ali_AppID > 0 then
          begin
            writeln(dbg,'Attempting to AutoLoad AppID/LocalID: ',alb_Items[i].ali_AppID,'/',alb_Items[i].ali_LocalID);
            do_autoload(alb_Items[i].ali_AppID,alb_Items[i].ali_LocalID);
            alb_Items[i].ali_AppID:=0;
          end;

    UnlockServiceData(servdatab);
    writeln(dbg,'Service data unlocked.');
  until quit;
end;

procedure done_autoload;
begin
  if sig <> -1 then
    FreeSignal(sig);

  writeln(dbg,'AutoLoad exiting.');
end;

begin
  Assign(dbg,'CON:');
  SetTextBuf(dbg,dbgb);
  Rewrite(dbg);

  writeln(dbg,'Autoload Startup');
  if JanusBase = nil then 
    begin
      writeln(dbg,'janus.library not found, exiting');
      exitcode:=1;
    end
  else
    begin
      writeln(dbg,'janus.library opened.');

      if init_autoload then
        process_autoload;
      done_autoload;
    end;

  DOSDelay(150);
  Close(dbg);
end.
