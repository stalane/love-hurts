# Source Update Calendar

Expected publication windows for each agency report referenced in the
dataset. Used to schedule re-checking the dataset when new data becomes
available.

| Month | Agency | Report | Typical window |
|-------|--------|--------|----------------|
| **February** | FTC | CSN Data Book (prior year) | Early–mid Feb |
| **February** | Chainalysis | Crypto Crime Report (prior year) | Mid–late Feb |
| **March** | FBI IC3 | Internet Crime Report (prior year) | Mid March |
| **March** | Cybermalveillance.gouv.fr | Annual activity report (prior year) | Early March |
| **May** | City of London Police | Romance fraud press release | Early May |
| **October** | Europol | IOCTA (current year) | Mid October |
| **October** | GASA | Global State of Scams (current year) | Late October |
| **Irregular** | FTC | Data Spotlight (romance-specific) | Last published Feb 2023 |
| **Irregular** | SSMSI / ONDRP | France victimisation surveys | No fixed schedule |

## Automation triggers

The following cron-friendly check can be added to a monitoring system:

```bash
# Check if a IC3 report for a new year exists (run from repo root)
year=$(date +%Y)
next_year=$((year + 1))
curl -sI "https://www.ic3.gov/AnnualReport/Reports/${next_year}_IC3Report.pdf" \
  | grep -q "200 OK" && echo "NEW IC3 REPORT AVAILABLE: ${next_year}"
```

Similar checks can be constructed for other predictable-URL sources.
