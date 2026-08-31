# reconstructor.py
import os

def build_structure_plan(analysis_results):
    # Accepts list of per-file analyses and returns markdown plan (string)
    md = "# Proposed Project Structure\n\n"
    md += "*(Generated plan based on analysis)*\n\n"
    # simple placeholder
    md += "```\nproject/\n  src/\n  README.md\n  scripts/\n```\n"
    return md
