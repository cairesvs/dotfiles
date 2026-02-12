---
name: code-gaia-backend
description: Use when working on Code Gaia backend services - provides team conventions for DRF serializers, ViewSets, service layers, API URLs, environment variables, and import patterns
---

# Code Gaia Backend Conventions

## Overview

Team-agreed best practices for Code Gaia backend services. These complement Python/Django ecosystem standards (PEP-8, etc.) with project-specific conventions.

## When to Use

Use this skill when:
- Writing Django Rest Framework serializers or ViewSets
- Creating API endpoints
- Organizing business logic
- Setting up environment variables
- Writing tests for backend services

Use this for projects like atomic-engine-2, tenant-management, platform, etc.
You can check if this is a codegaia project by checking `git remote -v | grep "CodeGaia"`

## 1. Related Fields in Serializers

Split related fields into two: `object_id` and `object`.

- `object_id`: serialized to the database-level value (foreign key), used for both serialization and deserialization
- `object`: serialized to the complete object, read-only, used when sending data to frontend

```python
from rest_framework.serializers import ModelSerializer, UUIDField

class AuthorSerializer(ModelSerializer):
    class Meta:
        model = Author
        fields = ("id", "name")

class BookSerializer(ModelSerializer):
    author_id = UUIDField()
    author = AuthorSerializer(read_only=True)

    class Meta:
        model = Book
        fields = ("id", "title", "author_id", "author")
```

## 2. Docstrings for Tests

Add docstrings to tests describing expected behavior:

```python
def test_get_object_when_object_does_not_exist():
    """The response should be a 404 and the result set should be empty."""
    ...
```

Benefits:
- Provides quick context for complex business logic tests
- Test runner displays docstring next to failed tests

Docstrings should be one-line when possible, multi-line for complex tests.

## 3. Docstrings for ViewSets & Serializers

Add class-level docstrings to `ViewSet` and `Serializer` definitions. Add method-level docstrings to custom actions.

These docstrings appear automatically in Swagger documentation and help frontend-backend communication.

```python
class BookViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing books in the library catalog.

    Supports standard CRUD operations plus custom actions for checkout/return.
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer

    @action(detail=True, methods=["post"])
    def checkout(self, request, pk=None):
        """Mark a book as checked out by the requesting user."""
        ...
```

## 4. Hyphenate API URLs

Separate multiple words in API URLs with hyphens, not underscores.

```python
# ✅ Good
path("v1/supply-chain/supply-chain-assessments/", ...)

# ❌ Bad
path("v1/supply_chain/supply_chain_assessments/", ...)

# 😱 Worse (inconsistent)
path("v1/supply_chain/supply-chain-assessments/", ...)
```

## 5. Use select_related and prefetch_related

**select_related**: SQL joins for single-valued relationships (ForeignKey, OneToOne)
**prefetch_related**: Separate queries for multi-valued relationships (ManyToMany, reverse FK)

**Usage in ViewSets:**

```python
# Simple case: define on queryset
class ExampleViewSet(viewsets.ModelViewSet):
    queryset = Example.objects.select_related("another").order_by("created_at")

# Dynamic case: override get_queryset
class ExampleViewSet(viewsets.ModelViewSet):
    queryset = Example.objects.order_by("created_at")

    def get_queryset(self):
        queryset = super().get_queryset()
        return queryset.select_related("another")
```

**Custom manager for always-loaded relations** (use sparingly):

```python
class ExampleManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().select_related("another")

class Example(models.Model):
    objects = ExampleManager()
    # OR keep default separate:
    custom_objects = ExampleManager()
```

## 6. Service Layer for Business Logic

Keep models and views thin. Place substantial business logic in a `services/` module.

**Folder structure:**
```
models/
  - disclosure_draft_batch.py
views/
  - disclosure_draft_batch.py
services/
  - disclosure_draft_batch.py
serializers/
  - disclosure_draft_batch.py
```

**Dependency chain:** models → services → views/serializers (never reverse)

