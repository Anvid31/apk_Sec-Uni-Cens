#!/usr/bin/env python3
"""
Exporta la tabla surveys de PostgreSQL a Shapefile (puntos WGS84).

Uso:
  python3 scripts/export_shapefile.py
  python3 scripts/export_shapefile.py --output exports/sedes.shp

Variables de entorno (o .env en la raíz del proyecto):
  PG_HOST, PG_PORT, PG_DB, PG_USER, PG_PASSWORD
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import zipfile
from datetime import datetime
from pathlib import Path

try:
    import psycopg2
    import shapefile  # pyshp
except ImportError as exc:
    print(
        "Faltan dependencias. Instala con:\n"
        "  pip install psycopg2-binary pyshp",
        file=sys.stderr,
    )
    raise SystemExit(1) from exc

ROOT = Path(__file__).resolve().parents[1]
PHOTO_RE = re.compile(r"^photo", re.I)

PRJ_WKT = (
    'GEOGCS["GCS_WGS_1984",'
    'DATUM["D_WGS_1984",'
    'SPHEROID["WGS_1984",6378137.0,298.257223563]],'
    'PRIMEM["Greenwich",0.0],'
    'UNIT["Degree",0.0174532925199433]]'
)

RESERVED = {
    "ID",
    "CREATED_AT",
    "FORM_TYPE",
    "INSTITUTION",
    "DANE_CODE",
    "MUNICIPALITY",
    "DEPARTMENT",
    "LATITUDE",
    "LONGITUDE",
}


def load_env() -> dict[str, str]:
    env = {
        "PG_HOST": os.getenv("PG_HOST", "127.0.0.1"),
        "PG_PORT": os.getenv("PG_PORT", "5432"),
        "PG_DB": os.getenv("PG_DB", "caracterizacion_cens"),
        "PG_USER": os.getenv("PG_USER", "caract_user"),
        "PG_PASSWORD": os.getenv("PG_PASSWORD", "caract_dev_pass"),
    }
    dotenv = ROOT / ".env"
    if dotenv.exists():
        for line in dotenv.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key.startswith("PG_") and key not in os.environ:
                env[key] = value
    return env


def logical_key(key: str) -> str:
    key = re.sub(r"([a-z])([A-Z])", r"\1_\2", key)
    key = re.sub(r"[^A-Za-z0-9_]", "_", key)
    return key.upper()


def value_to_string(value) -> str:
    if value is None:
        return ""
    if isinstance(value, bool):
        return "Si" if value else "No"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, list):
        return ", ".join(value_to_string(v) for v in value if v is not None)
    if isinstance(value, dict):
        return json.dumps(value, ensure_ascii=False)
    return str(value)


def summarize_mobiliario(data: dict) -> str:
    parts = []
    for code, item in data.items():
        if not isinstance(item, dict):
            continue
        cant = item.get("cantidad")
        if cant is not None:
            parts.append(f"{code}:{cant}")
    return "; ".join(parts)


def summarize_electro(data: dict) -> str:
    parts = []
    for name, item in data.items():
        if not isinstance(item, dict):
            continue
        tiene = item.get("tiene", "")
        cant = item.get("cantidad")
        suffix = f"({cant})" if cant is not None else ""
        parts.append(f"{name}:{tiene}{suffix}")
    return "; ".join(parts)


def normalize_data(data: dict) -> dict:
    if data.get("formType") == "unified" or "schoolName" in data:
        return dict(data)

    sections = {
        "generalInfo": "GEN",
        "informacionGeneral": "GEN",
        "institutionalInfo": "INST",
        "informacionInstitucional": "INST",
        "coverageInfo": "COV",
        "electricityInfo": "ELEC",
        "accessRouteInfo": "ACCESS",
        "observationsInfo": "OBS",
    }
    out: dict = {}
    for key, value in data.items():
        prefix = sections.get(key)
        if prefix and isinstance(value, dict):
            for inner_k, inner_v in value.items():
                out[f"{prefix}_{inner_k}"] = inner_v
        else:
            out[key] = value
    return out


def flatten_row(row: dict) -> dict[str, str]:
    data = row["data"] if isinstance(row["data"], dict) else {}
    normalized = normalize_data(data)

    created = row.get("created_at")
    if isinstance(created, datetime):
        created_str = created.isoformat()[:19]
    else:
        created_str = str(created or "")[:19]

    out: dict[str, str] = {
        "ID": str(row.get("id", ""))[:50],
        "CREATED_AT": created_str,
        "FORM_TYPE": str(row.get("form_type", ""))[:20],
        "INSTITUTION": str(row.get("institution", ""))[:100],
        "DANE_CODE": str(row.get("dane_code", ""))[:20],
        "MUNICIPALITY": str(row.get("municipality", ""))[:50],
        "DEPARTMENT": str(row.get("department", ""))[:50],
        "LATITUDE": f"{float(row['latitude']):.8f}",
        "LONGITUDE": f"{float(row['longitude']):.8f}",
    }

    for raw_key, value in normalized.items():
        if PHOTO_RE.match(raw_key):
            continue
        if raw_key in ("mobiliario", "electrodomesticos"):
            continue
        key = logical_key(raw_key)
        if key in RESERVED:
            continue
        if isinstance(value, dict):
            if len(value) <= 4 and not any(isinstance(v, dict) for v in value.values()):
                for inner_k, inner_v in value.items():
                    sub = logical_key(f"{raw_key}_{inner_k}")
                    if sub not in RESERVED:
                        out[sub] = value_to_string(inner_v)[:100]
            continue
        text = value_to_string(value)
        if text:
            out[key] = text[:100]

    if isinstance(normalized.get("mobiliario"), dict):
        out["MOBILIARIO"] = summarize_mobiliario(normalized["mobiliario"])[:200]
    if isinstance(normalized.get("electrodomesticos"), dict):
        out["ELECTRODOM"] = summarize_electro(normalized["electrodomesticos"])[:200]

    return out


def unique_dbf_name(key: str, used: set[str]) -> str:
    base = key[:10]
    if base not in used:
        used.add(base)
        return base
    for i in range(1, 100):
        suffix = str(i)
        candidate = f"{key[: 10 - len(suffix)]}{suffix}"
        if candidate not in used:
            used.add(candidate)
            return candidate
    return base


def build_schema(rows: list[dict[str, str]]) -> list[tuple[str, str, str, int, int]]:
    keys: set[str] = set()
    for row in rows:
        keys.update(row.keys())

    priority = [
        "ID",
        "CREATED_AT",
        "FORM_TYPE",
        "INSTITUTION",
        "DANE_CODE",
        "MUNICIPALITY",
        "DEPARTMENT",
        "LATITUDE",
        "LONGITUDE",
        "MOBILIARIO",
        "ELECTRODOM",
    ]
    ordered = [k for k in priority if k in keys] + sorted(k for k in keys if k not in priority)

    used: set[str] = set()
    schema: list[tuple[str, str, str, int, int]] = []
    for key in ordered:
        dbf = unique_dbf_name(key, used)
        if key in ("LATITUDE", "LONGITUDE"):
            schema.append((key, dbf, "N", 18, 8))
        elif all((row.get(key, "") == "" or _is_number(row.get(key, ""))) for row in rows) and any(
            row.get(key, "") for row in rows
        ):
            schema.append((key, dbf, "N", 12, 0))
        else:
            max_len = max((len(row.get(key, "")) for row in rows), default=20)
            schema.append((key, dbf, "C", min(max(max_len, 20), 100), 0))
    return schema


def _is_number(value: str) -> bool:
    try:
        float(value)
        return True
    except ValueError:
        return False


def fetch_rows(env: dict[str, str]) -> list[dict]:
    conn = psycopg2.connect(
        host=env["PG_HOST"],
        port=int(env["PG_PORT"]),
        dbname=env["PG_DB"],
        user=env["PG_USER"],
        password=env["PG_PASSWORD"],
    )
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, created_at, form_type, institution, dane_code,
                       municipality, department, latitude, longitude, data
                FROM surveys
                WHERE latitude IS NOT NULL AND longitude IS NOT NULL
                ORDER BY institution
                """
            )
            columns = [desc[0] for desc in cur.description]
            result = []
            for record in cur.fetchall():
                row = dict(zip(columns, record))
                if isinstance(row["data"], str):
                    row["data"] = json.loads(row["data"])
                result.append(row)
            return result
    finally:
        conn.close()


