# SHELL

alias "$"=''

alias al='nano ~/.oh-my-zsh/custom/aliases.zsh'
alias rc='nano ~/.zshrc'
alias refresh='source ~/.zshrc'
alias p10krc='nano ~/.p10k.zsh'

# UTILITY

alias commands='nano ~/Downloads/UbuntuApps/COMMANDS.txt'

cdls() {
    local dir="$1"
    local dir="${dir:=$HOME}"
    if [[ -d "$dir" ]]; then
        cd "$dir" >/dev/null; ls
    else
        echo cdls: no such directory: $dir
    fi
}

alias dc='docker compose'

alias autoclicker='xdotool click --repeat 1000 --delay 10 1'

alias xclip='xclip -selection c'

alias tech='cd ~/Tech'

alias piserver='ssh -J serveo.net krishnan@krishnans2006'

# TJUAV

alias tjuav='cd ~/Tech/TJUAV/'

tjuav-sim() {
    if [ "$1" != "" ]
    then
        ~/Tech/TJUAV/ardupilot/Tools/autotest/sim_vehicle.py --no-mavproxy -v ArduPlane --add-param-file ~/Tech/TJUAV/ardupilot/Tools/autotest/default_params/avalon.parm -L "$1"
    else
        ~/Tech/TJUAV/ardupilot/Tools/autotest/sim_vehicle.py --no-mavproxy -v ArduPlane --add-param-file ~/Tech/TJUAV/ardupilot/Tools/autotest/default_params/avalon.parm -L FARM_RC
    fi
}

tjuav-server() {
    cd ~/Tech/TJUAV/GroundStation/server/
    source ~/Tech/TJUAV/GroundStation/server/venv/bin/activate
    python ~/Tech/TJUAV/GroundStation/server/app.py
}

alias tjuav-client='npm start --prefix ~/Tech/TJUAV/GroundStation/client'
alias mission-planner='mono ~/Tech/TJUAV/MissionPlanner/MissionPlanner.exe'

# tjCSL

alias tjcsl='cd ~/Tech/tjCSL/'

raw-passcard() {
    gpg -d ~/Tech/tjCSL/keybase-passcard/passwords/"$1".txt.gpg 2>/dev/null
}

passcard() {
    password=$(gpg -d ~/Tech/tjCSL/keybase-passcard/passwords/"$1".txt.gpg 2>/dev/null)
    echo "$password" | xclip
    if [[ "$2" != "" ]]
    then
        echo "$password"
    fi
}

kb() {
    pass tjcsl/kerberos | kinit 2024kshankar/root
    echo kinit as 2024kshankar/root complete!
}

tjras() {
    export SSHPASS=$(pass tjcsl/kerberos)
    sshpass -e ssh "$@" 2024kshankar@ras2.tjhsst.edu
}

tjssh() {
    CSL_USERNAME="2024kshankar"
    PASSCARD_DIR="/home/krishnan/Tech/tjCSL/keybase-passcard"

    # Set INPUT as server
    INPUT="$1"

    # Set HOST as server.csl.tjhsst.edu
    if [[ "$INPUT" == *"@"* ]]
    then
        HOST=$(echo "$INPUT" | cut -d"@" -f2)
    else
        HOST="$INPUT"
    fi

    # Set SERVER as user@server.csl.tjhsst.edu
    if [[ "$INPUT" != *"."* ]]
    then
        SERVER="$INPUT".csl.tjhsst.edu
        HOST="$HOST".csl.tjhsst.edu
    fi

    if ping -c 1 "$HOST" &> /dev/null
    then
        if [ -e "$PASSCARD_DIR"/passwords/"$INPUT".txt.gpg ]
        then
            export SSHPASS=$(raw-passcard "$INPUT")
            if [[ "$SSHPASS" != "" ]]
            then
                echo Found passcard! SSHing...
                sshpass -e ssh "${@:2}" "$SERVER"
            else
                echo No access to passcard! SSHing...
                ssh "${@:2}" "$SERVER"
            fi
        else
            echo -n "No passcard! Enter alternate passcard (leave blank to continue): "
            read PASSCARD_NAME
            if [[ "$PASSCARD_NAME" != "" ]]
            then
                if [ -e "$PASSCARD_DIR"/passwords/"$PASSCARD_NAME".txt.gpg ]
                then
                    export SSHPASS=$(raw-passcard "$PASSCARD_NAME")
                    if [[ "$SSHPASS" != "" ]]
                    then
                        echo Found passcard! SSHing...
                        sshpass -e ssh "${@:2}" "$SERVER"
                    else
                        echo No access to passcard! SSHing...
                        ssh "${@:2}" "$SERVER"
                    fi
                else
                    echo Passcard not found! SSHing...
                    ssh "${@:2}" "$SERVER"
                fi
            else
                echo SSHing...
                ssh "${@:2}" "$SERVER"
            fi
        fi
    else
        echo Unpingable! Using ras host-chaining...
        ssh "${@:2}" -J "$CSL_USERNAME"@ras2.tjhsst.edu "$SERVER"
    fi
}

tjans() {
    ANSIBLE_DIR="/home/krishnan/Tech/tjCSL/ansible"
    TEMP_FILE="/home/krishnan/.ansible-playbook-runner.sh"
    NUM_FORKS="100"
    CONNECT_USER="root"

    PLAY="$1"
    if [[ "$1" == "" ]]
    then
        echo usage: tjans playbook ssh_pwd_name vault_pwd_name --extra --args
        return
    fi

    if [[ "$2" != "" ]] && [[ "$2" != "-" ]]
    then
        SSH_PASS_NAME="$2"
    else
        SSH_PASS_NAME=""
    fi
    export SSHPASS=$(raw-passcard "$SSH_PASS_NAME")

    if [[ "$3" != "" ]] && [[ "$3" != "-" ]]
    then
        VAULT_PASS_NAME="$3"
    else
        VAULT_PASS_NAME="ansible"
    fi
    export VAULTPASS=$(raw-passcard "$VAULT_PASS_NAME"_vault)
    echo "#!/bin/bash" > "$TEMP_FILE"
    echo 'echo $VAULTPASS' >> "$TEMP_FILE"
    chmod +x "$TEMP_FILE"

    echo RUNNING COMMAND: "\n"    ansible-playbook "$ANSIBLE_DIR"/"$1".yml -i "$ANSIBLE_DIR"/hosts -f "$NUM_FORKS" -u "$CONNECT_USER" "${@:4}"
    git -C "$ANSIBLE_DIR" pull
    ansible-playbook "$ANSIBLE_DIR"/"$1".yml -i "$ANSIBLE_DIR"/hosts -e "pass=$SSHPASS" --vault-password-file "$TEMP_FILE" -f "$NUM_FORKS" -u "$CONNECT_USER" "${@:4}"
}

deploy-tin() {
    tjans tin tin tin -t tin-django
}

alias tjovpn='sudo openvpn ~/Tech/tjCSL/2024kshankar.ovpn'
