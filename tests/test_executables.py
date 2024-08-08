"""
Test if all binaries exist
"""

import shutil
import pytest


@pytest.mark.parametrize(("binary"), ["python3"])
def test_binaries(binary):
    """Check if binary exists"""
    assert shutil.which(binary)
