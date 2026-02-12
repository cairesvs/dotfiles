---
name: python-best-practices
description: Use when reading or writing Python files - provides type-first development patterns with dataclasses, discriminated unions, NewType, Protocol, and Django/DRF-specific patterns for models, serializers, querysets, and avoiding N+1 queries
---

# Python Best Practices

## Overview

Types define the contract before implementation. This skill covers type-first development, functional patterns, Django ORM optimization, and Django Rest Framework best practices.

## When to Use

Use this skill when:
- Writing or reviewing Python code
- Working with Django models and querysets
- Implementing Django Rest Framework APIs
- Designing data structures and APIs
- Setting up type checking

## Type-First Development

Types define the contract before implementation. Follow this workflow:

1. **Define data models** - dataclasses, Pydantic models, or TypedDict first
2. **Define function signatures** - parameter and return type hints
3. **Implement to satisfy types** - let the type checker guide completeness
4. **Validate at boundaries** - runtime checks where data enters the system

### Make Illegal States Unrepresentable

Use Python's type system to prevent invalid states at type-check time.

**Dataclasses for structured data:**
```python
from dataclasses import dataclass
from datetime import datetime

@dataclass(frozen=True)
class User:
    id: str
    email: str
    name: str
    created_at: datetime

@dataclass(frozen=True)
class CreateUser:
    email: str
    name: str

# Frozen dataclasses are immutable - no accidental mutation
```

**Discriminated unions with Literal:**
```python
from dataclasses import dataclass
from typing import Literal

@dataclass
class Idle:
    status: Literal["idle"] = "idle"

@dataclass
class Loading:
    status: Literal["loading"] = "loading"

@dataclass
class Success:
    status: Literal["success"] = "success"
    data: str

@dataclass
class Failure:
    status: Literal["error"] = "error"
    error: Exception

RequestState = Idle | Loading | Success | Failure

def handle_state(state: RequestState) -> None:
    match state:
        case Idle():
            pass
        case Loading():
            show_spinner()
        case Success(data=data):
            render(data)
        case Failure(error=err):
            show_error(err)
```

**NewType for domain primitives:**
```python
from typing import NewType

UserId = NewType("UserId", str)
OrderId = NewType("OrderId", str)

def get_user(user_id: UserId) -> User:
    # Type checker prevents passing OrderId here
    ...

def create_user_id(raw: str) -> UserId:
    return UserId(raw)
```

**Enums for constrained values:**
```python
from enum import Enum, auto

class Role(Enum):
    ADMIN = auto()
    USER = auto()
    GUEST = auto()

def check_permission(role: Role) -> bool:
    match role:
        case Role.ADMIN:
            return True
        case Role.USER:
            return limited_check()
        case Role.GUEST:
            return False
    # Type checker warns if case is missing
```

**Protocol for structural typing:**
```python
from typing import Protocol

class Readable(Protocol):
    def read(self, n: int = -1) -> bytes: ...

def process_input(source: Readable) -> bytes:
    # Accepts any object with a read() method
    return source.read()
```

**TypedDict for external data shapes:**
```python
from typing import TypedDict, Required, NotRequired

class UserResponse(TypedDict):
    id: Required[str]
    email: Required[str]
    name: Required[str]
    avatar_url: NotRequired[str]

def parse_user(data: dict) -> UserResponse:
    # Runtime validation needed - TypedDict is structural
    return UserResponse(
        id=data["id"],
        email=data["email"],
        name=data["name"],
    )
```

## Module Structure

Prefer smaller, focused files: one class or closely related set of functions per module. Split when a file handles multiple concerns or exceeds ~300 lines. Use `__init__.py` to expose public API; keep implementation details in private modules (`_internal.py`). Colocate tests in `tests/` mirroring the source structure.

## Functional Patterns

- Use list/dict/set comprehensions and generator expressions over explicit loops.
- Prefer `@dataclass(frozen=True)` for immutable data; avoid mutable default arguments.
- Use `functools.partial` for partial application; compose small functions over large classes.
- Avoid class-level mutable state; prefer pure functions that take inputs and return outputs.

