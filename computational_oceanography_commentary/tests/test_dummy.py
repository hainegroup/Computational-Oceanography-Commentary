import pytest
from computational_oceanography_commentary.dummy import dummy_foo


def test_dummy():
    assert dummy_foo(4) == (4 + 4)
