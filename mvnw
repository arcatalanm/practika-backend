#!/bin/sh
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
exec sh "$project_dir/ms-auth/mvnw" -f "$project_dir/pom.xml" "$@"
