# Stage 4: Source Analysis
# Purpose: Find, read, and analyze sources identified in the research plan.
# Extract evidence for taxonomy claims and comparison dimensions.

## Inputs
- `research-plan.yaml` — prioritized source targets
- `survey-state.yaml` — gap context
- Target survey document — current content for context

## Task
For each source in the research plan:

1. **Find the source**: Locate the paper, system documentation, or artifact.

2. **Extract structured evidence**:
   - What isolation mechanism does it use?
   - Where does it sit in the taxonomy?
   - What are its distinguishing characteristics?
   - What are its limitations or scope?
   - What claims does it make about security, performance, or compatibility?

3. **Record evidence** in `evidence-ledger.yaml`:
   - Source ID with full citation
   - Evidence items with direct quotes or paraphrases
   - Confidence rating (direct quote vs. inference vs. secondary source)
   - How it maps to taxonomy dimensions
   - How it compares to already-surveyed systems

4. **Produce source notes** in `source-notes.md`:
   - Key findings per source
   - Surprising or counter-intuitive results
   - How each source changes or confirms the current taxonomy

## Output
- `evidence-ledger.yaml` — structured evidence entries
- `source-notes.md` — narrative source analysis
