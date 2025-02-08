#SingleInstance, Force
#NoTrayIcon
#Include <AuxLib>

    AuxLibLoad()

    SetRegView 64
    RegRead, DeveloperDir, HKCU\Software\Developer, DeveloperDir
    ProjectDir := GetProjectDir()

    if (A_Args.Length() > 0) {
        label := A_Args[1]
        if IsLabel(label) {
            Gosub %label%
        }
        ExitApp
    }

    ; Project Menu
    AddMenuItemEditor("ProjectMenu")
    AddMenu( "ProjectMenu" )
    AddMenuItemWSLEnabled( "ProjectMenu", ProjectDir )
    AddMenu("ProjectMenu", "En&vironment Shell...`tV", "OnEnvShell", WSLPath )
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&README.md...`tR", "OnReadme", BrowserPath )
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&Sync with Upstream`tS", "OnSyncWithUpstream", ConEmuPath )
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&LibreChat...`tL", "OnLibreChatWSL", ResDir "github.ico" )
    AddMenu( "ProjectMenu" )
    AddMenuItemEditProjectMenu("ProjectMenu")
    ShowMenu( "ProjectMenu" )
    ExitApp
return ; end of script's auto-execute section

MenuHandler:
    MsgBox % "MenuHandler was called."
return

OnSyncWithUpstream:
    ProjectDir := GetProjectDir()
    SyncWithUpstream(ProjectDir, "https://github.com/danny-avila/LibreChat.git")
return

OnLibreChatWSL:
{
    ProjectDir := GetProjectDir()
    SplitPath, A_LineFile,, ProjectDir
    SplitPath, ProjectDir,, ProjectDir

    ProjectDirWsl := "/home/ubuntu/LibreChat" ; ConvertToWslPath(ProjectDir)
    ShiftPressed := GetKeyState("Shift","P")
    BatchScript =
    (
        
        echo !yellow!Initializing LibreChat in !green!%ProjectDir%!yellow! ...!nc!
    )
    BashScript =
    (
        
        # Check if LibreChat is installed
        should_install=%ShiftPressed%
        
        if [[ -f "%ProjectDirWsl%/.env" && "$should_install" == "0" ]]; then
            echo "LibreChat already installed."
            cd "%ProjectDirWsl%" || { echo "Failed to change directory."; exit 1; }
            /usr/bin/npm run backend || { echo "Failed to npm run backend."; exit 1; }
        else
            # sudo apt-get update || exit 1
            # sudo apt-get install -y build-essential libvips-dev pkg-config python3 nodejs npm || exit 1
            cd "/home/ubuntu" || { echo "Failed to change directory."; exit 1; }
            git clone "https://github.com/dwf981/LibreChat.git" || { echo "Failed to clone repository."; exit 1; }  # Fixed quote here
            cd "/home/ubuntu/LibreChat" || { echo "Failed to change directory."; exit 1; }
            echo "Installing dependencies..."
            /usr/bin/npm install || { echo "Failed to npm install."; exit 1; }
            echo "Installing ci dependencies..."
            /usr/bin/npm ci || { echo "Failed to npm ci."; exit 1; }
            echo "Running frontend..."
            /usr/bin/npm run frontend || { echo "Failed npm run frontend."; exit 1; }
            echo "Running backend..."
            /usr/bin/npm run backend || { echo "Failed npm run backend."; exit 1; }
            echo "Copying .env file..."
            if [ ! -f .env ]; then cp .env.example .env; fi
            echo "Copying librechat.yaml file..."
            if [ ! -f librechat.yaml ]; then cp librechat.example.yaml librechat.yaml; fi
            echo "LibreChat installed successfully."
        fi
    )
    Options := { Visible: "ConEmu", Colors: true, Pause: true, Admin: false }
    RunBash( Options, StripBat(BatchScript), StripBat(BashScript), [], true, true )
    return
}

OnEnvShell:
    SplitPath, ProjectDir, ProjectName
    BatchScript =
    (

        echo !yellow!Starting environment...!nc!
    )
    BashScript =
    (
        
        cd ~/%ProjectName%
        bash
    )
    Options := { Visible: "ConEmu", Colors: true, Pause: true, Admin: false }
    RunBash( Options, StripBat(BatchScript), StripBat(BashScript), [] )
return
