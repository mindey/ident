dhash() {
    # SHA256 hashing directory or file .manifest
    if [[ -d $1 ]]; then
        dir=$1; find "$dir" -type f -exec sha256sum {} \; | awk '{print $1}' | sed "s~$dir~~g" | LC_ALL=C sort -d > .manifest
        cat .manifest | sha256sum
    elif [[ -f $1 ]]; then
        cat $1 | sha256sum > .manifest
        cat .manifest | sha256sum
    elif [[ -z $1 ]]; then
        echo "No parameter provided."
    else
        echo "Parameter $1 not valid."
    fi

}

dsign() {
    # RSA signing .manifest hash
    if [ -z "$1" ]
      then
        echo "No arguments supplied"
      else
        echo "PATH - $1"
        HASH=$(dhash $1 | cut -d' ' -f1)
        echo "SHA256 - $HASH"
        WHO="$(whoami)@$(hostname)"
        SIGN=$(echo -n "$WHO," && echo "$HASH" | openssl rsautl -sign -inkey ~/.ssh/id_rsa | base64 -w0 && echo -n ":" && cat ~/.ssh/id_rsa.pub | base64 -w0)
        echo "SIGNATURE(user,b64sig:b64key) - $SIGN"
        FILE=$(echo "$HASH.sign")
        echo $SIGN >> $FILE
        echo "\nThe signature was added to $HASH.sig file."
    fi
}

verify() {
}
