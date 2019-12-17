#!/usr/bin/env bash

# KC Quick kubernetes context switch

CONTEXTS=$(kubectl config get-contexts --no-headers=true -o name | sed -re 's/^(.*)$/\1 \1/gi' | paste -s -d " " -)
TEMPFILE=$(mktemp)
if dialog --keep-tite --no-tags --default-item "$(kubectl config current-context)" --menu "Please select a k8s context" 0 0 5 ${CONTEXTS} 2>"${TEMPFILE}"
then
    kubectl config use-context "$(cat "${TEMPFILE}")"
fi

rm "${TEMPFILE}"
