# sqlc-dts

A generic `sqlc` plugin that generates TypeScript declaration files (`.d.ts`) from SQL query metadata.

- No project-specific query logic
- Reusable across projects
- Supports both `process` and `wasm` plugin modes

## Generated Types

For each query `QueryName`, it generates:
- `QueryNameReq`
- `QueryNameRes`

And a lookup map:
- `apiTypes = { "QueryName": [QueryNameReq, QueryNameRes], ... }`

## Type Mapping

Mapping is based on `sqlc` metadata only (`type`, `not_null`, `is_array`, `array_dims`).

- `bool`, `boolean` -> `boolean`
- `smallint`, `int2`, `integer`, `int4`, `serial`, `serial4`, `smallserial` -> `number`
- `bigint`, `int8`, `bigserial`, `serial8`, `int` -> `number`
- `real`, `float4`, `float8`, `double precision`, `numeric`, `decimal` -> `number`
- `json`, `jsonb` -> `Record<string, any>`
- `uuid`, `text`, `varchar`, `bpchar`, `char`, `character varying`, `citext` -> `string`
- `timestamptz`, `timestamp`, `date`, `time`, `timetz`, `point` -> `string`

Fallback:
- contains `char`/`text`/`time` -> `string`
- contains `json` -> `Record<string, any>`
- numeric-ish unknown type with `is_func_call=true` -> `number`
- otherwise -> `any`

## Plugin Options

Pass via `sqlc` `codegen.options`:

```yaml
options:
  file_name: api-types.d.ts
  query_rename:
    OldQuery: NewQuery
  drop_params:
    SomeQuery:
      - internal_param
```

- `file_name`: output file name (default `api-types.d.ts`)
- `query_rename`: rename generated query type names
- `drop_params`: drop request fields by query name

## Build

### Local binary

```bash
go build -o sqlc-dts .
```

### WASM

```bash
./build-wasm.sh
```

Outputs:
- `dist/sqlc-dts.wasm`
- `dist/sqlc-dts.wasm.sha256`

## GitHub Actions (Auto Build on master)

Workflow file: `.github/workflows/release-wasm.yml`

On every push to `master`:
1. Build `sqlc-dts.wasm`
2. Compute SHA256
3. Upload to two releases:
   - immutable: `wasm-<commit-sha>`
   - rolling: `latest`

### HTTP URLs

After workflow succeeds:

Immutable URL (recommended for pinned builds):
- `https://github.com/<owner>/<repo>/releases/download/wasm-<commit-sha>/sqlc-dts.wasm`
- `https://github.com/<owner>/<repo>/releases/download/wasm-<commit-sha>/sqlc-dts.wasm.sha256`

Rolling URL (always newest artifact):
- `https://github.com/<owner>/<repo>/releases/latest/download/sqlc-dts.wasm`
- `https://github.com/<owner>/<repo>/releases/latest/download/sqlc-dts.wasm.sha256`

## sqlc Config Example (WASM)

```yaml
version: "2"
plugins:
  - name: dts
    wasm:
      url: "https://github.com/<owner>/<repo>/releases/download/wasm-<commit-sha>/sqlc-dts.wasm"
      sha256: "<sha256-from-.sha256-file>"
sql:
  - schema:
      - "./sql/schema.sql"
    queries:
      - "./sql/*.sql"
    engine: postgresql
    codegen:
      - out: ./types
        plugin: dts
```

## License

MIT
