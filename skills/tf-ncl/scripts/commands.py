"""
tf-ncl Commands

Commands:
- tfsec_scan: Scan Terraform for security issues
- tf_to_ncl: Convert Terraform HCL to Nickel
- tf_validate: Validate Terraform configurations
- tf_plan: Generate Terraform plan
"""

import subprocess
from pathlib import Path

from omni.foundation.api.decorators import skill_command

import structlog

logger = structlog.get_logger(__name__)


@skill_command(
    name="tfsec_scan",
    category="analyze",
    description="""
    Scan Terraform files for security issues using tfsec.

    Args:
        - path: str - Directory or file to scan (default: ".")

    Returns:
        Security findings report.
    """,
)
async def tfsec_scan(path: str = ".") -> str:
    """Scan Terraform for security issues."""
    try:
        result = subprocess.run(
            ["tfsec", path],
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode == 0:
            return f"[SECURE] No issues found in {path}"
        return f"[SECURITY ISSUES]\n{result.stdout}"
    except FileNotFoundError:
        return "tfsec not installed. Install: brew install tfsec"


@skill_command(
    name="tf_to_ncl",
    category="convert",
    description="""
    Convert Terraform HCL to Nickel format.

    Args:
        - tf_file: str - Terraform .tf file (required)
        - output: str - Output NCL file (optional)

    Returns:
        Conversion result with file path.
    """,
)
async def tf_to_ncl(tf_file: str, output: str | None = None) -> str:
    """Convert Terraform HCL to Nickel."""
    tf_path = Path(tf_file)
    if not tf_path.exists():
        return f"Error: {tf_file} not found"

    content = tf_path.read_text()
    ncl_content = convert_hcl_to_ncl(content)

    out_path = Path(output) if output else tf_path.with_suffix(".ncl")
    out_path.write_text(ncl_content)

    return f"[CONVERTED] {tf_file} -> {out_path}"


@skill_command(
    name="tf_validate",
    category="validate",
    description="""
    Validate Terraform configurations.

    Args:
        - path: str - Directory to validate (default: ".")

    Returns:
        Validation result.
    """,
)
async def tf_validate(path: str = ".") -> str:
    """Validate Terraform."""
    try:
        result = subprocess.run(
            ["terraform", "validate", path],
            capture_output=True,
            text=True,
            timeout=60,
        )
        return f"[VALID] {result.stdout}" if result.returncode == 0 else f"[ERROR] {result.stderr}"
    except FileNotFoundError:
        return "terraform not installed"


@skill_command(
    name="tf_plan",
    category="analyze",
    description="""
    Generate Terraform plan.

    Args:
        - path: str - Directory for plan (default: ".")

    Returns:
        Terraform plan output.
    """,
)
async def tf_plan(path: str = ".") -> str:
    """Generate Terraform plan."""
    try:
        result = subprocess.run(
            ["terraform", "plan", "-out=plan.tfplan", path],
            capture_output=True,
            text=True,
            timeout=120,
        )
        return f"[PLAN] {result.stdout[:2000]}" if result.returncode == 0 else f"[ERROR] {result.stderr}"
    except FileNotFoundError:
        return "terraform not installed"


def convert_hcl_to_ncl(hcl_content: str) -> str:
    """Basic HCL to NCL conversion."""
    # This is a simplified converter
    # In production, use a proper parser
    lines = hcl_content.split("\n")
    ncl_lines = ["{"]

    for line in lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" in line:
            key, value = line.split("=", 1)
            key = key.strip().replace('"', "")
            value = value.strip().rstrip(",")
            if value.startswith("{") or value.startswith("["):
                ncl_lines.append(f"  {key} = {value},")
            elif value.startswith('"') and value.endswith('"'):
                ncl_lines.append(f"  {key} = {value},")
            else:
                ncl_lines.append(f"  {key} = {value},")

    ncl_lines.append("}")
    return "\n".join(ncl_lines)


__all__ = ["tfsec_scan", "tf_to_ncl", "tf_validate", "tf_plan"]