## Instructions

- Raise descriptive exceptions for unsupported cases; every code path returns a value or raises. This makes failures debuggable and prevents silent corruption.
- Propagate exceptions with context using `from err`; catching requires re-raising or returning a meaningful result. Swallowed exceptions hide root causes.
- Handle edge cases explicitly: empty inputs, `None`, boundary values. Include `else` clauses in conditionals where appropriate.
- Use context managers for I/O; prefer `pathlib` and explicit encodings. Resource leaks cause production issues.
- Add or adjust unit tests when touching logic; prefer minimal repros that isolate the failure.

## Examples

Explicit failure for unimplemented logic:
```python
def build_widget(widget_type: str) -> Widget:
    raise NotImplementedError(f"build_widget not implemented for type: {widget_type}")
```

Propagate with context to preserve the original traceback:
```python
try:
    data = json.loads(raw)
except json.JSONDecodeError as err:
    raise ValueError(f"invalid JSON payload: {err}") from err
```

Exhaustive match with explicit default:
```python
def process_status(status: str) -> str:
    match status:
        case "active":
            return "processing"
        case "inactive":
            return "skipped"
        case _:
            raise ValueError(f"unhandled status: {status}")
```

Debug-level tracing with namespaced logger:
```python
import logging

logger = logging.getLogger("myapp.widgets")

def create_widget(name: str) -> Widget:
    logger.debug("creating widget: %s", name)
    widget = Widget(name=name)
    logger.debug("created widget id=%s", widget.id)
    return widget
```

## Configuration

- Load config from environment variables at startup; validate required values before use. Missing config should fail immediately.
- Define a config dataclass or Pydantic model as single source of truth; avoid `os.getenv` scattered throughout code.
- Use sensible defaults for development; require explicit values for production secrets.

### Examples

Typed config with dataclass:
```python
import os
from dataclasses import dataclass

@dataclass(frozen=True)
class Config:
    port: int = 3000
    database_url: str = ""
    api_key: str = ""
    env: str = "development"

    @classmethod
    def from_env(cls) -> "Config":
        database_url = os.environ.get("DATABASE_URL", "")
        if not database_url:
            raise ValueError("DATABASE_URL is required")
        return cls(
            port=int(os.environ.get("PORT", "3000")),
            database_url=database_url,
            api_key=os.environ["API_KEY"],  # required, will raise if missing
            env=os.environ.get("ENV", "development"),
        )

config = Config.from_env()
```

## Django Patterns

### Models and QuerySets

**Type hints for Django models:**
```python
from django.db import models
from django.db.models import QuerySet
from typing import Self

class ActivityDataQuerySet(models.QuerySet["ActivityData"]):
    def with_emissions(self) -> Self:
        """Annotate with computed CO2e emissions."""
        return self.select_related("system", "activity_type")

    def for_hierarchy(self, hierarchy_id: str) -> Self:
        """Filter by hierarchy ID."""
        return self.filter(hierarchy_id=hierarchy_id)

class ActivityData(models.Model):
    hierarchy_id = models.CharField(max_length=255)
    activity_type = models.ForeignKey("ActivityType", on_delete=models.CASCADE)

    objects: models.Manager["ActivityData"] = models.Manager.from_queryset(ActivityDataQuerySet)()

    class Meta:
        abstract = True
```

**Prevent N+1 queries with select_related and prefetch_related:**
```python
from django.db.models import Prefetch

# ❌ BAD: N+1 query - hits DB for each activity's system
activities = ActivityData.objects.all()
for activity in activities:
    print(activity.system.name)  # DB hit per iteration

# ✅ GOOD: select_related for ForeignKey/OneToOne
activities = ActivityData.objects.select_related("system", "activity_type")

# ✅ GOOD: prefetch_related for ManyToMany/Reverse ForeignKey
activities = ActivityData.objects.prefetch_related(
    Prefetch(
        "contributions",
        queryset=Contribution.objects.select_related("contributor")
    )
)
```

