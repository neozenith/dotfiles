import subprocess
from pathlib import Path
from itertools import groupby

def update_pyenv():
    """Update with latest information."""
    PYENV_HOME=Path.home() / ".pyenv"
    subprocess.run("git pull", capture_output=True, shell=True, text=True, cwd=PYENV_HOME)

def tidy_versions():
    # Get all available versions
    result = subprocess.run("pyenv install --list", capture_output=True, shell=True, text=True)

    # Get all python versions that are only X.Y.Z format and only digits. No dev or alpha versions etc
    return {
        pyversion.strip(): tuple([int(d) for d in pyversion.strip().split(".")])  
        for pyversion in result.stdout.strip().split("\n") 
        if pyversion.strip().startswith("3.") and all([d.isdigit() for d in pyversion.strip().split(".")])
    }

def max_patched_versions():
    # Group tuples by the minor version number
    grouped_versions = groupby(tidy_versions().values(), lambda v: v[1] )
    # Tuple sort to get the largest within each group
    return [
        '.'.join([str(n) for n in list(v)]) # Convert tuple back to dot formatted string
        for v in sorted([
            max(g, key=lambda x: x) 
            for k, g in grouped_versions
        ], reverse=True)
    ]


if __name__ == "__main__":
    update_pyenv()
    print("\n".join([f"pyenv install {v}" for v in max_patched_versions()[:3]]))
    