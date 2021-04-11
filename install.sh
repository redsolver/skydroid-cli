#!/bin/sh
# Based on Deno installer: Copyright 2019 the Deno authors. All rights reserved. MIT license.
# TODO(everyone): Keep this script simple and easily auditable.

set -e

if [ "$OS" = "Windows_NT" ]; then
	target="windows.exe"
else
	case $(uname -sm) in
	"Darwin x86_64") target="mac" ;;
	"Darwin arm64") target="none" ;;
	*) target="linux" ;;
	esac
fi

if [ "$target" = "none" ];  then
	echo "Error: ARM is not supported yet" 1>&2
	exit 1
fi

if [ $# -eq 0 ]; then
	cli_uri="https://github.com/redsolver/skydroid-cli/releases/latest/download/skydroid-${target}"
else
	cli_uri="https://github.com/redsolver/skydroid-cli/releases/download/${1}/skydroid-${target}"
fi

bin_dir="$HOME/.local/bin"
exe="$bin_dir/skydroid"

if [ ! -d "$bin_dir" ]; then
 	mkdir -p "$bin_dir"
fi

curl --fail --location --progress-bar --output "$exe" "$cli_uri"
chmod +x "$exe"

echo "The SkyDroid CLI was installed successfully to $exe"
echo ""
if command -v skydroid >/dev/null; then
	echo "Run 'skydroid --help' to get started"
else
	case $SHELL in
	/bin/zsh) shell_profile=".zshrc" ;;
	*) shell_profile=".bash_profile" ;;
	esac
	echo "Manually add the directory to your \$HOME/$shell_profile (or similar)"
    echo ""
	echo "  export PATH=\"$bin_dir:\$PATH\""
    echo ""
	echo "Run '$exe --help' to get started"
fi