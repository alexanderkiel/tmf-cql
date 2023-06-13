# TMF CQL Schulung

## Start

```sh
export PASSWORD=<password>
```

## Schädeldachfraktur

### CQl Library

```cql
library "schaedelfraktur"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
code "Schädeldachfraktur": 'S02.0' from icd10

context Patient

define InInitialPopulation:
  exists [Condition: "Schädeldachfraktur"]
```

### Ausführung

```sh
blazectl --server https://mii-agiop-polar.life.uni-leipzig.de/blaze --user polar --password "$PASSWORD" evaluate-measure schaedeldachfraktur.yml | jq -rf count.jq
```

### Ergebnis

```text
206
```

## Schädeldachfraktur mit zusätzlicher Stratifizierung nach Geburtsjahr

### CQl Library

```cql
library "schaedelfraktur-stratifier-birth-year"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
code "Schädeldachfraktur": 'S02.0' from icd10

context Patient

define InInitialPopulation:
  exists [Condition: "Schädeldachfraktur"]

define BirthYear:
  year from Patient.birthDate
```

### Ausführung

```sh
blazectl --server https://mii-agiop-polar.life.uni-leipzig.de/blaze --user polar --password "$PASSWORD" evaluate-measure schaedeldachfraktur-stratifier-birth-year.yml | jq -rf stratifier-birth-year.jq
```

### Ergebnis

```text
"year","count"
"1950",104
"1995",102
```

## Schädeldachfraktur/Schädelbasisfraktur

### CQl Library

```cql
library "schaedelfraktur"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem icd10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm'
code "Schädeldachfraktur": 'S02.0' from icd10
code "Schädelbasisfraktur": 'S02.1' from icd10

context Patient

define InInitialPopulation:
  exists [Condition: "Schädeldachfraktur"] or
  exists [Condition: "Schädelbasisfraktur"]
```

### Ausführung

```sh
blazectl --server https://mii-agiop-polar.life.uni-leipzig.de/blaze --user polar --password "$PASSWORD" evaluate-measure schaedelfraktur.yml | jq -rf count.jq
```

### Ergebnis

```text
411
```

## Medication Codes

```sh
blazectl --server https://mii-agiop-polar.life.uni-leipzig.de/blaze --user polar --password "$PASSWORD" evaluate-measure stratifier-medication-statement-medication-code.yml | jq .
```
