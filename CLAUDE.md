# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# ohm-tags — JOSM validator plugin for OpenHistoricalMap

## Who I am

Jeff Meyer, OHM Advisor. I hold the OpenHistoricalMap® service mark and
am one of three advisors (with Minh Nguyễn and Richard Welty) setting
the project's technical direction. When I make a judgment call on OHM
tagging conventions or terminology, treat it as authoritative — don't
look for a wiki citation to second-guess me. The OHM wiki is a spec
but drifts; my word beats the wiki when they disagree.

## What this plugin does

JOSM validator plugin that checks OHM-style date tags and source/name
consistency. Two test classes:

- `DateTagTest` — validates `start_date`, `end_date`, and their `:edtf`
  and `:raw` siblings. Handles Julian conversion, EDTF normalization,
  the tagcleanupbot rollback pattern, ambiguity detection, year-boundary
  heuristics, and base-vs-`:edtf` reconciliation.
- `TagConsistencyTest` — validates names, source tags (including
  `source:url` consolidation and semicolon splitting), and attribute-
  source references to Wikidata/Wikipedia.

Currently ~50 distinct validator messages, all WARNING severity.
Package: `org.openstreetmap.josm.plugins.ohmtags`. Builds with Ant.

## Terminology rules (important)

**Don't use these terms** — they're not OHM vocabulary:
- "base tag" — say `*_date` or explicitly `start_date` / `end_date`
- "date triple" — say "the `*_date`, `*_date:edtf`, and `*_date:raw`
  tags" or similar

The targets are **OHM** (OpenHistoricalMap), not OSM proper. OHM uses
a data model derived from OSM but has its own tagging conventions,
especially around dates.

## Message title conventions

All titles are prefixed with `[ohm] ` so they're distinguishable from
core JOSM validator messages. The conventional patterns in use:

- `[ohm] Invalid date - <what>; fixable, please review suggested fix`
- `[ohm] Invalid date - <what>; unfixable, please review`
- `[ohm] Suspicious date - <what>; autofix by <action>`
- `[ohm] Suspicious date - <what>; unfixable, please review`
- `[ohm] Date mismatch: <what>; autofix as <action>` or `unfixable, ...`
- `[ohm] Missing <tag> tag; unfixable, please review [and add X]`
- `[ohm] Source optimization - <what>; autofix by <action>`
- `[ohm] Source mismatch - <what>; unfixable, please review`

When adding new messages, follow the pattern. Suffix should always
indicate fixability and what action, if any, the fix performs.

## Current state and open items (as of end of Apr 2026 session)

### Two titles that disagree with their code

- **"[ohm] Invalid date - invalid day in start_date or end_date;
  unfixable, please review"** — title says unfixable but the code
  offers a fix (trims to YYYY-MM). Either retitle to "fixable" or
  remove the fix.
- **"[ohm] Source mismatch - source contains url that does not match
  source:url; unfixable, please review"** — title says unfixable but
  the code still offers the consolidate fix. Same decision needed.

### Flagged for removal or review

- **"[ohm] Date/EDTF mismatch - *_date:edtf does not describe *_date
  tag; cannot be fixed, please review"** — flagged for possible
  removal in a prior round. Fires only as a companion to the
  "Invalid date - *_date:edtf; fixable" warning when base also exists.
  I concluded (and agreed with Claude) that it's redundant: after the
  user applies the fixable warning's autofix, the `:edtf` becomes valid
  and any remaining mismatch is caught by other messages. Should be
  deleted.
- **"[ohm] Date mismatch: across date tags"** — was renamed but
  flagged for another review. Current title is a bit vague; fires when
  `:raw` is present and disagrees with base/`:edtf` (non-bot editor).

### Cluster consolidation recommendations (pending decisions)

Claude proposed several cluster-level consolidations I haven't acted
on yet. Summarized:

1. **"Invalid date" family** — 5 titles, recommended keep separate but
   align wording. Already did partial alignment.
2. **"Invalid component" family** (3 titles: invalid day / invalid
   month / too many days) — inconsistent prefixes. Recommended: all
   get `[ohm] Invalid date - ` prefix. Not yet done.
3. **"Missing Wikipedia/Wikidata"** — 4 titles (2 triggers × 2 networks).
   Recommended: merge into one `[ohm] Missing wikidata tag` and one
   `[ohm] Missing wikipedia tag`, with description explaining trigger.
   Not yet done.
