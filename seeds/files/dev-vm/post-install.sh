#!/bin/sh

FR_DIR="/usr/local/share/first-run"

rm -rf $FR_DIR
mkdir -p $FR_DIR
cd $FR_DIR

    # add kakrueger/openstreetmap for osm2pgsql
    add-apt-repository ppa:kakrueger/openstreetmap
    apt-get update
    apt-get install -y osm2pgsql

    wget http://mirror.citiviz.vpn/seeds/files/dev-vm/config.tar
    wget http://mirror.citiviz.vpn/seeds/files/dev-vm/scripts.tar

    tar xvf config.tar
    tar xvf scripts.tar

    USER_PASSWD_ENTRY="$(grep 1000:1000 /etc/passwd)"

    USER=$(echo $USER_PASSWD_ENTRY | cut -d: -f1)
    HOME=$(echo $USER_PASSWD_ENTRY | cut -d: -f6)
    NAME=$(echo $USER_PASSWD_ENTRY | cut -d: -f5 | cut -d, -f1)

    split_fullname() {
        FIRSTNAME=$1
        shift
        LASTNAME=$*
    }
    split_fullname $NAME

    to_lower() {
        sed -e 's/[A-Z]/\l&/g'
    }
    join_names() {
        tr ' ' '-'
    }
    EMAIL="$(echo $FIRSTNAME | to_lower).$(echo $LASTNAME | to_lower | join_names)@citiviz.com"

cat << EOF > /first-run.sh
#!/bin/sh
#
# first-run.sh script | Citiviz dev-vm setup
#
# assumes that the user:
#  1) provided correct information under the "full name" field during installation
#  2) has an email account @citiviz.com in the form:
#       (firstname).(lastname)@citiviz.com
#  with:
#   - no capital letters
#   - spaces are translated to dashes (i.e.: '-')
#
# Example: Joerg Von Dracula has <joerg.von-dracula@citiviz.com>
#

cd $FR_DIR

show_and_run() {
    local name
    local cmd
    name=\$1
    shift
    cmd=\$*

    echo "[\${name}] \${cmd}"
    . \${cmd}
}

do_script() {
    local what
    local args
    what=\$1
    shift
    args=\$*

    show_and_run script/\${what} \${what} \${args}
}

do_script init-git           "${NAME}" "${EMAIL}"
do_script make-xchat2-config "${NAME}" "${EMAIL}" "${FIRSTNAME}"

EOF

chmod +x /first-run.sh
chown ${USER}:${USER} /first-run.sh

echo "Please run /first-run.sh as your normal user."
