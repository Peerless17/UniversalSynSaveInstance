> [!IMPORTANT]
> Independent, unofficial project. Not affiliated with, endorsed by, or officially connected to Roblox Corporation. "Luau" is a trademark of Roblox Corporation.
<p align="center">
  <img height="300px" style="margin: 0; padding: 0" src=".moonwave/static/logo.png" />
</p>

# Loadstring

```lua
local Params = {
	RepoURL = "https://raw.githubusercontent.com/Peerless17/UniversalSynSaveInstance/master/",
	SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = {} -- See Documentation below
synsaveinstance(Options)
```

# Universal Syn Save Instance

Or shortly USSI, a project aimed at resurrecting saveinstance function from Synapse X.<br />
Reason: Many tools fail miserably at providing good user experience when it comes to tinkering with saving instances.

# Documentation

Detailed documentation is available at [Online Documentation] or in the reference table below.

### Basic Usage

UniversalSynSaveInstance accepts an options table, instance, or file path in any order:

```lua
-- Save place with custom options
synsaveinstance({
	mode = "optimized", -- "optimized", "full", "scripts"
	SafeMode = true,
	DecompileTimeout = 15,
})

-- Save specific model as .rbxm/.rbxmx
synsaveinstance(workspace.MyModel)

-- Save multiple instances as a model
synsaveinstance({ workspace.ModelA, workspace.ModelB })

-- Save with custom file name
synsaveinstance({ mode = "scripts" }, "MyScripts.rbxl")
```

### Options (`SaveInstanceOptions`)

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `mode` | `string` | `"optimized"` | What to save: `"optimized"` (key services like Workspace, Players, Lighting, ReplicatedStorage), `"full"` (entire game tree), or `"scripts"` (saves parts containing LuaSourceContainers). |
| `Binary` | `boolean` | `true` | Save binary format (`.rbxl`/`.rbxm`) for smaller file size and faster loading. Automatically falls back to XML if executor cannot write binary data. |
| `CompressionMode` | `string \| boolean` | `"zstd"` | Compression format for binary files: `"zstd"`, `"lz4"`, or `false` for uncompressed. |
| `CompressionLevel` | `number` | `9` | Zstandard compression level (-7 to 22). Higher values produce smaller files but take longer. |
| `FilePath` | `string \| false` | `false` | Custom output file name/path. Auto-appends file extension if omitted. |
| `SafeMode` | `boolean` | `false` | Disconnects LocalPlayer upon saving, enabling `KillAllScripts` and `BoostFPS`. Recommended. |
| `KillAllScripts` | `boolean` | `false` | Disables and stops running scripts prior to saving to prevent interference. |
| `BoostFPS` | `boolean` | `false` | Disables 3D rendering while saving to maximize performance and re-enables it upon completion. |
| `Object` | `Instance \| false` | `false` | Save a specific Instance instead of the entire game. Automatically sets `IsModel = true`. |
| `IsModel` | `boolean` | `false` | Save as a model (`.rbxm`/`.rbxmx`) instead of a place (`.rbxl`/`.rbxlx`). |
| `ShowStatus` | `boolean` | `true` | Displays progress, saving state, file size, and elapsed time on-screen. |
| `ReadMe` | `boolean` | `true` | Adds a `README` script inside the save with place ID, date, executor, and diagnostics. |
| `Decompile` | `boolean` | `true` | Decompiles LuaSourceContainers into source code. If disabled, scripts will have an empty/commented source. |
| `SaveBytecode` | `boolean` | `false` | Appends compiled bytecode as comments if supported by executor (`getscriptbytecode`). |
| `DecompileTimeout` | `number` | `10` | Timeout per script decompile in seconds (`-1` to disable timeout). |
| `BytecodeTimeout` | `number` | `3` | Timeout per bytecode extraction in seconds (`-1` to disable timeout). |
| `DecompileIgnore` | `table` | `{TextChatService}` | Instances or classes to skip during decompilation. |
| `SourceCache` | `table \| false` | `false` | Pre-defined source mapping for instances instead of decompiling. |
| `DecompileJobless` | `boolean` | `false` | Only uses scripts already cached in decompiler cache. |
| `scriptcache` | `boolean` | `true` | Caches decompiled script output to avoid redundant decompilations across runs. |
| `RecoverScriptsFromAssets` | `boolean` | `true` | Attempts to recover original script source from published assets. |
| `IsolatePlayers` | `boolean` | `false` | Groups all Player objects inside a `"Players"` folder instead of the Players service. |
| `IsolateStarterPlayer` | `boolean` | `false` | Isolates StarterPlayer scripts and characters. |
| `IsolateLocalPlayer` | `boolean` | `false` | Isolates LocalPlayer components and PlayerGui. |
| `NilInstances` | `boolean` | `false` | Saves instances parented to `nil` (using `getnilinstances` if supported). |
| `IgnoreNotArchivable` | `boolean` | `true` | Saves objects even if their `Archivable` property is `false`. |
| `SaveNotCreatable` | `boolean` | `false` | Converts non-creatable Roblox classes to creatable alternatives (e.g., Folder). |
| `IgnoreDefaultProperties` | `boolean` | `true` | Skips properties that equal class default values (XML format only). |
| `IgnoreDefaultPlayerScripts` | `boolean` | `false` | Skips Roblox built-in player scripts (PlayerModule, ChatScript, etc.). |
| `SharedBinaryStrings` | `boolean` | `false` | Deduplicates identical binary strings/buffers to save space. |
| `TreatUnionsAsParts` | `boolean` | `false` | Converts PartOperations (CSG) to standard Parts if executor fails to extract union data. |
| `ShutdownWhenDone` | `boolean` | `false` | Closes Roblox client once saving finishes. |
| `__DEBUG_MODE` | `boolean \| function` | `false` | Enables verbose debug warnings and logs. |