**Custom managers for reusable queries:**
```python
class ActivityDataManager(models.Manager):
    def with_full_relations(self) -> QuerySet["ActivityData"]:
        """Load all commonly-accessed relations."""
        return self.get_queryset().select_related(
            "system",
            "activity_type",
            "location"
        ).prefetch_related("contributions")

class ActivityData(models.Model):
    objects = ActivityDataManager.from_queryset(ActivityDataQuerySet)()
```

**Avoid business logic in models:**
```python
# ❌ BAD: Complex calculation in model
class RefrigerantFlow(ActivityData):
    @property
    def co2e_emissions(self):
        # 50 lines of calculation logic
        ...

# ✅ GOOD: Move to service layer
class RefrigerantFlow(ActivityData):
    pass

# ledger/services/emissions.py
class EmissionsCalculator:
    def calculate_co2e(self, activity: RefrigerantFlow) -> Decimal:
        # Testable, reusable calculation logic
        ...
```

### Migrations

**Always name migrations descriptively:**
```bash
# ❌ BAD
poetry run python manage.py makemigrations

# ✅ GOOD
poetry run python manage.py makemigrations ledger --name add_contribution_type_field
poetry run python manage.py makemigrations gri --name migrate_computed_fields_to_contributions
```

**Data migrations with type hints:**
```python
from django.db import migrations
from django.apps.registry import Apps
from django.db.backends.base.schema import BaseDatabaseSchemaEditor

def migrate_contributions(apps: Apps, schema_editor: BaseDatabaseSchemaEditor) -> None:
    """Migrate computed fields to contributions system."""
    ActivityData = apps.get_model("ledger", "ActivityData")
    Contribution = apps.get_model("ledger", "Contribution")

    for activity in ActivityData.objects.all():
        Contribution.objects.create(
            activity=activity,
            contributor_type="emissions",
            value=activity.old_computed_field
        )

def reverse_migration(apps: Apps, schema_editor: BaseDatabaseSchemaEditor) -> None:
    """Reverse the migration."""
    Contribution = apps.get_model("ledger", "Contribution")
    Contribution.objects.filter(contributor_type="emissions").delete()

class Migration(migrations.Migration):
    dependencies = [
        ("ledger", "0140_previous_migration"),
    ]

    operations = [
        migrations.RunPython(migrate_contributions, reverse_migration),
    ]
```

### Testing with FactoryBoy

**Type-safe factories:**
```python
from factory import SubFactory, Trait, LazyAttribute
from factory.django import DjangoModelFactory
from typing import Any
from ledger.models import RefrigerantFlow, System, ActivityType

class SystemFactory(DjangoModelFactory):
    class Meta:
        model = System

    name = "GHGP 2015"
    version = "2015"

class ActivityTypeFactory(DjangoModelFactory):
    class Meta:
        model = ActivityType

    name = "Refrigerant"
    code = "REF"

class RefrigerantFlowFactory(DjangoModelFactory):
    class Meta:
        model = RefrigerantFlow

    hierarchy_id = "test-hierarchy"
    system = SubFactory(SystemFactory)
    activity_type = SubFactory(ActivityTypeFactory)
    quantity = 100

    class Params:
        # Traits for common test scenarios
        high_gwp = Trait(
            refrigerant_type="HFC-134a",
            quantity=1000
        )

        low_gwp = Trait(
            refrigerant_type="R-600a",
            quantity=100
        )

# Usage in tests
def test_high_gwp_refrigerant():
    activity = RefrigerantFlowFactory(high_gwp=True)
    assert activity.computed_co2e_emissions > 1000
```

