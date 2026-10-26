import json
from pathlib import Path

from openai.types.shared_params.response_format_json_schema import JSONSchema

DIR = Path(__file__).resolve().parent.parent / "prompts"


def load(name: str) -> tuple[str, JSONSchema]:
    with open(DIR / f"{name}.json") as f:
        schema: JSONSchema = json.load(f)
    with open(DIR / f"{name}.md") as f:
        system = (
            f.read()
            + "\n\n### Schema\n"
            + json.dumps(schema, ensure_ascii=False, indent=2)
        )
    return system, schema