4. **"Source multiple values" family** — 4 titles, currently mostly
   aligned. One outlier: **"[ohm] Source tag contains multiple value
   types - text & URL"**. Recommended rename for consistency:
   `[ohm] Source optimization - source contains one URL and one text
   string; autofix by splitting into source and source:name`.
5. **"start_date=present" / "end_date=present" pair** — titles don't
   mention "present" at all; users can't tell what fired from title
   alone. Recommended: include `=present` in the titles.

Next session should work through these cluster decisions.

## JOSM scripting environment gotchas

When scripting against JOSM (via Jython console or plugin code):

- `ChangePropertyCommand([obj], key, value)` — two-arg form. The
  three-arg form `ChangePropertyCommand(ds, [obj], key, value)` does
  NOT exist in current JOSM API.
- For undo/redo, use:
  ```java
  import org.openstreetmap.josm.data.UndoRedoHandler;
  UndoRedoHandler.getInstance().add(command);
  ```
  Not `org.openstreetmap.josm.actions`, not `MainApplication.undoRedo`.
- In the Jython scripting console, `print()` output is unreliable.
  For diagnostics, use `JOptionPane.showMessageDialog(...)`.

## Build environment

- Java source: `src/org/openstreetmap/josm/plugins/ohmtags/`
- Ant build: `build.xml` → produces `dist/ohm-tags.jar`
- Compiled against: `../../josm/core/dist/josm-custom.jar` (path
  relative to plugin dir; adjust if your JOSM checkout is elsewhere)
- Install target: copies jar to JOSM's plugin directory
- Ant targets: `clean`, `compile`, `dist`, `install`

The plugin currently compiles clean on my machine. There is no
automated test suite — I've been testing manually in JOSM against
`test_objects.osm` (38k lines of OSM XML with edge cases I've been
collecting from real OHM data).

## Suggested high-leverage next steps

1. **Add a regression test harness.** Load `test_objects.osm`, run the
   validator programmatically, dump all errors to stdout. Lets any
   code change be regression-tested in 2 seconds instead of requiring
   a full JOSM rebuild+restart cycle. High ROI.
2. **Work through the cluster decisions** listed above. Probably 30
   minutes of focused pairing.
3. **Reconcile the two title/code mismatches** listed above.
4. **Create a `docs/MESSAGES.md`** that documents every message title,
   trigger, and fix — so the spec is auditable without reading Java
   source. Claude Code can generate this from the code using the
   Python extraction pattern we used.

## Pre-release checklist (for eventual publishing)

Before filing a JOSM registry ticket or publishing a GitHub release:

- [ ] Add LICENSE file (GPLv2 or GPLv3 — required per JOSM policy)
- [ ] Add license header comments to Java files
- [ ] Verify MANIFEST has: Plugin-Class, Plugin-Description,
      Plugin-Version, Plugin-Mainversion, Author, Plugin-Link
- [ ] Write README with install instructions, feature summary, and
      link to OHM wiki for context
- [ ] Check plugin name uniqueness against JOSM plugin registry
- [ ] Decide on versioning scheme (semver vs SVN-revision)
- [ ] Resolve the title/code mismatches so behavior matches docs
- [ ] Ship to a small group of OHM contributors for phase-1 feedback
- [ ] Then publish GitHub release + file JOSM Trac ticket requesting
      registry inclusion (or go through SVN repo path instead)

## Working with Claude Code

When picking up this work in a new Claude Code session:

- Start by reading this file, then run `ls src/org/openstreetmap/josm/
  plugins/ohmtags/validation/` to see the two test classes.
- The javadoc at the top of `DateTagTest.java` and
  `TagConsistencyTest.java` documents the rule design in detail.
- Error code constants have inline comments noting retired codes
  (e.g. `CODE_EDTF_INVALID_WITH_BASE` was retired when two messages
  merged). Don't reuse retired codes.
- When renaming messages in bulk, the pattern that worked well:
  walk a dict of `old_title: new_title` and do string replacement on
  both `.java` files. Titles split across concatenated string literals
  need separate regex-based handling (they exist; grep for them).
- When in doubt about OHM convention, ask me. Don't guess from OSM
  conventions — OSM and OHM diverge on dates particularly.
