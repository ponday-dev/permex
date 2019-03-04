# Permex

```markdown
**Caution** Permex is in development. It is proposal yet, so this repository will may be archived.
```

Permex is library that to controll permissions.

## Usage

At first, create a module and call `use Permex`.

```elixir
defmodule Permissions do
  use Permex
end
```

Next you use `permission` macro. First argument means the name of permission (You can name any one).

```elixir
defmodule Permissions do
  use Permex
  
  permission :create
  permission :read
  permission :update
  permission :delete
end
```

Before use `Permission` object, you need to call `require Permission` in module that you want to use this.

```elixir
defmodule SomeModule do
  require Permissions
end
```

Setup is completed! You can validate permissions by `Permissions.allow?`.

```elixir
permissions = [:read, :create]

Permissions.allow?(permissions, :read)
# => true
Permissions.allow?(permissions, :update)
# => false

# You can check multiple permissions.
Permissions.allow?(permissions, [:read, :create])
# => true
Permissions.allow?(permissions, [:read, :delete])
# => false
```

## Custom Resolver

In some cases, you may need more complex condition. In those cases, you can use custom resolver.

```elixir
defmodule MyResolver do
  @behaviour Permex.Resolver
  
  def perform(value), do: rem(value, 2) == 1
end
```

`permission` macro can receive custom resolver in second argument.

```elixir
defmodule Permissions do
  use Permex
  
  permissions :calc
  permissions :odd, MyResolver
end
```

Custom resolver is used as follows:

```elixir
require Permissions

permissions = [:calc, :odd]

Permissions.allow?(permissions, :odd, 1)
# => true
Permissions.allow?(permissions, :odd, 2)
# => false

Permissions.allow?(permissions, [:calc, [odd: 1]])
# => true
Permissions.allow?(permissions, [:calc, [odd: 2]])
# => false
```