def write_shapefile(
    rows: list[dict[str, str]],
    coords: list[tuple[float, float]],
    output_base: Path,
) -> Path:
    schema = build_schema(rows)
    shp_path = output_base.with_suffix("")
    writer = shapefile.Writer(str(shp_path), shapeType=shapefile.POINT)

    for _, dbf_name, field_type, length, decimals in schema:
        if field_type == "N":
            writer.field(dbf_name, field_type, size=length, decimal=decimals)
        else:
            writer.field(dbf_name, field_type, size=length)

    for row, (lat, lon) in zip(rows, coords):
        writer.point(lon, lat)
        record = []
        for source_key, _, field_type, length, decimals in schema:
            raw = row.get(source_key, "")
            if field_type == "N":
                if decimals:
                    record.append(float(raw) if raw else 0.0)
                else:
                    record.append(int(float(raw)) if raw else 0)
            else:
                record.append(str(raw)[:length])
        writer.record(*record)

    writer.close()

    prj_path = Path(f"{shp_path}.prj")
    prj_path.write_text(PRJ_WKT, encoding="ascii")

    zip_path = output_base if output_base.suffix == ".zip" else output_base.with_suffix(".zip")
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for ext in (".shp", ".shx", ".dbf", ".prj"):
            file_path = Path(f"{shp_path}{ext}")
            zf.write(file_path, arcname=f"{shp_path.name}{ext}")

    return zip_path


def main() -> int:
    parser = argparse.ArgumentParser(description="Exportar surveys a Shapefile")
    parser.add_argument(
        "--output",
        "-o",
        default=str(ROOT / "exports" / "caracterizacion_sedes.zip"),
        help="Ruta del ZIP de salida",
    )
    args = parser.parse_args()

    env = load_env()
    db_rows = fetch_rows(env)
    if not db_rows:
        print("No hay registros con coordenadas en surveys.")
        return 1

    flat_rows = [flatten_row(r) for r in db_rows]
    coords = [(float(r["latitude"]), float(r["longitude"])) for r in db_rows]

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    zip_path = write_shapefile(flat_rows, coords, output)

    print(f"✅ Exportados {len(flat_rows)} puntos → {zip_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
