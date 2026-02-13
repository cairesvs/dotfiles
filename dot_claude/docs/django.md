## Django

- If the project it's using Django, make sure to remember about N+1 queries, and be aware of prefetch and select related feature.
- When running migrations please always give a meaningful name to the migration.
- Avoid add business logic directly in the Model, and if you are using Django Rest Framework, in the Serializer.
- If available, try to use FactoryBoy instead of creating the database entries manually.
- Always think hard about creating test data in one place. If possible use FactoryBoy Traits.
- Always think hard about using QuerySet Paginator, question if the data is big, and use Paginator, and bulk-updates when developing
