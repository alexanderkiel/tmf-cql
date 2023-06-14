["text", "system", "code", "count"],
(.group[0].stratifier[0].stratum[] | [.value.text, .value.coding[].system, .value.coding[].code, .population[0].count])
| @csv
