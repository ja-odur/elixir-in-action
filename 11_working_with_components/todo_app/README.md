# Todo

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `todo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:todo, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/todo>.

## Bugs

Starting observer - https://elixirforum.com/t/observer-in-iex-s-mix-error-undefinedfunctionerror-function-wx-object-start-3-is-undefined/58544/2

```
Mix.ensure_application!(:wx)
Mix.ensure_application!(:runtime_tools)
Mix.ensure_application!(:observer)
:observer.start()
```

