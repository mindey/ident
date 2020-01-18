from ident import sign, verify


def test_fail_gracefully():
    challenge_msg = 'MyChallengeMessage'
    result = sign(challenge_msg)
    result += '1'
    verification_dict = verify(result)

    assert verification_dict['recovered_challenge_message'] == 'UNKNOWN'



