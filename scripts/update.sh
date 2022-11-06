#!/bin/sh
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${BASE_DIR}/.."
README_FILE="${REPO_DIR}/README.md"
UP_FILE="${REPO_DIR}/scripts/up.sh"
DOWN_FILE="${REPO_DIR}/scripts/down.sh"

reset_out_file() {
    local OUT_FILE=$1
    cat <<EOT >${OUT_FILE}
#!/bin/sh
# This file is autogenerated - DO NOT EDIT!
set -euo pipefail
BASE_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="\${BASE_DIR}/.."
(
cd \${REPO_DIR}
EOT
}

update_up() {
    local OUT_FILE=$UP_FILE
    reset_out_file ${OUT_FILE}
    awk '/^(kubectl create)/' $README_FILE >>$OUT_FILE
    awk '/^(kubectl apply)/' $README_FILE >>$OUT_FILE
    awk '/^(helm repo)/' $README_FILE | uniq >>$OUT_FILE
    awk '/^(helm upgrade)/' $README_FILE >>$OUT_FILE
    echo ")" >>$OUT_FILE
}

update_down() {
    local OUT_FILE=$DOWN_FILE
    reset_out_file ${OUT_FILE}
    awk '/^(helm uninstall)/' $README_FILE >>$OUT_FILE
    awk '/^(kubectl delete)/' $README_FILE >>$OUT_FILE
    echo ")" >>$OUT_FILE
}

main() {
    echo "Updating $UP_FILE"
    update_up
    echo "Updating $DOWN_FILE"
    update_down
}

main