# Publication edits (source files preserved outside package)

- 01: Created database automatically when absent; removed syntax-error comma in `DimPatient`.
- 02: Retained original bulk-load order and local path; added portability notes.
- 03: Removed repeated row-count block and repeated standalone missing-key tests; core validation queries retained.
- 04: Removed duplicated department performance query; added `ProviderID` to provider grouping to avoid merging providers with identical names.
- Docs: Marked reconstructed DAX as not fully extracted from PBIX and distinguished appointment-based financial attribution from payment-date reporting.

Not executed against SQL Server in this environment. Review and test before sharing a claim of end-to-end reproducibility.
