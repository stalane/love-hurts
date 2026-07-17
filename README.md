# Romance Scam Statistics

Verified, source-attributed statistics on romance scams ("arnaques sentimentales"), compiled and fact-checked in June 2026 for the **Baromètre des arnaques sentimentales**. Every figure was verified against the primary report before inclusion; figures that could not be traced to a primary or clearly-attributed secondary source were excluded. See [`METHODOLOGY.md`](METHODOLOGY.md) for the full OSINT collection and verification methodology.

📊 Human-readable versions:
- 🇫🇷 [Baromètre 2026 des arnaques sentimentales](https://www.arnaques-rencontres.fr/fr/articles/statistiques-arnaques-sentimentales-france)
- 🇬🇧 [Romance scam statistics 2025-2026](https://www.arnaques-rencontres.fr/en/articles/romance-scam-statistics)

## Methodology

### Inclusion criteria
A figure is included when all of the following hold: traceable to a published source, clear attribution and methodology, explicit time period, and a defined romance scam category.

### Exclusion criteria
Figures are excluded when no primary source exists, when an untraceable ratio is involved, when counts overlap with other entries, or when the source is paywalled or lacks published methodology.

### Source reliability
| Tier | Label | Examples |
|------|-------|----------|
| 1 | **Primary** — official law-enforcement/government report | FBI IC3, FTC CSN Data Book |
| 2 | **Secondary** — industry body with cited methodology | GASA, Chainalysis |
| 3 | **Tertiary** — news article citing a named source | Global Dating Insights, franceinfo |
| 4 | **Excluded** — untraceable origin | "1 in 15–20 victims report" |

Each dataset entry includes a `fiabilite` tier field. See [`METHODOLOGY.md`](METHODOLOGY.md) §3–5 for the complete verification workflow.

## Headline figures

| Metric | Value | Year | Source |
|---|---|---|---|
| US losses reported to FBI (confidence/romance) | $929,287,469 (+38% YoY) | 2025 | FBI IC3 2025 Internet Crime Report |
| US complaints (FBI IC3) | 23,159 (+29% YoY) | 2025 | FBI IC3 |
| US losses, victims aged 60+ | $584M — 63% of total (+50% YoY) | 2025 | FBI IC3 (Elder Fraud) |
| Romance losses with likely AI nexus | $19M (626 complaints) | 2025 | FBI IC3 (AI section) |
| Romance losses with crypto nexus | $394.8M — 42% of US total | 2025 | FBI IC3 |
| US losses reported to FTC (9 months) | $1.16B, 55,604 reports (+22%) | 2025 | FTC via Global Dating Insights |
| Romance scams starting on social media | ~60% of 2025 money-loss victims | 2025 | FTC press release, Apr 27, 2026 |
| UK losses (City of London Police) | £102M+, 10,784 reports (+29%) | 2025 | CoLP, May 5, 2026 |
| France: validated police reports | ≈3,400 | 2024 | DGPN via franceinfo |
| Average crypto-scam payment | $782 → $2,764 (+253%) | 2024→2025 | Chainalysis 2026 Crypto Crime Report |
| Adults worldwide who encountered a scam (12 mo) | 57% (23% lost money) | 2025 | GASA Global State of Scams 2025 |

Full machine-readable data with source URLs and exact citations: [`data/romance-scam-statistics.json`](data/romance-scam-statistics.json)

## Statistical blind spots

The dataset's gaps are systematic and have security-relevance implications.

### France: volume-only reporting
No official national financial total exists. The DGPN publishes complaint counts (~3,400 in 2024) but no THESEE breakdown by scam type. This creates a **visibility trap**: low reporting → low perceived harm → low funding → low reporting.

### No EU aggregate
Europol publishes only qualitative IOCTA threat assessments. Cross-border scam operations cannot be measured at the European level despite member states collecting data nationally.

### Untraceable under-reporting ratio
The commonly cited "1 in 15–20" ratio cannot be traced to a current primary source. Any claim of "true losses" using such a multiplier is speculation.

### Platform blindness
~60% of romance scams start on social media, but per-platform breakdowns are not published for most countries. Attackers shift between platforms faster than statistics can track.

### AI nexus under-counting
The FBI IC3's $19M for AI-identified romance losses is a lower bound — it captures only cases where AI involvement was explicitly identified. AI-enabled scams were 4.5× more profitable per operation (Chainalysis).

## Data maintenance

### Update schedule
| Source | Cadence | Next expected |
|--------|---------|---------------|
| FBI IC3 Annual Report | Annual (March) | ~March 2027 |
| FTC CSN Data Book | Annual (February) | ~Feb 2027 |
| City of London Police | ~Annual (May) | ~May 2027 |
| Europol IOCTA | Annual (October) | ~Oct 2026 |
| GASA Global State of Scams | Annual (~October) | ~Oct 2026 |
| Chainalysis Crypto Crime | Annual (~February) | ~Feb 2027 |

### Source integrity
`scripts/verify-sources.sh` downloads each referenced source URL, computes SHA-256 hashes, and compares against known-good hashes in `scripts/source-hashes.sha256`. A hash change flags the document as CHANGED for manual review.

### Reproduction
To independently verify this dataset (~2–4 hours): clone the repo, run `scripts/verify-sources.sh`, and cross-check each figure against the original reports. See [`METHODOLOGY.md`](METHODOLOGY.md) §8 for the full reproduction guide.

## License & citation

Data compiled from public official sources. Reuse freely with attribution:

> Baromètre des arnaques sentimentales, arnaques-rencontres.fr, June 2026.

Maintained by [Valentin Le Normand](https://www.valentin.love) — founder of an international matchmaking agency and editor of [arnaques-rencontres.fr](https://www.arnaques-rencontres.fr), a French romance-scam prevention site.
