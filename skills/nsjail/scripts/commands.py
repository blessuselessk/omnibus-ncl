"""
nsjail Commands

Commands:
- nsjail_config: Generate nsjail configuration
- nsjail_profile: Generate nsjail profile
- nsjail_run: Run command in nsjail
"""

import subprocess
from pathlib import Path

from omni.foundation.api.decorators import skill_command

import structlog

logger = structlog.get_logger(__name__)


@skill_command(
    name="nsjail_config",
    category="generate",
    description="""
    Generate nsjail configuration for skill execution.

    Args:
        - skill_id: str - Skill identifier (required)
        - mode: str - Execution mode (default: "local")
        - timeout: int - Timeout in seconds (default: 30)

    Returns:
        nsjail configuration string.
    """,
)
async def nsjail_config(skill_id: str, mode: str = "local", timeout: int = 30) -> str:
    """Generate nsjail configuration."""
    config = generate_config(skill_id, mode, timeout)
    return config


@skill_command(
    name="nsjail_profile",
    category="generate",
    description="""
    Generate nsjail profile for skills.

    Args:
        - profile_type: str - Profile: minimal, standard, development
        - skill_id: str - Skill identifier (required)

    Returns:
        nsjail profile string.
    """,
)
async def nsjail_profile(profile_type: str = "minimal", skill_id: str = "test") -> str:
    """Generate nsjail profile."""
    profile = generate_profile(profile_type, skill_id)
    return profile


@skill_command(
    name="nsjail_run",
    category="execute",
    description="""
    Run command in nsjail sandbox.

    Args:
        - cmd: list[str] - Command to run (required)
        - mode: str - Execution mode (default: "local")
        - timeout: int - Timeout in seconds (default: 30)

    Returns:
        Command output.
    """,
)
async def nsjail_run(cmd: list[str], mode: str = "local", timeout: int = 30) -> str:
    """Run command in nsjail."""
    try:
        result = subprocess.run(
            ["nsjail", "-m", "-R", "/", "-R", "/tmp", "-R", "/usr"] + cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return f"[OUTPUT]\n{result.stdout}\n[ERROR]\n{result.stderr}"
    except FileNotFoundError:
        return "nsjail not installed"


def generate_config(skill_id: str, mode: str, timeout: int) -> str:
    """Generate nsjail config."""
    return f"""
# nsjail config for {skill_id}
mode = {mode}
timeout = {timeout}
"""


def generate_profile(profile_type: str, skill_id: str) -> str:
    """Generate nsjail profile."""
    profiles = {
        "minimal": 'mode: NONE\nrlimit_as: 134217728\nrlimit_cpu: 30\n',
        "standard": 'mode: LOCAL\nrlimit_as: 268435456\nrlimit_cpu: 60\n',
        "development": 'mode: NET\nrlimit_as: 536870912\nrlimit_cpu: 300\n',
    }
    return profiles.get(profile_type, profiles["minimal"])


__all__ = ["nsjail_config", "nsjail_profile", "nsjail_run"]
