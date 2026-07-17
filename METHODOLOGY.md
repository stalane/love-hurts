# OSINT Collection & Verification Methodology

## Romance Scam Statistics Dataset

This document describes the complete methodology used to compile, verify, and
publish the dataset in `data/romance-scam-statistics.json`. It is designed to
be **reproducible** — someone following these steps should arrive at the same
dataset, or be able to identify exactly where their results differ and why.

---

## 1. Purpose & Scope

The dataset collects **verified, source-attributed statistics on romance
scams** for the period 2024–2026, compiled in June 2026 for the Baromètre des
arnaques sentimentales.

**In scope:**
- Official law-enforcement and regulator reports (FBI IC3, FTC, City of London
  Police, DGPN, Europol)
- Industry/civil-society reports with clearly attributed methodology (GASA,
  Chainalysis)
- Machine-readable structure with exact citations and source URLs

**Out of scope:**
- Estimates based on extrapolation or modeling
- Figures that cannot be traced to a published primary or secondary source
- Individual victim accounts (anecdotal evidence)
- Paid or behind-paywall data

**Geographic scope:** Primarily US, UK, France, and global aggregates (GASA).
EU-wide romance scam totals do not exist — Europol publishes only qualitative
analysis.

---

## 2. Source Discovery

### 2.1. Known Agency Reports (calendar-driven)

These agencies publish on predictable schedules. Checking dates are set in
advance:

| Agency | Report | Typical Release | URL pattern |
|--------|--------|-----------------|-------------|
| FBI IC3 | Internet Crime Report / IC3 Annual Report | March (prior year) | `ic3.gov/AnnualReport/Reports/<YEAR>_IC3Report.pdf` |
| FTC | Consumer Sentinel Network Data Book | February (prior year) | `ftc.gov/system/files/ftc_gov/pdf/csn-annual-data-book-<YEAR>.pdf` |
| FTC | Data Spotlight (romance-specific) | Irregular — last published Feb 2023 | `ftc.gov/news-events/data-visualizations/data-spotlight` |
| City of London Police | Romance Fraud press release | Periodic, ~May | `cityoflondon.police.uk/news` |
| Europol | IOCTA (Internet Organised Crime Threat Assessment) | October | `europol.europa.eu/publications-events/main-reports/iocta` |
| Cybermalveillance.gouv.fr | Annual activity report | ~March | `cybermalveillance.gouv.fr/tous-nos-contenus/actualites/rapport-activite` |
| GASA | Global State of Scams | ~October | `gasa.org/post/global-scams-on-the-rise` |
| Chainalysis | Crypto Crime Report | ~February | `chainalysis.com/blog/crypto-scams` |

### 2.2. Alert-based Discovery

- **Google Alerts:** Keywords: `"romance scam" statistics`, `"romance fraud"
  report`, `arnaque sentimentale chiffres`, `pig butchering losses`
- **RSS feeds** from agency press release pages
- **Twitter/X lists:** Accounts of fraud researchers, law enforcement
  communications, and relevant journalists
- **Preprints / academic trackers:** SSRN, arXiv for working papers on romance
  scam measurement

### 2.3. Secondary-source Trails

When a news article cites an official figure, the original report is always
hunted down. If the original cannot be located (e.g., behind a defunct URL,
paywalled, or referenced without a citation), the figure is excluded.

---

## 3. Triage & Inclusion Criteria

### 3.1. Inclusion

A figure is included when **all** of the following hold:

1. **Traceable to a published source** — a URL or known document identifier
   is available
2. **Source attribution is clear** — the report states who collected the data
   and by what method