### Legacy Aliases & Shortcuts

UniversalSynSaveInstance supports familiar options from older saveinstance implementations (Synapse X, KRNL, Dex):
- `noscripts = true` &rarr; `Decompile = false`
- `XML = true` &rarr; `Binary = false`
- `DisableCompression = true` &rarr; `CompressionMode = false`
- `Overwrite = true` &rarr; `AvoidFileOverwrite = false`
- `RemovePlayerCharacters = true` &rarr; `SavePlayerCharacters = false`
- `Clipboard = true` &rarr; `CopyToClipboard = true`

# TO-DOs

- [x] Look into adding support for Binary Format Output (rbxl/rbxm)
- [ ] Add table.clone instead {} in some cases if possible
- [x] Support for Model files:
  - [x] rbxmx (xml)
  - [x] rbxm (binary)
- [x] Implement [Luau Syntax] (important for performance!):
  - [x] Compound Operators
  - [x] Avoid using `next`, `ipairs` & `pairs`
  - [x] ~~Interpolated strings instead of concat~~ Slower
  - [ ] Type-checking (😩🙀)
  - [ ] ~~`if-then-else` expressions~~ No reason to
  - [ ] Floor division

- [x] Speed things up as much as possible
  - Requires benchmarks
- [x] Support for as many [KRNL-like saveinstance Options] & [UNC]:
  - Change mode to invalid mode like "custom" if you only want to save ExtraInstances
  * [x] Decompile (! This takes priority over OPTIONS.noscripts if set !)
  * [x] DecompileIgnore
  * [x] DecompileTimeout (! This takes priority over OPTIONS.timeout if set !)
  * [x] ExtraInstances
  * [x] FilePath
  * [x] IgnoreDefaultProps
  * [x] IsolateStarterPlayer
  * [x] NilInstances
  * [x] Object (for .rbxmx files)
  * [x] RemovePlayerCharacters
  * [x] SavePlayers
  * [x] ShowStatus
    - [x] ~~Add Drawing Library support for ShowStatus~~ Can't reliably test if it's working on a tool
  * [x] IsolatePlayerGui (same as IsolateLocalPlayer)
  * [x] Callback
  * [x] CopyToClipboard/Clipboard
  * [x] Binary (rbxl/rbxm)
