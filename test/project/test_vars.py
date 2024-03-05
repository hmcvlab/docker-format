"""
Created on Wed Oct 18 2023
CopyRight (c) 2023 Munich University of Applied Sciences
"""

import re
from pathlib import Path

from git import Repo

PROJECT_ROOT = Path(Repo(".", search_parent_directories=True).working_tree_dir)


def test_tag():
    """Check if tag file exists and content has the following format: 0.0.0"""
    file = PROJECT_ROOT / "vars" / "tag"
    assert file.exists()
    content = file.read_text(encoding="utf-8")
    assert re.match(r"^\d+\.\d+\.\d+$", content) is not None