3. **Time period is explicit** — the figure applies to a known year or range
4. **Romance scam definition is stated or deducible** — the report defines
   what it counts (e.g., FBI IC3's "Confidence Fraud / Romance" category)

### 3.2. Exclusion

A figure is excluded when any of the following apply:

- **No primary or clearly-attributed secondary source** — the figure is
  repeated across news outlets but traces back to an anonymous source or an
  unpublished study
- **Untraceable ratio** — e.g., "1 in 15–20 victims report to police" is
  widely quoted but no current primary study supports it
- **Overlapping/duplicate counts** — FTC and FBI figures cover different
  populations and are reported separately; they must not be summed
- **Paywalled or unpublished methodology** — if the source requires payment
  or does not describe its collection method

### 3.3. Worked Example: The "1 in 15–20" Ratio

During compilation, multiple sources were found citing a "1 in 15" or "1 in
20" under-reporting ratio for romance scams. Tracing backward:

- News articles attributed it to "FBI statistics" but the 2025 IC3 report does
  not contain this claim
- Some sources cited a 2017 academic paper that extrapolated from a small
  convenience sample
- No recent (2020–2026) primary study with a defensible methodology could be
  located

**Decision:** Excluded. The ratio's prevalence in news coverage does not
substitute for a verifiable primary source.

---

## 4. Verification Workflow

Each figure undergoes the following steps:

```
Source identified
       │
       ▼
Download original document
       │
       ▼
Verify document authenticity
  ├── Check SHA-256 hash against known-good (if previously downloaded)
  ├── Check publication date matches expected report period
  ├── Check publisher domain matches the agency
  └── Check for signs of tampering (altered PDF metadata, mismatched fonts,
      URLs in document that don't resolve)
       │
       ▼
Search document for relevant figure
  ├── Use document-internal search ("romance", "confidence", "fraud",
      "sentimental", "arnaque", etc.)
  └── If figure appears in a table, confirm row/column headers match the
      claimed category
       │
       ▼
Extract exact quote or table cell
  ├── Record the exact wording or values
  └── Capture surrounding context (year, category definition, footnotes)
       │
       ▼
Cross-reference with other sources
  ├── Does this contradict another primary source? If so, investigate the
      discrepancy (different population, different time period, different
      definition)
  └── Does a secondary source provide useful context? Record as a note.
       │
       ▼
Write to dataset with full citation
```

### 4.1. PDF Authenticity Verification

PDFs from official sources should be verified before use:

```bash
# Download and hash
curl -sLO "https://www.ic3.gov/AnnualReport/Reports/2025_IC3Report.pdf"
sha256sum 2025_IC3Report.pdf

# Compare against known hash (see scripts/source-hashes.sha256)
# If hash differs, investigate: new edition? updated errata? tampered copy?
```

Second- and third-order checks:
- PDF metadata: `pdfinfo` reports a Producer and CreationDate consistent with
  the agency's tools
- Cross-check with others who downloaded the same file (shared Slack/Twitter
  verification)
- If a URL returns a different file than expected, check the Internet Archive
  for the previous version

### 4.2. Handling Discrepancies

When two sources report different figures for the same metric:

| Situation | Action |
|-----------|--------|
| Different time periods | Report both, label explicitly |
| Different populations (US vs global, etc.) | Report both, label the population |
| Different definitions (e.g., "romance only" vs "romance + confidence") | Report the more specific, note the broader |
| Same source, different versions | Prefer latest; check for published errata |

**Example:** FTC reported $1.16B across 55,604 reports for 9 months of 2025
(Jan–Sep). The FBI IC3 reported $929M across 23,159 complaints for full-year
2025. These are from different agencies with different collection mechanisms —
both are valid and both are reported, with the respective time-frame and
population stated.

---

## 5. Source Reliability Taxonomy

| Tier | Label | Definition | Examples from dataset |
|------|-------|------------|----------------------|
| 1 | **Primary** | Official government or law-enforcement report, direct from publisher | FBI IC3 2025 Report, FTC CSN Data Book 2024 |
| 2 | **Secondary** | Report from regulated industry body or civil-society org that cites its methodology | GASA Global State of Scams 2025, Chainalysis Crypto Crime Report 2026 |
| 3 | **Tertiary** | News article or analysis that reports figures from a named primary or secondary source | Global Dating Insights (citing FTC), franceinfo (citing DGPN) |
| 4 | **Excluded** | No original source, anonymous claim, or untraceable origin | "1 in 15–20 victims report" |

Each entry in `data/romance-scam-statistics.json` includes a `fiabilite` field
indicating the tier.

---

## 6. Threat Model: Statistical Blind Spots

The dataset's gaps are not random — they are systematic and have
security-relevance implications.

### 6.1. France: Volume-Only Reporting

**Gap:** No official national financial total for romance scams exists. The
DGPN (Direction Générale de la Police Nationale) publishes only validated
complaint counts (~3,400 in 2024) and does not break down THESEE (the French
complaint database) by scam type.

**Implication for attackers:**
- Financial harm has **no official baseline** — attackers can operate without
  triggering threshold-based detection systems
- Prevention funding in France is justified by complaint volume only (which is
  low), creating a **visibility trap**: low reporting → low perceived harm →
  low funding → continued low reporting
- This opacity is operationally useful to scam networks — they can target
  French victims knowing the full scale of losses will not appear in public
  statistics

**Verification challenge:** French police reports use the THESEE system, but
category-level breakdowns are not published. Journalists request them via
access-to-information (CADA) channels — response times and completeness vary.

### 6.2. Missing EU Aggregate

**Gap:** Europol publishes only qualitative threat assessments. No EU-wide
romance scam total exists despite all member states collecting complaint data
nationally.

**Implication:** Cross-border scam operations cannot be measured at the
European level. Europol's IOCTA acknowledges the problem (LLM/GenAI
industrialising social engineering) but does not produce a financial figure.

### 6.3. Untraceable Under-Reporting Ratio

**Gap:** The commonly cited "1 in 15–20" reporting rate cannot be traced to a
current primary source.

**Implication for analysts:**
- Multipliers applied to raw complaint data are **not evidence-based**
- Any claim of "true losses" based on such a multiplier should be treated as
  speculation