- [x] ~~Remove buffersize, savebuffer & so on for sake of performance by concatenating <Item> strings to total string then writing it to file (no extra steps like table.concat)~~ table.concat proved faster in the case of huge amount of concatenations
  - Test table.concat vs string ..= with a full buffer (this benchmark differs per usecase)
- [ ] Add Option to restart saveinstance from the point that it crashed on (perhaps by skipping)
- [ ] Maybe modes should do more than just determining the list of instances to save, like changing IgnoreDefaultProperties to false if mode is "full" for example
- [x] Add Lua & Luau versions instead of merged (WARNING: LUAU MIGHT BE MORE UPDATED THAN LUA VERSION, lua version exists just for the sake of old & bad tools, ask devs of your tools to support luau as its latest & greatest)
- [x] ~~Add Support for multiple Instances to be saved as a model~~ IsModel = true & ExtraInstances
- [x] ~~Force disable ParticleEmitters in case something like IgnorePropertiesOfNotScriptsOnScriptsMode is enabled (they stack in one place and create huge lag)~~ Not needed anymore it seems as empty FlipbookLayout breaks them which also results in no particles
- [ ] Be able to specify which special properties you want saved (to avoid saving all)

# Acknowledgments
> [!IMPORTANT]
> This document is based largely on the efforts of [@Anaminus] & [@Dekkonot], authors of the [Roblox Format Specifications]. Additional
resources include:
> 
> - [Syngp Synapse X Source code 2019][Synapse X Source 2019] for base saveinstance code (extended by [@mblouka] & [@Acrillis])
> - [Moon/LorekeeperZinnia][@LorekeeperZinnia] for being the original creator of saveinstance that was used in Synapse X, Elysian and many others. As well as being an inspiration for this project.
> - [Rojo Rbx Dom Xml] for being a fallback documentation in case something wasn't clear in the [Roblox Format Specifications]
> - [Roblox File Format] for a list of redirects of old/deprecated xml properties that still use the old tag values
> - [Roblox Client Tracker] for an extended & close to full JSON Api Dump (with hidden properties & default values)

\*\*\* View source code of this file for more credits

[Online Documentation]: https://peerless17.github.io/UniversalSynSaveInstance/api/UniversalSynSaveInstance
[Documentation]: https://peerless17.github.io/UniversalSynSaveInstance/api/UniversalSynSaveInstance
[@Acrillis]: https://github.com/Acrillis
[@Anaminus]: https://github.com/Anaminus
[@Dekkonot]: https://github.com/Dekkonot
[@mblouka]: https://github.com/mblouka
[@LorekeeperZinnia]: https://github.com/LorekeeperZinnia
[saveinstance Options]: https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D
[Rojo Rbx Dom Xml]: https://github.com/rojo-rbx/rbx-dom/blob/master/docs/xml.md
[Rojo Rbx Dom Binary]: https://github.com/rojo-rbx/rbx-dom/blob/master/docs/binary.md
[Luau Syntax]: https://luau-lang.org/syntax
[Rbx-Binary-Format]: https://github.com/Dekkonot/rbx-binary-format/blob/master/src/writer.lua
[Roblox Client Tracker]: https://github.com/MaximumADHD/Roblox-Client-Tracker
[Roblox File Format]: https://github.com/MaximumADHD/Roblox-File-Format
[Roblox Format Specifications]: https://github.com/RobloxAPI/spec/
[Roblox Format Specifications Binary]: https://github.com/RobloxAPI/spec/blob/master/formats/rbxl.md
[Synapse X Source 2019]: https://github.com/Acrillis/SynapseX
[UNC]: https://github.com/unified-naming-convention/NamingStandard/commit/613c1956b801ace54ba141dfc60842a16608b54f
