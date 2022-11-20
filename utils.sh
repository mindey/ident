sha256digest() {
    if [ "$(uname)" != "Darwin" ]; then
        echo $(shasum -a 256 $1)
    else
        echo $(sha256sum $1)
    fi
}

solve() {
    # Generate keypair with "ssh-keygen -m pem" (must use PKCS#8 format)
    # RSA signing input challenge string.
    if [ -z "$1" ]
      then
        echo "No arguments supplied"
      else
        if [ "$(uname)" != "Darwin" ]; then
            echo "$1" | openssl rsautl -sign -inkey ~/.ssh/id_rsa | base64 -w0 && echo -n ":" && cat ~/.ssh/id_rsa.pub | base64 -w0
        else
            echo "$1" | openssl rsautl -sign -inkey ~/.ssh/id_rsa | base64 | tr -d '\n' && echo -n ":" && cat ~/.ssh/id_rsa.pub | base64
        fi
    fi
}

dhash() {
    # SHA256 hashing directory or file .manifest
    if [[ -d $1 ]]; then
        # Note: https://worklifenotes.com/2020/03/05/get-sha256-hash-on-a-directory/
        if [ "$(uname)" != "Darwin" ]; then
            dir=$1; find "$dir" -type f -exec shasum -a 256 {} \; | awk '{print $1}' | LC_ALL=C sort -d > .manifest
        else
            dir=$1; find "$dir" -type f -exec sha256sum {} \; | awk '{print $1}' | LC_ALL=C sort -d > .manifest
        fi
        cat .manifest | sha256digest | awk '{print $1}'
    elif [[ -f $1 ]]; then
        cat $1 | sha256digest | awk '{print $1}' > .manifest
        cat .manifest | sha256digest | awk '{print $1}'
    elif [[ -z $1 ]]; then
        echo "NONE"
    else
        echo "NONE"
    fi

}

sign() {
    # RSA signing file or folder .manifest hash to .sign file, and saving SHA256 of the signatures as its name.
    if [ $1 = "-v" ]; then
        target=$2
        verbose=true
    else
        target=$1
        verbose=false
    fi

    if [ -z "$target" ]
      then
        echo "No arguments supplied"
      else
        if [ "$verbose" = true ]; then
            echo "0. Path argument was accepted:"
            echo "PATH = $target\n"
        fi
        HASH=$(dhash $target)
        if [ $HASH != "NONE" ]; then
            if [ "$verbose" = true ]; then
                echo "1. Manifest file .manifest of PATH content was generated:"
                echo "HASH = SHA256 .manifest = $HASH\n"
            fi
            WHO="$(whoami)@$(hostname)"
            SIGN=$(solve $HASH)
            if [ "$verbose" = true ]; then
                echo "2. Your RSA (~/.ssh/id_rsa) signature of the .manifest SHA256 was created:"
                echo "SIGNATURE(b64sig:b64key) = solve HASH = $SIGN\n"
            fi
            SIGN=$(echo -n "$WHO," && echo "$SIGN")
            FILE=$(echo "$HASH.sign")
            echo $SIGN >> $FILE
            if [ "$verbose" = true ]; then
                echo "3. This signature prefixed with $WHO, was added to $HASH.sign file."
            fi
            SHA=$(cat $FILE | sha256digest | awk '{print $1}')
            if [ "$verbose" = true ]; then
                echo "\n4. The SHA256 of $HASH.sign is:\n $SHA"
            fi

            # Do you want to rename folder to final hash value for verification?
            echo -n "Rename folder to the value of final hash? [Y/n] "
            read rename

            if [[ -z $rename ]]; then
                rename="Y"
            fi

            if [ "$rename" = "Y" ]; then

                if [[ $target != $SHA ]]; then
                    if [[ -d $target ]]; then
                        mv $target $SHA
                    elif [[ -f $target ]]; then
                        mkdir $SHA
                        mv $target $SHA
                    fi
                fi
                if [ "$verbose" = true ]; then
                    echo "\nSaving it by renaming PATH -> '$SHA'."
                    echo "Now, the folder name contains a proof of signatures to be saved to blockchain, but before it"
                    echo "you can verify the sigining integrity by the verify command from (pip install ident) package."
                fi
            fi

            # Do you want to append text-label to the folder name?
            echo -n "Are you the first party signing this data? [y/N] "
            read ifirst

            if [[ -z $ifirst ]]; then
                folder=""
            else
                if [ "$ifirst" = "y" ]; then
                    ifirst="Y"
                fi
                if [ "$ifirst" = "Y" ]; then
                    echo -n "Give a name to folder to store all results: "
                    read folder
                fi
            fi

            if [[ -z $folder ]]; then
            else
                mkdir $folder
                if [ "$rename" = "Y" ]; then
                    mv $SHA $folder
                else
                    mv $target $folder
                fi
                mv .manifest $folder
                mv $FILE $folder
            fi
            #ls .

            # Do you want to save the hash to blockchain?
            echo -n "Do you want to store the hash to blockchain: [y/N] "
            read saveit

            if [[ -z $saveit ]]; then

                echo "Not saving for now. Hash value: $SHA"

            elif [ "$saveit" = "Y" ] || [ "$saveit" = "y" ]; then

                echo "Choose a blockchain from the ones below:"
                echo " - [1] Solana (mainnet)"
                echo -n "Enter ID from above "
                read chain

                if [ -z "$chain" ]; then
                  echo "No chain selected. Skipping."
                else
                    if [ "$chain" = "1" ]; then
                        # 1. Solana Mainnet #
                        local result=$(solana config set --url https://api.mainnet-beta.solana.com)
                        local address=$(solana address)
                        local tx=$(solana transfer --allow-unfunded-recipient --with-memo $SHA $address 0.0)
                        local txid=${tx##*: }
                        echo "\nThe hash $SHA"
                        echo "was saved to transaction:"
                        echo "->  https://solscan.io/tx/$txid"
                        if [[ -z $folder ]]; then
                            echo "sol:$txid" >> ./tx
                        else
                            echo "sol:$txid" >> $folder/tx
                        fi
                    else
                        echo "Chosen chain isn't supported. Quitting. .sign hash value: $SHA"
                    fi
                fi
            fi

        else
            echo "Could not compute dhash of PATH. (dhash returned NONE)"
        fi
    fi
}

zipin() {
    FILE=$(echo "$1.zip")
    7za a -tzip -p -mem=AES256 "$FILE" "$1"
}

zipout() {
    7za x "$1"
}
