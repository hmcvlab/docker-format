import shutil


def test_binaries():
    """Check if binary exists"""
    assert shutil.which("python3")
