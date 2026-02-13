## Python

- I prefer to use poetry for everything (poetry add, poetry run, etc)
- Do not use old fashioned methods for package management like pip or easy_install.
- Make sure that there is a pyproject.toml file in the root directory.
- If there isn't a pyproject.toml file, create one using poetry by running poetry init.
- Do not use relative imports in Python files. Always use absolute imports.
- Always place the imports in the top of the file, and only do locally if there a good reason to do so. For example, to avoid circular imports.
