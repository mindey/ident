from ident import sign, verify


def test_verify():
    challenge_msg = 'MyChallengeMessage'
    result = sign(challenge_msg)
    verification_dict = verify(result)

    assert verification_dict['recovered_challenge_message'] == challenge_msg


