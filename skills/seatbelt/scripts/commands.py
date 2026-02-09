"""
seatbelt Commands

Commands:
- seatbelt_profile: Generate Seatbelt profile
- seatbelt_export: Export SBPL profile to file
- seatbelt_test: Test command in sandbox
"""

import subprocess
from pathlib import Path

from omni.foundation.api.decorators import skill_command

import structlog

logger = structlog.get_logger(__name__)


@skill_command(
    name="seatbelt_profile",
    category="generate",
    description="""
    Generate Seatbelt profile for macOS sandbox.

    Args:
        - profile: str - Profile type (default: "minimal")
        - skill_id: str - Skill identifier (default: "test")

    Returns:
        SBPL profile string.
    """,
)
async def seatbelt_profile(profile: str = "minimal", skill_id: str = "test") -> str:
    """Generate Seatbelt profile."""
    return generate_profile(profile)


@skill_command(
    name="seatbelt_export",
    category="export",
    description="""
    Export SBPL profile to file.

    Args:
        - profile: str - Profile type (default: "minimal")
        - output: str - Output file path (default: "/tmp/sandbox.sb")

    Returns:
        Export confirmation with file path.
    """,
)
async def seatbelt_export(profile: str = "minimal", output: str = "/tmp/sandbox.sb") -> str:
    """Export profile to file."""
    content = generate_profile(profile)
    Path(output).write_text(content)
    return f"[EXPORTED] {output}"


@skill_command(
    name="seatbelt_test",
    category="test",
    description="""
    Test command in sandbox.

    Args:
        - cmd: list[str] - Command to run (required)
        - profile: str - Profile type (default: "minimal")

    Returns:
        Command output or error.
    """,
)
async def seatbelt_test(cmd: list[str], profile: str = "minimal") -> str:
    """Test command in sandbox."""
    content = generate_profile(profile)
    Path("/tmp/test.sb").write_text(content)

    try:
        result = subprocess.run(
            ["sandbox-exec", "-f", "/tmp/test.sb"] + cmd,
            capture_output=True,
            text=True,
            timeout=10,
        )
        return f"[OUTPUT]\n{result.stdout}\n[ERROR]\n{result.stderr}"
    except FileNotFoundError:
        return "sandbox-exec not available on this platform"


def generate_profile(profile_type: str) -> str:
    """Generate SBPL profile."""
    profiles = {
        "minimal": """(version 1)
(deny default)
(allow file-read* (regex #"/.*"))
(allow file-write* (regex #"/tmp/.*"))
(allow file-write* (regex #"/var/folders/.*"))
(deny network*)
(allow process-exec* (literal "/bin/pwd"))
""",
        "standard": """(version 1)
(deny default)
(allow file-read* (regex #"/.*"))
(allow file-write* (regex #"/tmp/.*"))
(allow file-write* (regex #"/var/folders/.*"))
(allow network-bind (local ip))
(deny network*)
(allow process-fork)
(allow process-exec* (literal "/bin/pwd"))
(allow process-exec* (literal "/bin/ls"))
(allow process-exec* (literal "/bin/cat"))
""",
        "development": """(version 1)
(deny default)
(allow file-read* (regex #"/.*"))
(allow file-write* (regex #"/tmp/.*"))
(allow file-write* (regex #"/var/folders/.*"))
(allow network*)
(allow process-exec* (regex #"/usr/bin/.*"))
(allow process-exec* (regex #"/bin/.*"))
""",
    }
    return profiles.get(profile_type, profiles["minimal"])


__all__ = ["seatbelt_profile", "seatbelt_export", "seatbelt_test"]
