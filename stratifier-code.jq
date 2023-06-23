["text", "system", "code", "version", "count"],
(.group[0].stratifier[0].stratum[] | [.value.text, .value.coding[].system, .value.coding[].code, .value.coding[].version, .population[0].count])
| @csv
