import json
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from typing import Any

from botocore.exceptions import ClientError
from mypy_boto3_s3 import S3Client


def get_file(bucket_name: str, s3: S3Client, key: str, path: Path) -> bool:
    try:
        s3.download_file(bucket_name, key, str(path))
    except ClientError as e:
        code = e.response.get("Error", {}).get("Code")
        if code in ("404", "NoSuchKey"):
            return False
        raise
    return True


def list_ids(bucket_name: str, s3: S3Client, prefix: str) -> set[str]:
    ids: set[str] = set()
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket_name, Prefix=prefix):
        for obj in page.get("Contents", []):
            key = obj.get("Key")
            if key is None:
                continue

            ids.add(key.removeprefix(prefix).removesuffix(".json"))

    return ids


def put_json(bucket_name: str, s3: S3Client, key: str, data: object) -> bool:
    try:
        s3.put_object(
            Bucket=bucket_name,
            Key=key,
            Body=json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8"),
        )
    except ClientError as e:
        print(f"failed to upload {key}: {e}")
        return False

    return True


def get_json(bucket_name: str, s3: S3Client, key: str) -> Any:
    obj = s3.get_object(Bucket=bucket_name, Key=key)
    return json.loads(obj["Body"].read())


def get_json_many(
    bucket_name: str, s3: S3Client, prefix: str, ids: list[str]
) -> dict[str, Any]:
    with ThreadPoolExecutor(max_workers=32) as pool:
        data = pool.map(
            lambda place_id: get_json(bucket_name, s3, f"{prefix}{place_id}.json"), ids
        )
    return dict(zip(ids, data))
