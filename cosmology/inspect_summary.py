import json
with open("cosmology/mcmc_production_summary.json", "r") as f:
    summ = json.load(f)
print("Keys in summary:", list(summ.keys()))
for k, v in summ.items():
    if isinstance(v, dict) and 'H0' in v:
        print(f"\n--- {k} ---")
        for p, val in v.items():
            print(f"  {p:<16}: {val}")
    elif isinstance(v, (int, float, str, list)):
        print(f"{k}: {v}")
