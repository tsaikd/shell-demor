#!/bin/bash

set -e

PN="${BASH_SOURCE[0]##*/}"
PD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# env config
if [ "${DEF_PS1}" ] ; then
	PS1="${DEF_PS1}"
else
	PS1='\e[01;32m'"${USER}"'\e[m \e[01;34;40m%s\e[m$ '
fi

DEF_SLEEP="${DEF_SLEEP:-6}"
DEF_GAP="${DEF_GAP:-2}"

function usage() {
	cat <<EOF
Usage: ${PN} [Options] <Script file>
Options:
  -h : show this help message

ENVIRONMENTS:
  DEF_PS1   = "${PS1}"
  DEF_SLEEP = "${DEF_SLEEP}"
  DEF_GAP   = "${DEF_GAP}"
EOF
	[ $# -gt 0 ] && { echo ; echo "$@" ; exit 1 ; }
	exit 0
}

for i in $@ ; do
	case "${i}" in
	-h) usage ;;
	*) cmdfile="${i}" ;;
	esac
done

if [ -z "${cmdfile}" ] ; then
	usage
fi

num="$(wc -l "${cmdfile}" | cut -d' ' -f1)"
clear
printf "${PS1}" "$(sed "s|${HOME%%/}|~|" <<<"${PWD}")"

for ((i=1 ; i<=num ; i++)) ; do
	set +e
	cmd="$(sed -n "${i}p" "${cmdfile}")"
	cmdhide="$(echo "${cmd}" | grep -o "#demo:hide")"
	cmd="$(echo "${cmd}" | sed "s/#demo:hide//; s/\\s\\+$//")"
	cmdnewline="$(echo "${cmd}" | grep -o "#demo:newline")"
	cmd="$(echo "${cmd}" | sed "s/#demo:newline//; s/\\s\\+$//")"
	cmdsleep="$(echo "${cmd}" | grep -o "#demo:sleep:[[:digit:]]\\+" | cut -d: -f3)"
	cmd="$(echo "${cmd}" | sed "s/#demo:sleep:[0-9]\\+//; s/\\s\\+$//")"
	cmdgap="$(echo "${cmd}" | grep -o "#demo:gap:[[:digit:]]\\+" | cut -d: -f3)"
	cmd="$(echo "${cmd}" | sed "s/#demo:gap:[0-9]\\+//; s/\\s\\+$//")"
	set -e

	if [ "${cmd}" ] && [ -z "${cmdhide}" ] ; then
		printf "%s" "${cmd}"
		sleep ${cmdsleep:-${DEF_SLEEP}}
		echo
	fi

	if [ "${cmd}" ] ; then
		eval ${cmd}
	fi

	if [ "${cmdnewline}" ] ; then
		if [ "${cmdhide}" ] ; then
			printf "${PS1}" "$(sed "s|${HOME%%/}|~|" <<<"${PWD}")"
		else
			echo
		fi
	fi

	if [ "${cmd}" ] && [ -z "${cmdhide}" ] ; then
		printf "${PS1}" "$(sed "s|${HOME%%/}|~|" <<<"${PWD}")"
		sleep ${cmdgap:-${DEF_GAP}}
	fi
done

echo