**Centralize test data creation:**
```python
# ❌ BAD: Scattered test data creation
class TestEmissions:
    def test_case_1(self):
        system = System.objects.create(name="GHGP", version="2015")
        activity = RefrigerantFlow.objects.create(system=system, ...)

    def test_case_2(self):
        system = System.objects.create(name="GHGP", version="2015")  # Duplicate
        activity = RefrigerantFlow.objects.create(system=system, ...)

# ✅ GOOD: Reusable factories with traits
class TestEmissions:
    def test_case_1(self):
        activity = RefrigerantFlowFactory(high_gwp=True)

    def test_case_2(self):
        activity = RefrigerantFlowFactory(low_gwp=True)
```

### QuerySet Optimization

**Use pagination for large datasets:**
```python
from django.core.paginator import Paginator

# ❌ BAD: Load all activities into memory
activities = ActivityData.objects.all()
for activity in activities:
    process(activity)

# ✅ GOOD: Paginate for large datasets
paginator = Paginator(ActivityData.objects.all(), 1000)
for page_num in paginator.page_range:
    page = paginator.page(page_num)
    for activity in page.object_list:
        process(activity)
```

**Bulk operations for performance:**
```python
# ❌ BAD: Individual saves in loop
for activity in activities:
    activity.computed_field = calculate(activity)
    activity.save()  # N queries

# ✅ GOOD: Bulk update
activities_to_update = []
for activity in activities:
    activity.computed_field = calculate(activity)
    activities_to_update.append(activity)

ActivityData.objects.bulk_update(
    activities_to_update,
    fields=["computed_field"],
    batch_size=1000
)
```

## Django Rest Framework Patterns

### Serializers

**Type hints for serializers:**
```python
from rest_framework import serializers
from typing import Any, Dict
from ledger.models import ActivityData

class ActivityDataSerializer(serializers.ModelSerializer[ActivityData]):
    class Meta:
        model = ActivityData
        fields = ["id", "hierarchy_id", "activity_type", "quantity"]

    def validate_quantity(self, value: Any) -> float:
        """Validate quantity is positive."""
        if value <= 0:
            raise serializers.ValidationError("Quantity must be positive")
        return float(value)

    def create(self, validated_data: Dict[str, Any]) -> ActivityData:
        """Create activity with validated data."""
        return ActivityData.objects.create(**validated_data)
```

**Avoid business logic in serializers:**
```python
# ❌ BAD: Business logic in serializer
class ActivityDataSerializer(serializers.ModelSerializer):
    def create(self, validated_data):
        activity = super().create(validated_data)
        # 50 lines of emissions calculation
        activity.co2e_emissions = complex_calculation(activity)
        activity.save()
        return activity

# ✅ GOOD: Move to service layer
class ActivityDataSerializer(serializers.ModelSerializer):
    def create(self, validated_data):
        activity = super().create(validated_data)
        # Delegate to service
        EmissionsService().calculate_and_save(activity)
        return activity
```

**Nested serializers with select_related:**
```python
class SystemSerializer(serializers.ModelSerializer):
    class Meta:
        model = System
        fields = ["id", "name", "version"]

class ActivityDataSerializer(serializers.ModelSerializer):
    system = SystemSerializer(read_only=True)

    class Meta:
        model = ActivityData
        fields = ["id", "hierarchy_id", "system"]

    @classmethod
    def get_optimized_queryset(cls) -> models.QuerySet:
        """Queryset with relations loaded."""
        return ActivityData.objects.select_related("system")

# In viewset
class ActivityDataViewSet(viewsets.ModelViewSet):
    serializer_class = ActivityDataSerializer

    def get_queryset(self):
        return ActivityDataSerializer.get_optimized_queryset()
```

### ViewSets

**Type-safe viewsets:**
```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.request import Request
from rest_framework.response import Response
from typing import Any

class ActivityDataViewSet(viewsets.ModelViewSet[ActivityData]):
    queryset = ActivityData.objects.all()
    serializer_class = ActivityDataSerializer

    def get_queryset(self) -> models.QuerySet[ActivityData]:
        """Filter by hierarchy_id from JWT."""
        hierarchy_id = self.request.user.hierarchy_id
        return super().get_queryset().filter(hierarchy_id=hierarchy_id)

    @action(detail=True, methods=["post"])
    def recalculate(self, request: Request, pk: str | None = None) -> Response:
        """Recalculate emissions for activity."""
        activity = self.get_object()
        EmissionsService().calculate_and_save(activity)
        serializer = self.get_serializer(activity)
        return Response(serializer.data)
```

