# Local dbt Core + DuckDB Workspace

This project is a local learning workspace for dbt Core and DuckDB.

## Layout

- `dbt_project.yml`: dbt project identity and model discovery configuration.
- `requirements.txt`: pinned dbt-duckdb adapter dependency.
- `models/`: contains dbt models.
- `specs/`: reserved for short transformation specs before implementation.
- `data/`: local DuckDB database location; database files are ignored by Git.
- `.venv/`: local Python environment created by the setup commands; ignored by Git.

For a lightweight spec-driven workflow, a future spec can state the model's
purpose, grain, inputs, transformation rules, assumptions, and expected behavior
before its SQL model is written. No spec or model is included yet.

## Current project status

This project is in the Data Vault build-out phase. The basic structure is in
place and the model layers are split into staging, hubs, satellites, and links.

Current state:

- staging models for customers, sales orders, and sales order items
- hub models for customers, sales orders, and sales order position items
- satellite models for customer, order, and order item details
- link models for customer-to-order and order-to-order-item relationships
- local DuckDB profile configured for a project-local database


## Create the Python environment

From this directory in WSL, check that Python is at least 3.10, then create and
activate a project-local virtual environment:

```bash
python3 --version
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```


## Configure the dbt profile

For dbt Core, the default profile file is `~/.dbt/profiles.yml` in the WSL home
directory. The profile name below must match `profile` in `dbt_project.yml`.

If the file does not exist, create it after making its parent directory:

```bash
mkdir -p ~/.dbt
nano ~/.dbt/profiles.yml
```

Add this profile block, replacing `<your-linux-username>` with the username
shown by `whoami`:

```yaml
dbt_learning_local:
	target: dev
	outputs:
		dev:
			type: duckdb
			path: /home/<your-linux-username>/repos/dbt_project/data/learning.duckdb
```

If `profiles.yml` already exists, do not replace it. Add only the
`dbt_learning_local:` block at the top level, or merge its `outputs` and
`target` under that profile if the profile name is already present. Keep all
other profiles unchanged. The configured database path should be an absolute
Linux path under this project. The adapter resolves relative `path` values
from the profile file's location, not from the project directory.

DuckDB creates the database file when a command connects; scaffolding itself
does not create it.

## Verify the setup

With `.venv` active and the profile configured, run these from the project
directory:

```bash
dbt --version
dbt debug --project-dir . --profiles-dir ~/.dbt
dbt parse --project-dir . --profiles-dir ~/.dbt
```

`dbt debug` checks the local adapter connection and may create
`data/learning.duckdb`. `dbt parse` checks the project configuration.

## Formatting

The project uses SQLFluff for formatting and linting the SQL files.

Install the formatting/linting tools in the project venv:

```bash
source .venv/bin/activate
python -m pip install sqlfluff sqlfluff-templater-dbt
```

The project includes a root `.sqlfluff` file with the config.

Useful commands:

```bash
source .venv/bin/activate
sqlfluff lint models
sqlfluff fix models
```

`sqlfluff lint models` checks for issues, and `sqlfluff fix models` applies the
safe automatic fixes. The dbt parse/build commands are the main validation
for the project logic, while SQLFluff is mainly about style and consistency.