- This uncertainty benefits attackers — estimates of the true scale of harm
  cannot be authoritatively produced, reducing pressure on platforms and
  regulators

### 6.4. Platform Blindness

**Gap:** The FTC reports that ~60% of romance scams start on social media, but
per-platform breakdowns are not published for most countries.

**Implication:** Attackers can shift between platforms faster than
platform-specific statistics appear, staying below detection thresholds on
any single platform.

### 6.5. AI Nexus Under-Counting

**Gap:** The FBI IC3 reports $19M in romance losses where AI was identified as
a factor. This is almost certainly a lower bound — it captures only cases where
the victim or investigator specifically identified AI involvement.

**Implication:** AI-augmented scams (deepfake profiles, voice cloning, LLM
personas) are growing faster than the reporting infrastructure can classify
them. Chainalysis found AI-enabled scams were 4.5× more profitable per
operation ($3.2M vs $719K).

---

## 7. Update Automation

### 7.1. Per-Agency Check Schedule

| Source | Cadence | Next expected | Trigger |
|--------|---------|---------------|---------|
| FBI IC3 Annual Report | Annual (March) | ~March 2027 | Calendar reminder + RSS |
| FTC CSN Data Book | Annual (February) | ~Feb 2027 | Calendar reminder |
| FTC Data Spotlight | Irregular | Unknown | Google Alert |
| City of London Police | ~Annual (May) | ~May 2027 | News monitoring |
| Europol IOCTA | Annual (October) | ~Oct 2026 | Calendar reminder |
| Cybermalveillance.gouv.fr | Annual (~March) | ~March 2027 | Calendar reminder |
| GASA Global State of Scams | Annual (~October) | ~Oct 2026 | Calendar reminder |
| Chainalysis Crypto Crime | Annual (~February) | ~Feb 2027 | Calendar reminder |
| SSMSI (France) | Irregular | Unknown | Google Alert, ONDRP reports |

### 7.2. Automated Source Integrity Check

The `scripts/verify-sources.sh` script performs the following on demand:

1. Parse `data/romance-scam-statistics.json` to extract all source URLs
2. Download each URL (if still reachable)
3. Compute SHA-256 hash of the downloaded file
4. Compare against known-good hashes in `scripts/source-hashes.sha256`
5. Report: OK (match), CHANGED (hash differs — manual review needed),
   GONE (404/connection error), NEW (no known hash — add it)

This script is intended as a **canary** — if a source URL changes, redirects,
or the document is replaced, an analyst investigates.

### 7.3. Update Workflow

When a new report is published:

1. Run `verify-sources.sh` to check existing source integrity
2. Download the new report, verify its authenticity
3. Extract relevant figures following the verification workflow (Section 4)
4. Add to `data/romance-scam-statistics.json` with `faibilite` rating and
   exact citation
5. Update `scripts/source-hashes.sha256` with the new report's hash
6. If the new report supersedes a previous figure, retain the historical value
   with a note (don't delete old data — enables trend analysis)

---

## 8. Reproduction Guide

To independently reproduce this dataset from scratch:

```bash
# Prerequisites
# - curl, sha256sum (Linux/macOS) or equivalent
# - A JSON processor (jq) for parsing the existing dataset
# - pdfinfo (poppler-utils) for PDF metadata checks

# Step 1: Clone the repository
git clone <repo-url>
cd romance-scam-statistics

# Step 2: Run source verification
# This downloads all referenced source documents and checks integrity
bash scripts/verify-sources.sh

# Step 3: Open each report identified as OK or CHANGED
# For each figure in the existing dataset:
#   - Locate the figure in the original document
#   - Confirm the value, context, and year match
#   - If a discrepancy is found, document it

# Step 4: Check for new reports since the dataset was last updated
# Consult the update calendar (Section 7.1) and search for new publications

# Step 5: If all figures verify, the dataset is confirmed current
# If new figures are found, update the dataset following Section 7.3
```

Expected time for full reproduction: **2–4 hours** for a single analyst
familiar with the domain. First-time verification (reading each report) takes
longer than subsequent checks.

---

## References

- FBI IC3 Internet Crime Reports: <https://www.ic3.gov/AnnualReport/>
- FTC Consumer Sentinel Network: <https://www.ftc.gov/policy/reports/policy-reports/data-visualizations>
- City of London Police: <https://www.cityoflondon.police.uk/news/>
- Europol IOCTA: <https://www.europol.europa.eu/publications-events/main-reports/iocta>
- CNAF (French national complaint data): <https://www.cnaf-risques.com>
- GASA Global State of Scams: <https://www.gasa.org/research>
- Chainalysis Crypto Crime Reports: <https://www.chainalysis.com/blog/crypto-crime/>
- SSMSI (French statistical service): <https://www.ssmsi.sécurité.interieur.gouv.fr>
- Internet Archive: <https://web.archive.org> — for checking changed or removed reports
