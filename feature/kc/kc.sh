#!/usr/bin/env bash

# KC Quick kubernetes context switch

# Run without arguments to quickly select the working context
# Run with -n to select the namespace from the current context

TEMPFILE=$(mktemp)


if [ "X${1}X" == "X-nX" ]
then
  NAMESPACES=()
  while IFS='' read -r line; do NAMESPACES+=("$line" "$line"); done < <(kubectl get ns --no-headers=true -o name | sed -re 's/namespace\/(.*)/\1/gi')
  if dialog --keep-tite --no-tags --default-item "$(kubectl config current-context)" --menu "Please select a k8s context" 0 0 5 "${NAMESPACES[@]}" 2>"${TEMPFILE}"
  then
      kubectl config set-context --current --namespace="$(cat "${TEMPFILE}")"
  fi
else
  CONTEXTS=()
  while IFS='' read -r line; do CONTEXTS+=("$line" "$line"); done < <(kubectl config get-contexts --no-headers=true -o name)
  if dialog --keep-tite --no-tags --default-item "$(kubectl config current-context)" --menu "Please select a k8s context" 0 0 5 "${CONTEXTS[@]}" 2>"${TEMPFILE}"
  then
      kubectl config use-context "$(cat "${TEMPFILE}")"
  fi
fi

rm "${TEMPFILE}"
