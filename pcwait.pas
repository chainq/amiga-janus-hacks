{*
 * Example code - waits for the Janus services to initialize
 * on the PC side after cold boot
 *
 * Copyright (c) 2022, Karoly Balogh <charlie@amigaspirit.hu>
 * See LICENSE file for details on the licensing of this file.
 *}

{$mode fpc}
program pcwait;

uses
  janus, exec, amigados;

var
  JA: PJanusAmiga;
  loop: dword;

begin
  if JanusBase = nil then 
    begin
      writeln('Waiting for janus.library....');
      repeat
        JanusBase:=Pointer(OpenLibrary('janus.library',0));
        DOSDelay(50);
      until JanusBase <> nil;
    end;

  writeln('janus.library loaded.');

  JA:=Pointer(MakeWordPtr(JanusBase^.jb_ParamMem));

  loop:=0;
  while (JA^.ja_AmigaState and AMIGA_PC_READY) = 0 do
    begin
      // CacheClearE(JA,sizeof(TJanusAmiga),CACRF_ClearD);
      if loop = 0 then 
        Writeln('Waiting for the PC Side to initialize...')
      else
        Write('.');
      inc(loop);
      DOSDelay(50);
    end;

  if loop = 0 then
    writeln('PC Side already initialized.')
  else
    begin
      writeln;
      writeln('PC Side initialized, took about ',loop,' seconds.');
    end;

  writeln('Janus Handler: ',JA^.ja_JHandlerVer,'.',JA^.ja_JHandlerRev);
  writeln('Janus Library: ',JA^.ja_JLibVer,'.',JA^.ja_JLibRev);
end.
