#!/bin/sh

set -e

ME=$(basename "$0")

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

docker_gen_nginx_conf() {
  local conffile="/etc/nginx/nginx.conf"
  local conffile_tmpl="/etc/nginx/nginx.conf.tmpl"

  [ -f "$conffile_tmpl" ] || return 0
  [ -w "$conffile" ] || return 0

  entrypoint_log "$ME: Backing up $conffile to $conffile.default"

  cp "$conffile" "$conffile.default"

  entrypoint_log "$ME: Running docker-gen on $conffile_tmpl to $conffile"
  goenvtemplator -template "$conffile_tmpl:$conffile"
}

docker_gen_nginx_template_conf() {
  local template_dir="${NGINX_CONF_TEMPLATE_DIR:-/etc/nginx/templates}"
  local suffix="${NGINX_CONF_TEMPLATE_SUFFIX:-.tmpl}"
  local output_dir="${NGINX_CONF_OUTPUT_DIR:-/etc/nginx/conf.d}"

  local template defined_envs relative_path output_path subdir
  [ -d "$template_dir" ] || return 0
  if [ ! -w "$output_dir" ]; then
    entrypoint_log "$ME: ERROR: $template_dir exists, but $output_dir is not writable"
    return 0
  fi

  find "$template_dir" -follow -type f -name "*$suffix" -print | while read -r template; do
    relative_path="${template#"$template_dir/"}"
    output_path="$output_dir/${relative_path%"$suffix"}"
    subdir=$(dirname "$relative_path")
    # create a subdirectory where the template file exists
    mkdir -p "$output_dir/$subdir"
    entrypoint_log "$ME: Running docker-gen on $template to $output_path"
    envsubst "$defined_envs" < "$template" > "$output_path"
    goenvtemplator -template "$template:$output_path"
  done
}

docker_gen_nginx_conf

docker_gen_nginx_template_conf

exit 0
