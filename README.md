# roblox project template

this is the template that i use for roblox projects! sets up roact w/ hot reloading, rodux, some other things, as well as a 'system' loading thing we like to use on our projects

## style guide

We follow [Roblox's Lua style guide](https://roblox.github.io/lua-style-guide/), with the following exceptions and additions:

### naming

Use PascalCase for all filenames. This is so our file structure in-game matches Roblox's PascalCase naming convention.

When naming variables, use PascalCase for anything that comes from outside of the script. This allows us to differentiate at a glance what belongs to the module, and what comes from elsewhere:

```lua
-- good
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Messages = import "Utils/Messages"
local Foo = import "Shared/Foo"
local Baz = import("Shared/Bar", { "baz" })

-- bad
local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")

local messages = import "Utils/Messages"
local foo = import "Shared/Foo"
local baz = import("Shared/Bar", { "baz" })
```

**Where this convention is broken:**

* The `import` function. This breaks convention because it's essentially treated as a global like `print()` or `wait()`.
* The `t` library, just because as a single letter, it carries meaning. `T` is strange to read and use.

### imports

The `import` requirement should be at the top of the file, followed by services, module imports, etc.

```lua
-- good
local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local foo = import "Shared/Foo"

-- bad
local Players = game:GetService("Players")

local import = require(game.ReplicatedStorage.Shared.Import)
local foo = import "Shared/Foo"
```

The block of import statements should be ordered by:

1. Libraries, such as Roact and Rodux.
2. Absolute paths.
3. Relative paths.

In each category, organize imports based off alphabetical order, using the path.

```lua
-- good
local Roact = import "Roact"
local Foo = import "Shared/Foo"
local Bar = import "../Bar"

-- bad
local Bar = import "../Bar"
local Roact = import "Roact"
local Foo = import "Shared/Foo"
```

Use the export selection syntax when importing members of a module individually.

```lua
-- good
local Foo, Bar = import("Shared/Module", { "foo", "bar" })

-- bad
local Module = import "Shared/Module"
local Foo = module.foo
local Bar = module.bar
```

### conditionals

Break up complicated if statements into multiple values.

```lua
-- good
local isThingType = thing == Constants.ThingType
local isBigEnough = Baby.BabyProp > 91
local notHogShit = thing ~= hogShit
if isThingType and isBigEnough and notHogShit then

-- bad
if (thing == Constants.ThingType) and (Baby.BabyProp > 91) and not hogShit then
```
