# Guachiman

Guachiman is an application to authenticate your Elixir/Phoenix application with AUTH0 and Guardian.

## Configuration

The following parameters could be provided through configuration:
	
### General configuration

- **scopes**: a list of the valid scopes that could be part of the token:
```
  scopes: ["create_user", "delete_user", "openid", "profile", "email"]
```

- **resource**: a MFA `{mod, function, args}` that `guachiman` (through Guardian) will use to retrieve the resourc given a `subject_id` (`sub` claim).
```
  resource: {ExBitcloudApi.GuardianResource, :get, []}
```

    
## Installation

...not yet

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `guachiman` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:guachiman, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/guachiman](https://hexdocs.pm/guachiman).
