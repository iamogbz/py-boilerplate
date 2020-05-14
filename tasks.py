import os

from invoke import exceptions, task


@task
def clean(ctx):
    """
    Remove build files e.g. package, distributable, compiled etc.
    """
    ctx.run("rm -rf *.egg-info dist build __pycache__ .pytest_cache artifacts/*")


@task
def lint(ctx, fix=False):
    """
    Check and fix syntax
    """
    lint_commands = {
        "isort": f"python -m isort {'' if fix else '--check-only --diff'} -y",
        "black": f"python -m black {'' if fix else '--check'} .",
        "flake8": "python -m flake8 src tests *.py",
        "mypy": "python -m mypy --strict src",
    }
    last_error = None
    for section, command in lint_commands.items():
        print(f"\033[1m[{section}]\033[0m")
        try:
            ctx.run(command, pty=True)
        except exceptions.Failure as ex:
            last_error = ex
        print()
    if last_error:
        raise last_error


@task(
    help={
        "coverage": "Build and report on test coverage",
        "dev": "Add development source files to environment",
        "test-pattern": "Pattern used to select test files to run",
        "verbose": "Verbose output e.g. non captured logs etc.",
    }
)
def test(ctx, coverage=False, dev=False, test_pattern=None, verbose=False):
    """
    Run entire test suite
    """
    env = {"PYTHONPATH": "./src"} if dev else {}
    flags = {"-s -vv": verbose, f"-k {test_pattern}": test_pattern}
    coverage_module = "coverage run -m " if coverage else ""
    test_flags = " ".join(flag for flag, enabled in flags.items() if enabled)
    ctx.run(f"python -m {coverage_module}pytest {test_flags} .", env=env, pty=True)
    if coverage:
        if not os.environ.get("CI"):
            ctx.run("coverage report", pty=True)


@task(pre=[clean])
def build(ctx):
    """
    Generate version from scm and build package distributable
    """
    # ctx.run("python setup.py sdist bdist_wheel")
