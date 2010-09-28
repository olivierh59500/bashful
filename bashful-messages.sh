#!/usr/bin/env bash

# Filename:      bashful-messages.sh
# Description:   A set of functions for giving the user information.
# Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
# Last Modified: Mon 2010-09-27 20:30:31 (-0400)

# doc bashful-messages {{{
#
# The messages library provides functions for notifying the user.
#
# All functions are sensitive to the following variables:
#
#     VERBOSE  # If unset/false, the user will not see notifications.
#
# The VERBOSE variable only matters if the function is used with the verbose
# mode check option (-c).
#
# doc-end bashful-messages }}}

if (( ${BASH_LINENO:-0} == 0 )); then
    source bashful-doc
    doc_execute "$0" "$@"
    exit
fi

[[ $BASHFUL_MESSAGES_LOADED ]] && return

source bashful-core
source bashful-modes
source bashful-terminfo
source bashful-utils

usage() #{{{1
{
    # doc usage {{{
    #
    # Display usage information and exit with the given error code.
    # Will automatically populate certain sections if things like verbose or
    # interactive modes are set (either on or off).
    #
    # Usage: usage [ERROR]
    #
    # Required variables:
    #
    #     SCRIPT_NAME
    #
    # Optional variables:
    #
    #     SCRIPT_ARGS
    #     SCRIPT_DESCRIPTION
    #     SCRIPT_EXAMPLES
    #     SCRIPT_OPTIONS
    #     SCRIPT_USAGE
    #
    # doc-end usage }}}

    if [[ $SCRIPT_NAME ]]; then
        local p="    "
        {
            echo "Usage: $SCRIPT_NAME [OPTIONS] $SCRIPT_ARGS"
            [[ $SCRIPT_USAGE ]] && echo "$SCRIPT_USAGE"

            if [[ $SCRIPT_DESCRIPTION ]]; then
                echo
                echo -e "$SCRIPT_DESCRIPTION"
            fi

            if [[ $SCRIPT_EXAMPLES ]]; then
                echo
                echo "EXAMPLES"
                echo
                echo -e "$SCRIPT_EXAMPLES"
            fi

            echo
            echo "GENERAL OPTIONS"
            echo
            echo "${p}-h    Display this help message."

            if [[ $INTERACTIVE ]]; then
                echo
                echo "${p}-i    Interactive. Prompt for certain actions."
                echo "${p}-f    Don't prompt."
            fi

            if [[ $VERBOSE ]]; then
                echo
                echo "${p}-v    Be verbose."
                echo "${p}-q    Be quiet."
            fi

            if [[ $SCRIPT_OPTIONS ]]; then
                echo
                echo "APPLICATION OPTIONS"
                echo
                echo -e "$SCRIPT_OPTIONS" | sed "s/^/${p}/"
            fi
        } | squeeze_lines >&2
    fi

    exit ${1:-0}
}

error() #{{{1
{
    # doc error {{{
    #
    # Displays a colorized (if available) error message.
    #
    # Usage: error [-c] [MESSAGE]
    #
    # doc-end error }}}

    local c

    unset OPTIND
    while getopts ":c" option; do
        case $option in
            c) c=1 ;;
        esac
    done && shift $(($OPTIND - 1))

    if truth $c && ! verbose; then
        return
    fi

    local msg=${1:-An error has occurred.}

    info "${term_fg_red}${term_bold}ERROR: ${msg}${term_reset}"
}

die() #{{{1
{
    # doc die {{{
    #
    # Displays an error message and exits with the given error code.
    #
    # Usage: die [MESSAGE] [ERROR]
    #
    # doc-end die }}}

    error "$1"; exit ${2:-1}
}

info() #{{{1
{
    # doc info {{{
    #
    # Displays a colorized (if available) informational message.
    #
    # Usage: info [-c] [MESSAGE]
    #
    # doc-end info }}}

    local c

    unset OPTIND
    while getopts ":c" option; do
        case $option in
            c) c=1 ;;
        esac
    done && shift $(($OPTIND - 1))

    if truth $c && ! verbose; then
        return
    fi

    local msg=${1:-All updates are complete.}

    # Shorten home paths, if they exist.
    msg=${msg//$HOME/\~}

    echo -e "${term_bold}${msg}${term_reset}" >&2
}

warn() #{{{1
{
    # doc warn {{{
    #
    # Displays a colorized (if available) warning message.
    #
    # Usage: warn [-c] [MESSAGE]
    #
    # doc-end warn }}}

    local c

    unset OPTIND
    while getopts ":c" option; do
        case $option in
            c) c=1 ;;
        esac
    done && shift $(($OPTIND - 1))

    if truth $c && ! verbose; then
        return
    fi

    local msg=${1:-A warning has occurred.}

    info "${term_fg_yellow}WARNING: ${msg}${term_reset}"
}

#}}}

BASHFUL_MESSAGES_LOADED=1
