# ohm-dates — JOSM plugin

Validates and normalizes OpenHistoricalMap date tags to EDTF (ISO 8601-2).

## What it does

Adds a validator test that checks these tags on every primitive:

- `start_date`
- `end_date`
- `start_date:edtf`

For `start_date` / `end_date`: if the sibling `:edtf` tag is missing or doesn't
match the normalized form, raises a **warning** with an autofix that writes the
normalized EDTF to `<key>:edtf`.

For `start_date:edtf` itself: if the value isn't already normalized, raises a
warning with an autofix that overwrites it in place.

For unparseable date values: raises an **error** (no autofix available).

## Supported input formats

All formats from the iD/OHM editor's `utilEDTFFromOSMDateString`:

- `YYYY`, `YYYY-MM`, `YYYY-MM-DD`, optionally with ` BC` / ` BCE`
- `~YYYY` — circa
- `YYYY..ZZZZ` — range
- `YYYY0s` — decade (e.g. `1850s`)
- `CNN` — century (e.g. `C19`)
- `early|mid|late YYYY0s`
- `early|mid|late CNN`
- `before YYYY-MM-DD`, `after YYYY-MM-DD`

## Building

Assumes the JOSM source tree layout (plugin dir sits at `josm/plugins/ohm-dates/`
alongside a built `josm/core/dist/josm-custom.jar`). If your layout differs,
override the `josm` property:

```
ant -Djosm=/path/to/josm-custom.jar dist
```

Output: `dist/ohm-dates.jar`.

## Installing

```
ant install
```

This copies the jar into the JOSM plugins directory
(`~/.josm/plugins/` on Linux, `~/Library/JOSM/plugins/` on macOS,
`%APPDATA%/JOSM/plugins/` on Windows). Restart JOSM and enable the plugin in
Preferences → Plugins.

## Using

After install: Validation → Validate (shortcut **V**) runs all enabled tests.
Errors appear in the Validation Results panel. Select one or more and click
"Fix" (or use "Fix selected errors" for batch apply).

The test registers as "OHM date tags" in Preferences → Validator Tests and can
be disabled there.
