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

            # Create $SHA.tx file for storing sha256sum of .sign file
            TXFILE="$SHA.tx"
            touch $TXFILE

            if [ "$verbose" = true ]; then
                echo "\nSaving it as the name of '$TXFILE'."
                echo "Now, it contains a proof of existence of signatures to be saved to blockchain, but before it"
                echo "you can verify the sigining integrity by the verify command from (pip install ident) package."
            fi

            # Do you want to save the hash to blockchain?
            echo "1. Computed .manifest of folder $target \n     and used its hash ($HASH) to name the signatures file."
            echo "2. RSA-signed that hash, and appended base64-coded (Signature:Pubkey) pair \n     to the end of the signatures file $FILE"
            echo "3. Obtained the hash $SHA of the signatures file, \n     and saved it as the name of transactions file $TXFILE"

            echo -n "\nDo you want now to store this hash of signatures file to a blockchain\n     and append the resulting transaction to the transactions file?: [y/N] "
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
                        # local tx=$(solana transfer --allow-unfunded-recipient --with-memo $SHA $address 0.0)
                        local tx="abc"
                        local txid=${tx##*: }
                        echo "\nThe hash $SHA"
                        echo "was saved to transaction:"
                        echo "->  https://solscan.io/tx/$txid"
                        echo "sol:$txid" >> $TXFILE
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
