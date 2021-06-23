#!/bin/bash  

shopt -s globstar

echo "::debug:: INPUT_SUFFIX=$INPUT_SUFFIX"
echo "::debug:: \$1=$1"
INPUT_SUFFIX=${INPUT_SUFFIX:-1}

if [[ -z "${INPUT_SUFFIX}" ]]
then
    echo "::error:: You must give a non-empty suffix"
    exit 1
fi

if [[ $GITHUB_REF =~ refs/([^/]+)/(.+) ]]
then
    # GITHUB_REF matches the pattern refs/type/name.
    # The type is usually tag or head (which indicates a branch)
    # The name is usually a simple string, but can be something more complex (e.g. gitflow's release/*, hotfix/* etc...)
    export GITHUB_REF_TYPE=${BASH_REMATCH[1]}
    export GITHUB_REF_NAME=${BASH_REMATCH[2]}
else
    # We are out of luck; the GITHUB_REF is nothing we can understand...
    # This can happen when something else than a branch of a tag is pushed,
    # or when the event that triggered the action is e.g a deletion.
    export GITHUB_REF_TYPE="none"
    export GITHUB_REF_NAME=""
fi

export GITHUB_REF_SSHA="${GITHUB_SHA:0:7}"

echo "::set-output name=type::$GITHUB_REF_TYPE"
echo "::set-output name=name::$GITHUB_REF_NAME"
echo "::set-output name=ssha::$GITHUB_REF_SSHA"

echo "::debug:: GITHUB_REF_TYPE=$GITHUB_REF_TYPE"
echo "::debug:: GITHUB_REF_NAME=$GITHUB_REF_NAME"
echo "::debug:: GITHUB_REF_SSHA=$GITHUB_REF_SSHA"

echo "GITHUB_REF_TYPE=$GITHUB_REF_TYPE" >> $GITHUB_ENV
echo "GITHUB_REF_NAME=$GITHUB_REF_NAME" >> $GITHUB_ENV
echo "GITHUB_REF_SSHA=$GITHUB_REF_SSHA" >> $GITHUB_ENV

echo "::debug:: Suffix is ${INPUT_SUFFIX}"

find -type f -name "*${INPUT_SUFFIX}" | \
while read tpl
do
    tgt="${tpl%${INPUT_SUFFIX}}"
    echo "::debug:: removing '$tgt' if any"
    rm -rf "$tgt"
    echo "::debug:: copying '$tpl' to '$tgt'"
    cp "$tpl" "$tgt"
    echo "::debug:: filtering '$tgt' in place"
    grep -o -E '\$\{[^{}]+\}' "$tgt" | xargs -I % bash -c "echo ::debug:: sed -i 's|%|"'%'"|g' '$tgt'";
    grep -o -E '\$\{[^{}]+\}' "$tgt" | xargs -I % bash -c "sed -i 's|%|'"%"'|g' '$tgt'";
    echo "processed '$(readlink -f "$tpl")' into '$tgt'"
done