```python
# models/disclosure_draft_batch.py
class DisclosureDraftBatch(models.Model):
    id = models.UUIDField(...)
    status = models.CharField(...)

# services/disclosure_draft_batch.py
def mark_accepted(instance: DisclosureDraftBatch):
    """Mark batch as accepted, fetch LLM output, write disclosures."""
    ...

# views/disclosure_draft_batch.py
from services import disclosure_draft_batch as disclosure_draft_batch_service

class DisclosureDraftBatchViewSet(viewsets.GenericViewSet):
    queryset = DisclosureDraftBatch.objects.all()

    @action(detail=True, methods=["post"])
    def accept(self, request, pk):
        disclosure_draft_batch_service.mark_accepted(self.get_object())
        return Response(status=status.HTTP_204_NO_CONTENT)
```

## 7. Constants Import Rules

`constants.py` modules should only import:
- Other `constants` modules
- Third-party packages

Never import models, views, or other application code into constants.

```python
# ✅ Good: constants are standalone
# constants.py
class Type(models.TextChoices):
    GOOD = ("good", _("Good"))
    BAD = ("bad", _("Bad"))

ALL_TYPES = (Type.GOOD, Type.BAD)

# models.py
from constants import Type

class ExampleModel(models.Model):
    field = models.CharField(choices=Type)

# ❌ Bad: constants depend on models
# constants.py
from models import ExampleModel  # Creates circular dependency risk

ALL_TYPES = (ExampleModel.Type.GOOD, ExampleModel.Type.BAD)
```

## 8. Avoid Overwriting get_object

The default `get_object` uses `get_queryset`, preserving optimizations like `prefetch_related`.

```python
# ❌ Bad: bypasses queryset optimizations
class ExampleModelViewSet(ModelViewSet):
    queryset = ExampleModel.objects.prefetch_related("other_model")

    def get_object(self):
        return get_object_or_404(ExampleModel, pk=self.kwargs[self.lookup_field])

# ✅ Good: use default behavior or call super
class ExampleModelViewSet(ModelViewSet):
    queryset = ExampleModel.objects.prefetch_related("other_model")
    # No get_object override needed - parent already calls get_object_or_404

# ✅ Good: if override needed, use super or get_queryset
class ExampleModelViewSet(ModelViewSet):
    queryset = ExampleModel.objects.prefetch_related("other_model")

    def get_object(self):
        obj = super().get_object()
        # Additional logic here
        return obj
```

## 9. Standard Environment Variables

Use consistent naming across all services.

**Database:**
```bash
SQL_ENGINE=django.db.backends.postgresql
SQL_DATABASE=<database name>
SQL_USER=<database user name>
SQL_PASSWORD=<database user password>
SQL_HOST=<database host>
SQL_PORT=<database port>
```

**Internal API** (routed through API Gateway/NGINX):
```bash
API_URL=http://localhost:8081
API_USER_EMAIL=admin@example.com
API_USER_PASSWORD=admin
```

**Redis / Celery:**
```bash
REDIS_URL=http://localhost:6379
CELERY_BROKER_URL=<REDIS_URL>/<SERVICE_DB_NUMBER>
CELERY_RESULT_BACKEND=<REDIS_URL>/<SERVICE_DB_NUMBER>
CELERY_TASK_DEFAULT_QUEUE=<SERVICE_NAME>
```

**Redis DB number assignments:**
| Service                    | DB Number |
|----------------------------|-----------|
| Atomic Engine 2            | 0         |
| Inventory Service          | 1         |
| Invoice Processing Service | 2         |
| Import Service             | 3         |

## 10. Use Absolute Imports

PEP-8 recommends absolute imports for readability.

```python
# ✅ Good
from reporting.models import one

# ❌ Bad
from ...models import one
```

## Extras

- Always check if the Taskfile.yml exists, that means you should looking for helpful commands there
- Before commit always run task lint-ruff and task format-ruff, if present
- If the project is a Djang project, always run commands with `poetry run python manage.py`
- If the project has devbox.json + .envrc, that means the project uses devbox, which is the responsible to handle external dependencies like python version, etc.
- If it's a devbox project and direnv is enabled, you don't need to do anything, but if direnv is not enabled, you need to prepend the commands with `devbox shell`

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Single field for FK (just `author`) | Split into `author_id` + `author` |
| Tests without docstrings | Add one-line docstring describing expected behavior |
| Underscores in API URLs | Use hyphens: `/supply-chain/` not `/supply_chain/` |
| Business logic in models/views | Move to `services/` module |
| Constants importing models | Define constants standalone, import into models |
| Overriding `get_object` with direct query | Use `super().get_object()` or default behavior |
| Relative imports | Use absolute imports from package root |
| Non-standard env var names | Follow the standard naming conventions |
