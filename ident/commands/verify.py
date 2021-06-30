#!/usr/bin/python3
import json, os, re, argparse, pathlib
from collections import defaultdict
import subprocess

from ident import verify

class SignFileExtensionError(Exception):
    """The signatures file must have .sign extension."""

class SignFilenameInvalidError(Exception):
    """The hash contained before .sign does not match sha256sum of .manifest."""

class ManifestNotFound(Exception):
    """Manifest (.manifest) file not found."""

class ManifestMismatchFolderError(Exception):
    """Manifest (.manifest) file hashes do not match location's content hashes."""

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dir', help='Source directory.')
    parser.add_argument('-s', '--sig', help='Signatures file.')
    parser.add_argument('-m', '--man', help='Manifest file.')
    args = parser.parse_args()

    CWD = pathlib.Path(os.getcwd())
    DIR = pathlib.Path(args.dir)
    SIG = pathlib.Path(args.sig)
    MAN = pathlib.Path(args.man or '.manifest')

    directory = os.path.join(CWD, DIR)
    manifest = os.path.join(CWD, MAN)
    signatures = os.path.join(CWD, SIG)

    # Reading signatures file content
    if not args.sig.endswith('.sign'):
        raise SignFileExtensionError

    challenge_message = args.sig.split('.sign', 1)[0]

    # Verify challenge message (must be equal to .manifest hash)
    if os.path.exists(manifest):
        manihash = subprocess.getoutput("sha256sum %s | awk '{print $1}'" % manifest)

        if challenge_message == manihash:
            print("[OK] Manifest (.manifest) hash is in .sign filename.")
        else:
            print("[--] Wrong manifest hash: mismating .sign filename.")
            raise SignFilenameInvalidError
    else:
        raise ManifestNotFound

    # Verify that manifest is correct, and reflects files:
    manifest_file_hashes = open(manifest).read().splitlines()
    prefix = f'location="{directory}"; '
    command = prefix + """find "$location" -type f -exec sha256sum {} \; | awk '{print $1}' | LC_ALL=C sort -d"""
    folder_file_hashes = subprocess.getoutput(command).splitlines()

    if manifest_file_hashes == folder_file_hashes:
        print(f"[OK] Manifest (.manifest) hashes match folder's file hashes.")
    else:
        print(f"[--] Manifest (.manifest) file hashes do not match location's ({directory}) content hashes.")
        raise ManifestMismatchFolderError

    # Verify Signatures
    print(f"\nVerifying signatures one by one:")
    successes_list = []

    for line in open(signatures, 'r').read().splitlines():
        name, sign = line.split(',', 1)
        result = verify(sign)

        line_success = False
        if result['success']:
            recovered_message = result.get('recovered_challenge_message')
            if recovered_message:
                if recovered_message == challenge_message:
                    line_success = True

        if line_success:
            print(f'- {name}: [YES]')
            successes_list += [True]
        else:
            print(f'- {name}: [NO]')
            successes_list += [False]

    if all(successes_list):
        print("All signatures are valid.")
        print(f"\nFinal hash is correct, and is as folder's name:\n{DIR}")
        print("(It is safe to write it to blockchain, as proof of data witness.)")
    elif any(successes_list):
        print("Not all signatures are valid.")
    else:
        print("No valid signatures found.")

if __name__ == '__main__':
    main()