**Avoid N+1 in list endpoints:**
```python
class ActivityDataViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        queryset = super().get_queryset()

        # Optimize based on action
        if self.action == "list":
            # List view needs related data
            queryset = queryset.select_related(
                "system", "activity_type"
            ).prefetch_related("contributions")
        elif self.action == "retrieve":
            # Detail view needs more relations
            queryset = queryset.select_related(
                "system", "activity_type", "location"
            ).prefetch_related(
                "contributions__contributor"
            )

        return queryset
```

### Testing DRF Views

**Type-safe API tests:**
```python
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from typing import Any, Dict

class ActivityDataAPITests(APITestCase):
    def setUp(self) -> None:
        self.client = APIClient()
        self.activity = RefrigerantFlowFactory()

    def test_create_activity(self) -> None:
        """Test creating activity via API."""
        data: Dict[str, Any] = {
            "hierarchy_id": "test",
            "quantity": 100,
            "activity_type": self.activity_type.id
        }

        response = self.client.post("/v1/activities/", data)

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["quantity"], 100)

    def test_list_activities_no_n_plus_one(self) -> None:
        """Ensure list endpoint doesn't have N+1 queries."""
        RefrigerantFlowFactory.create_batch(10)

        with self.assertNumQueries(3):  # 1 for activities, 1 for systems, 1 for types
            response = self.client.get("/v1/activities/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 10)
```

## Type Checking

**Use django-stubs for type checking:**
```toml
# pyproject.toml
[tool.poetry.dependencies]
django-stubs = "^5.0.0"
djangorestframework-stubs = "^3.15.0"

[tool.mypy]
plugins = ["mypy_django_plugin.main", "mypy_drf_plugin.main"]

[tool.django-stubs]
django_settings_module = "atomic_engine_2.settings"
```

**Common type issues and fixes:**
```python
from django.db.models import QuerySet
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from ledger.models import ActivityData

# ❌ BAD: Circular import
from ledger.models import ActivityData

def process_activities(activities: QuerySet[ActivityData]) -> None:
    ...

# ✅ GOOD: Use TYPE_CHECKING guard
def process_activities(activities: "QuerySet[ActivityData]") -> None:
    ...
```

## Optional: ty

For fast type checking, consider [ty](https://docs.astral.sh/ty/) from Astral (creators of ruff and uv). Written in Rust, it's significantly faster than mypy or pyright.

**Installation and usage:**
```bash
# Add as dev dependency
poetry add --group dev ty

# Run type checking
poetry run ty check

# Check specific files
poetry run ty check src/main.py
```

**Key features:**
- Automatic virtual environment detection (via `VIRTUAL_ENV` or `.venv`)
- Project discovery from `pyproject.toml`
- Fast incremental checking
- Compatible with standard Python type hints

**Configuration in `pyproject.toml`:**
```toml
[tool.ty]
python-version = "3.12"
```

**When to use ty vs alternatives:**
- `ty` - fastest, good for CI and large codebases (early stage, rapidly evolving)
- `pyright` - most complete type inference, VS Code integration
- `mypy` - mature, extensive plugin ecosystem

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| No type hints on functions | Add parameter and return types |
| N+1 queries in Django | Use select_related/prefetch_related |
| Business logic in models/serializers | Move to service layer |
| Mutable default arguments | Use `None` and initialize in function |
| Swallowing exceptions | Re-raise with context using `from err` |
| Unnamed migrations | Always use `--name` flag |
| Individual saves in loops | Use bulk_create/bulk_update |
| Missing FactoryBoy traits | Centralize common test scenarios |
