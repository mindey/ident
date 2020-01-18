# 1. Add this function to your `~/.bashrc` or `~/.zshrc`:
```
solve(){
    if [ -z "$1" ]
      then
        echo "No arguments supplied"
    fi
    echo "$1" | openssl rsautl -sign -inkey ~/.ssh/id_rsa | base64 -w 0 && echo -n ":" && cat ~/.ssh/id_rsa.pub | base64 -w 0
}
```

# 2. Open new terminal, and type:
$ solve MyChallengeMessage

Alternatively, generate challenge response by:
```python
from ident import sign

result = sign('MyChallengeMessage')
```

```python
from ident import verify

verify('cpvVd42+ugHiw/7FThW3qzywUEweRNGM9ISzGWgU0R5OajQ0dAZmkxDJeTf3Cxr8f3cQZN5t9KP9ONIEYjjmqTP90GJaUuwjB/OgDa++Gr6VtCg7KVV0hZUP+bhbxCeo9QV/SOJWI3KBOWfvhrySTC3ehxVK+ZaS+2WIhY9+bX1UbFLwMFhVo42JKs+DuhzU39NRC72ria5Phm8fzoYh13j5gr5g4zr22jlWwshzoGLKI2DCz1EYEOuTLZlZ1gSN3L4yHxKUAi9Y+U1BtgbV7Qz63q3by5zI5SatSdh/shdPrTVGzZQ1og/PBuvIv7A41VV2LVAfRIvYV8Cuy+RJl4+hvntlOeNlGyViE1+4EBsP6cMK4KsM4iktgaXrn1dA1kDyrv2an01b1lRzUbZXcJlum9hTZwB3RrJ1pmTxXhgDCiV9ZxYfvmj8sTflXuBai9u73EyeH3fR1pCARJP9a3lDAn/DvMTGy2pCayAqzXfrYvlNTE/JxQnPWZd2ozF2iH9I1Y5DElgwo0feKr2UIk/bBY3VKXFT5TvhAzatn2iDcUm4kxE+ydYuGTE+PunZBD//AqhwUc1bdDa0tPSRtdhdAw75mBJrATxJOHuDzQimW9ba3Vs2Xbas0v1Dj1O1Vc1XVl44XUFNalEQpJSM77mmKua02yXJt4ovTwwhI10=:c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFDQVFDclRsaksxb08rL3RlVnl0cTBqcmdpQ2ZxTmhRQ3h5OTcwZEY4TmVQL3NBZ2xicDFVaGxiOURhY0pBK1hGblFzOHJJOFFFQTloSmJ3YWVnUlE4YVVKR1FiekhCV1lYclJYWFZrUDJ1RmJwMHZRL1pLUXlwSG4zV25tM3J6UlBrMytMUFQwWHZvamNlaVdZekMrckNWNWpiR2IrcnlKMGRVUVo5S0lNVlczdVR6YVJlRWYvbTBuSlB4M0FCTmcvL1VQUGhRRGJNSVdsZHhZazZadmhmV3VKUVhVSWlzK3VOdzVwd2hTY0Ixd0NwYit1QUFiSG5Ib3RWdTJtR2dHQk9MRERDbTN4dVFtSHJhRUx3WWFmWUdZTmp3NUozNmNIN3puZnVTTC8xWk5Fb0YvaWFNMCtKNW9yaU54VndNY2gvWjdnVTRHMEh6TkZCM0xqaFJEVGN2cDlaRGRha0E3aHVoaWYxWms4am81VjR3YjJVNkJZR1d6NVVHZitCRVdWNlRzZGlLK0pvMDF4MDQ3T1pKTUR6REVYNFFaMGdQLzZ6YmNWd1p5Y1RvWWhTUmJGS3BadWY1RDBJMmFta2RxUWV2dHkzc290MWlIekRhWnJ4anpOclp3b0l0ZE05R2tTUmhadmRZQ28vRm9wZGNUcnJOeUNhT3diU2QzTjE5d25YYXFPWWhZL01jL2VBaEVUenVxc3VwTERHZVlqVG9pSHF0aUtJRnpMOWwrYlRWNEVmMUxaOUpJNm1tR0U0TUlQakFxbnB1cjlNbXF3ZkY1bHhPR3BRV1NaVUZWU3VNQXhVNUJuY0Q5Rnp5cHpNUlM0Q0V1aFQ4dERnWGI3S1VPT0dTdy9udG8xaVlsVy9FMVo0L01GbkZLdlJqRFFnaEFoRlJjU2UrYWRVdVVDMlE9PSBtaW5kZXlAYXJjaHBjLTIwMTUtMDctMjUK')
```

**Note.** There is a colon (':') in the string produced, which separates the base64-encoded signature (left) from the public key (right).
