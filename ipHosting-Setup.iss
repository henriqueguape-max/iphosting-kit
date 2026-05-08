#define AppName    "ipHosting Kit de Manutencao"
#define AppVersion "3.0"
#define AppPublisher "ipHosting"
#define AppExeName "ipHosting.bat"
#define AppDir     "ipHosting"

[Setup]
AppId={{B4E2F1A3-7C9D-4E6B-A2F8-D1C3E5B7A9F2}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/henriqueguape-max/iphosting-kit
AppSupportURL=https://github.com/henriqueguape-max/iphosting-kit/issues
DefaultDirName={autopf}\{#AppDir}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename=ipHosting-Setup-v{#AppVersion}
SetupIconFile=
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardResizable=no
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
DisableWelcomePage=no
DisableDirPage=no
DisableReadyPage=no
ShowLanguageDialog=no
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\ipHosting.bat
MinVersion=10.0
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Files]
Source: "ipHosting.bat";              DestDir: "{app}"; Flags: ignoreversion
Source: "ipHosting-Manutencao.ps1";   DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Atalho na area de trabalho
Name: "{autodesktop}\ipHosting Kit";  \
      Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; \
      Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\ipHosting-Manutencao.ps1"""; \
      WorkingDir: "{app}"; \
      IconFilename: "{sys}\shell32.dll"; \
      IconIndex: 162; \
      Comment: "ipHosting Kit de Manutencao Tecnica v{#AppVersion}"

; Atalho no menu iniciar
Name: "{group}\{#AppName}"; \
      Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; \
      Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\ipHosting-Manutencao.ps1"""; \
      WorkingDir: "{app}"; \
      IconFilename: "{sys}\shell32.dll"; \
      IconIndex: 162; \
      Comment: "ipHosting Kit de Manutencao Tecnica v{#AppVersion}"

; Atalho de desinstalacao no menu iniciar
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"

[Run]
; Oferta de execucao imediata apos instalar
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\ipHosting-Manutencao.ps1"""; \
  Description: "Executar o ipHosting Kit agora"; \
  Flags: postinstall nowait skipifsilent runascurrentuser

[UninstallDelete]
; Remove logs gerados pelo script (opcional — comentar para preservar)
; Type: filesandordirs; Name: "{userdesktop}\ipHosting-Logs"

[Code]
// Verifica se PowerShell 5.1+ esta disponivel antes de instalar
function InitializeSetup(): Boolean;
var
  Ver: String;
begin
  Result := True;
  if not RegQueryStringValue(HKLM,
    'SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine',
    'PowerShellVersion', Ver) then
  begin
    MsgBox(
      'PowerShell 5.1 ou superior e necessario.' + #13#10 +
      'Instale o Windows Management Framework e tente novamente.',
      mbError, MB_OK);
    Result := False;
  end;
end;
