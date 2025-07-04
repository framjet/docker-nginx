#!/bin/sh
# vim:sw=4:ts=4:et

set -e

. /docker-entrypoint.functions

DEFAULT_CONF_FILE="etc/nginx/conf.d/default.conf"

# check if we have ipv6 available
if [ ! -f "/proc/net/if_inet6" ]; then
    entrypoint_warn "ipv6 not available"
    exit 0
fi

if [ ! -f "/$DEFAULT_CONF_FILE" ]; then
    entrypoint_log "/$DEFAULT_CONF_FILE is not a file or does not exist"
    exit 0
fi

# check if the file can be modified, e.g. not on a r/o filesystem
touch /$DEFAULT_CONF_FILE 2>/dev/null || { entrypoint_warn "can not modify /$DEFAULT_CONF_FILE (read-only file system?)"; exit 0; }

# check if the file is already modified, e.g. on a container restart
grep -q "listen  \[::]\:80;" /$DEFAULT_CONF_FILE && { entrypoint_info "IPv6 listen already enabled"; exit 0; }

if [ -f "/etc/os-release" ]; then
    . /etc/os-release
else
    entrypoint_warn "can not guess the operating system"
    exit 0
fi

entrypoint_log "Getting the checksum of /$DEFAULT_CONF_FILE"

case "$ID" in
    "debian")
        CHECKSUM=$(dpkg-query --show --showformat='${Conffiles}\n' nginx | grep $DEFAULT_CONF_FILE | cut -d' ' -f 3)
        echo "$CHECKSUM  /$DEFAULT_CONF_FILE" | md5sum -c - >/dev/null 2>&1 || {
            entrypoint_log "/$DEFAULT_CONF_FILE differs from the packaged version"
            exit 0
        }
        ;;
    "alpine")
        CHECKSUM=$(apk manifest nginx 2>/dev/null| grep $DEFAULT_CONF_FILE | cut -d' ' -f 1 | cut -d ':' -f 2)
        echo "$CHECKSUM  /$DEFAULT_CONF_FILE" | sha1sum -c - >/dev/null 2>&1 || {
            entrypoint_log "/$DEFAULT_CONF_FILE differs from the packaged version"
            exit 0
        }
        ;;
    *)
        entrypoint_warn "Unsupported distribution"
        exit 0
        ;;
esac

# enable ipv6 on default.conf listen sockets
sed -i -E 's,listen       80;,listen       80;\n    listen  [::]:80;,' /$DEFAULT_CONF_FILE

entrypoint_info "Enabled listen on IPv6 in /$DEFAULT_CONF_FILE"

exit 0
