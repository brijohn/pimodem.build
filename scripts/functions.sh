
TOP=$(readlink -f $(dirname ${BASH_SOURCE:-$0})/..)

BUILDDIR=$TOP/build

PATH=$PATH:$BUILDDIR/tools

if [ -f $TOP/build.config ]; then
	. $TOP/build.config
fi

is_wireless_interface() {
	local _interface=$1
	local _regex="^wlan[0-9]+$"
	[[ $_interface =~ $_regex ]]
}

last_commit() {
	local gitpath"=$1"
	local opts=
	if [ -n "$2" ]; then
		opts="--short=$2"
	fi
	echo $(git -C $gitpath rev-parse $opts HEAD 2>/dev/null)
}

do_sign() {
	local file=$1
	local sig=".SIGN.RSA.$PUBKEY"
	pushd $(dirname $file) >/dev/null
	openssl dgst -sha1 -sign "$BUILDDIR/keys/$PRIVKEY" -out "$sig" "$file"
	tmptargz=$(mktemp)
	tar -f - -c "$sig" | abuild-tar --cut | gzip -9 > "$tmptargz"
	tmpsigned=$(mktemp)
	cat "$tmptargz" "$file" > "$tmpsigned"
	rm -f "$tmptargz" "$sig"
	chmod 644 "$tmpsigned"
	mv "$tmpsigned" "$file"
	popd >/dev/null
}

CGOCC=${CGOCC:-arm-linux-musleabihf-gcc}

PKGNAME=pimodem
PKGVER=1.0.0
PKGREV=r0
MAINTAINER="Brian Johnson"
EMAIL=${EMAIL:-"pimodem@invalid.invalid"}
PACKAGER=${PACKAGER:-$MAINTAINER}

LOGLEVEL=${LOGLEVEL:-"info"}

INTERFACE=${INTERFACE:-"eth0"}
SSID=${SSID:-""}
WPA_PSK=${WPA_PSK:-""}

PRIVKEY="$EMAIL-$(last_commit $TOP 8).rsa"
PUBKEY="$EMAIL-$(last_commit $TOP 8).rsa.pub"

ALSA_VERSION=${ALSA_VERSION:-1.1.9}
