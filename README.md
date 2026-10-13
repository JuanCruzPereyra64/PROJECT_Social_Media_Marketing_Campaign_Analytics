# Social Media Marketing Campaign Analytics

> **Star finding:** campaigns spending under $1k concentrate just **3.9% of the budget**
> and generate **19.0% of total revenue**.
> Efficiency lives at low spend — scaling budget without changing campaign structure
> buys proportionally less return.

## Business Problem

How can a company improve the performance of its social media campaigns and use its
marketing budget more efficiently? This project answers it like a real marketing
analytics team would: audit → clean → measure → explore → answer → recommend.

## Dataset

- **Raw:** 6,200 records × 16 columns (`Code/db/`), intentionally messy: exact duplicates,
  14 platform label variants, missing values (~5%), impossible values, unreliable
  precomputed CTR/CPC columns.
- **Clean:** 6,000 rows, unique Campaign_IDs (`data/cleaned/social_media_campaigns_clean.csv`).
- **With KPIs:** clean + CTR, CPC, Conversion Rate, CPA, ROAS, ROI, spend bins
  (`data/cleaned/social_media_campaigns_with_kpis.csv`).
- Lineage rule: every stage is a new file — raw and intermediates are never overwritten.

## Methodology

1. **Data Quality Audit** — dimensions, types, nulls, duplicates, categorical cardinality,
   impossible values, metric consistency, outliers. No data modified.
2. **Data Cleaning** (Python/Pandas) — working copy only: 200 exact duplicates removed,
   Platform 14 → 6 labels, false CTR/CPC columns dropped, dates validated, NaNs kept
   (imputing money metrics would invent results), no outliers removed.
3. **Marketing KPIs** — rebuilt from definitions; ratios stored as decimals.
4. **EDA + 5 Business Questions** — platforms, content × platform, spend ranges,
   audience segments, reallocation scenario (observed vs modeled, explicitly labeled).
5. **SQL mirror** — SQLite staging + 11 queries reproducing the key cuts; both tools converge.
6. **Robustness** — star finding re-tested on 4,900 fully complete rows (holds: ROAS 19.44).

## Key Findings

| # | Finding |
|---|---------|
| 1 | Email is the most efficient platform (ROAS 4.17, ROI 3.17); YouTube trails (3.81) |
| 2 | Instagram runs 2x the campaigns but mid-table ROAS (3.94) — volume ≠ efficiency |
| 3 | Text is the best content (4.08); most-seen Video (395M impr.) returns 4.01 |
| 4 | Best combo: Email + Video (4.66). Worst: YouTube + Image (3.40) |
| 5 | Carousel converts best (10.51%) but monetizes average — converting ≠ earning |
| 6 | ROAS collapses 18.39 → 2.11 from the lowest to the highest spend range |
| 7 | Segments are flat (age 3.83–4.10, location 3.90–4.04, device 3.95–4.02): no reallocation by segment |
| 8 | Platforms are budget-balanced (revenue/spend share gaps ≤ 0.006) |
| 9 | Modeled scenario: moving 20% of top-range spend to low-spend efficiency → +28.8% revenue (scenario, not a promise) |

## Recommendations (WHAT → WHY)

- **Cap high-spend campaigns, pilot low-spend patterns** → ROAS 18.39 vs 2.11 observed.
- **Fund Email + Video and Facebook + Text first** → top observed combos (4.66, 4.64).
- **Fix YouTube + Image before scaling it** → lowest combo (3.40).
- **Keep segment budgets proportional** → noise-level gaps.
- **Report overall ratios, never simple averages** → mean ROAS 9.48 vs overall 3.98.

## Project Structure

```text
├── Code/
│   ├── Social Media Campaigns Analysis.ipynb   # full analysis (audit → Q&A → findings)
│   └── db/
│       └── social_media_campaigns_messy_Raw (1).xlsx   # RAW, untouched
├── data/cleaned/
│   ├── social_media_campaigns_clean.csv       # post-cleaning (6,000 × 14)
│   ├── social_media_campaigns_with_kpis.csv   # post-analysis (6,000 × 21)
│   └── social_media_campaigns.db              # SQLite staging (table: campaigns)
├── sql/
│   └── marketing_analysis.sql                 # 11 verification queries
├── report/
│   ├── executive_report.pdf                   # manager-level report (11 sections)
│   └── figures/                               # charts used in the report
└── README.md
```

## Reproduce

```bash
pip install pandas matplotlib reportlab
# 1. Run the notebook top to bottom (regenerates cleaned CSVs)
# 2. Load staging: sqlite3 data/cleaned/social_media_campaigns.db < load from CSV
# 3. Run queries: sqlite3 data/cleaned/social_media_campaigns.db < sql/marketing_analysis.sql
```

## Dashboard

Interactive Looker Studio dashboard (4 pages: Executive Overview, Platform Performance,
Content & Audience, Campaign Optimization) — link to be added here.

## Limitations

Synthetic/educational data: spend and results are nearly independent (correlations ~0),
so effect sizes describe this dataset, not market laws. Dates unreliable as ranges
(46% inverted). 271 rows with Clicks > Impressions kept and flagged. The +28.8% is a
modeled scenario under stated assumptions, not a guaranteed outcome.

## Tools

Python · Pandas · NumPy · Matplotlib · SQL (SQLite) · Looker Studio
