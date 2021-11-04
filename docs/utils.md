# Signing file and directory manifests

**VIDEO EXPLANATION: https://youtu.be/_uYRIrkq-KE**

The repository root contains the file [utils.sh](https://raw.githubusercontent.com/mindey/ident/master/utils.sh), that contains `sign`, `dhash` and `solve` functions.

The `sign` function allows to produce the manifest (`.manifest` containing sha256 checksums) of target `<folder-or-file>`, and append one's own key's (`~/.ssh/id_rsa`) signature to the `.sign` file named with sha256 checksum of the `.manifest` file. It is useful when multiple parties want to create a list of signatures (`.sign`) file, proving their identity witness of folder or file content.

## Usage

### In Linux:

1. Generate RSA keypair by:

`ssh-keygen -m pem` (if you don't already have one)

2. Add the  [utils.sh](https://raw.githubusercontent.com/mindey/ident/master/utils.sh) content into `~/.bashrc` and source it (run `. ~/.bashrc`), or alternatively -- reopen terminal.

For [ZSH](https://ohmyz.sh/) users:
- wget: `wget -Oq- https://raw.githubusercontent.com/mindey/ident/master/utils.sh -O ~/.sign.sh && chmod a+x ~/.sign.sh && echo "\n# Signing #\n. ~/.sign.sh" >> ~/.zshrc`
- curl: `curl https://raw.githubusercontent.com/mindey/ident/master/utils.sh -o ~/.sign.sh && chmod a+x ~/.sign.sh && echo "\n# Signing #\n. ~/.sign.sh" >> ~/.zshrc`

For [BASH](https://www.gnu.org/software/bash/) users:
- wget: `wget -Oq- https://raw.githubusercontent.com/mindey/ident/master/utils.sh -O ~/.sign.sh && chmod a+x ~/.sign.sh && echo "\n# Signing #\n. ~/.sign.sh" >> ~/.bashrc`
- curl: `curl https://raw.githubusercontent.com/mindey/ident/master/utils.sh -o ~/.sign.sh && chmod a+x ~/.sign.sh && echo "\n# Signing #\n. ~/.sign.sh" >> ~/.bashrc`


3. Now, you can run:

`sign <folder-or-file>`

to produce signatures.

### In MacOS:

1. Install [XCode](https://developer.apple.com/xcode/) and [homebrew](https://brew.sh/), then:

`brew install coreutils`

2. Generate RSA keypair by:

`ssh-keygen -m pem` (if you don't already have one)

3. Add the  [utils.sh](https://raw.githubusercontent.com/mindey/ident/master/utils.sh) content into `~/.profile` and source it (run `. ~/.profile`), or alternatively -- reopen terminal.

For [BASH](https://www.gnu.org/software/bash/) users:
- curl: `curl https://raw.githubusercontent.com/mindey/ident/master/utils.sh -o ~/.sign.sh && chmod a+x ~/.sign.sh && echo ". ~/.sign.sh" >> ~/.bashrc`

Now, you can run:

`sign <folder-or-file>`

to produce signatures.

### In Windows:

1. Install [git-bash](https://gitforwindows.org/) on Windows

2. Generate RSA keypair by:

`ssh-keygen -m pem` (if you don't already have one)

(`-m` parameter is important, it doesn't work otherwise generated keys)

3. Add the  [utils.sh](https://raw.githubusercontent.com/mindey/ident/master/utils.sh) content into `~/.bashrc` and source it (run `. ~/.bashrc`), or alternatively -- reopen terminal.

For [BASH](https://www.gnu.org/software/bash/) users:
- curl: `curl https://raw.githubusercontent.com/mindey/ident/master/utils.sh -o ~/.sign.sh && chmod a+x ~/.sign.sh && echo ". ~/.sign.sh" >> ~/.bashrc`

Now, you can run:

`sign <folder-or-file>`

to produce signatures in the `.sign` file.


## Final verification.

`pip install ident`

Once you have accumulated all the signatures, and want to do final verification of the signing integrity, answer `"Y"` to the question at the end:

`Rename folder to the hash value for final verification? [y/N] Y`

Then, the folder or file signed will be renamed, and you can run the `verify` command from the Python3 `pip install ident` package, like so:

`verify -d <folder-or-file> -s <signature-file>.sig`

### For example:

```
$ verify -d 0bd263b05fa66f00aa8d963c310645624391e1af7a2efa0a30610e4dd791cd3f -s 63d1b91908456f6a42dc2a17ebec0d7668451804c8c9d944b99dd4b57f4302d4.sign
[OK] Manifest (.manifest) hash is in .sign filename.
[OK] Manifest (.manifest) hashes match folder's file hashes.

Verifying signatures one by one:
- mindey@world: [YES]
All signatures are valid.

Final hash is correct, and is as folder's name:
0bd263b05fa66f00aa8d963c310645624391e1af7a2efa0a30610e4dd791cd3f
(It is safe to write it to blockchain, as proof of data witness.)
```
