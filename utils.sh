solve(){
    # RSA signing input challenge string.
    if [ -z "$1" ]
      then
        echo "No arguments supplied"
      else
        if [ "$(uname)" != "Darwin" ]; then
            echo "$1" | openssl rsautl -sign -inkey ~/.ssh/id_rsa | base64 -w0 && echo -n ":" && cat ~/.ssh/id_rsa.pub | base64 -w0
        else
            echo "$1" | openssl rsautl -sign -inkey ~/.ssh/id_rsa | base64 && echo -n ":" && cat ~/.ssh/id_rsa.pub | base64
        fi
    fi
}

dhash() {
    # SHA256 hashing directory or file .manifest
    if [[ -d $1 ]]; then
        dir=$1; find "$dir" -type f -exec sha256sum {} \; | awk '{print $1}' | sed "s~$dir~~g" | LC_ALL=C sort -d > .manifest
        cat .manifest | sha256sum | awk '{print $1}'
    elif [[ -f $1 ]]; then
        cat $1 | sha256sum | awk '{print $1}' > .manifest
        cat .manifest | sha256sum | awk '{print $1}'
    elif [[ -z $1 ]]; then
        echo "NONE"
    else
        echo "NONE"
    fi

}

sign() {
    # RSA signing file or folder .manifest hash to .sign file, and saving signatures SHA256 sum as its name.
    if [ -z "$1" ]
      then
        echo "No arguments supplied"
      else
        echo "0. Path argument was accepted:"
        echo "PATH = $1\n"
        HASH=$(dhash $1)
        if [ $HASH != "NONE" ]; then
            echo "1. Manifest file .manifest of PATH content was generated:"
            echo "HASH = sha256sum .manifest = $HASH\n"
            WHO="$(whoami)@$(hostname)"
            SIGN=$(solve $HASH)
            echo "2. Your RSA (~/.ssh/id_rsa) signature of the .manifest SHA256 was created:"
            echo "SIGNATURE(b64sig:b64key) = solve HASH = $SIGN\n"
            SIGN=$(echo -n "$WHO," && echo "$SIGN")
            FILE=$(echo "$HASH.sign")
            echo $SIGN >> $FILE
            echo "3. This signature prefixed with $WHO, was added to $HASH.sign file."
            SHA=$(cat $FILE | sha256sum | awk '{print $1}')
            echo "\n4. The SHA256 of $HASH.sign is:\n $SHA"
            if [[ $1 != $SHA ]]; then
                mv $1 $SHA
            fi
            echo "\nSaving it by renaming PATH -> '$SHA'."
            echo "Now, the folder name contains a proof of signatures to be saved to blockchain, but before it"
            echo "you can verify the sigining integrity by the verify command from (pip install ident) package."
        else
            echo "Could not compute dhash of PATH. (dhash returned NONE)"
        fi
    fi
}
