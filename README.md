# TMF CQL Schulung

## Start

### Öffentlicher Server

```sh
export BASE="https://mii-agiop-polar.life.uni-leipzig.de/blaze"
export PASSWORD=<password>
```

### Lokaler Server

```sh
docker compose up -d
export BASE="http://localhost:8080/fhir"
blazectl --server "$BASE" upload data
```

## Alle Patienten

Unsere Population soll einfach alle Patienten enthalten.

### CQl Library

```cql
// CQL Library Header
library "everyone"
// wir nutzen das Datenmodell FHIR in der Version R4
using FHIR version '4.0.0'
// wir binden die CQL Bibliothek FHIRHelpers, die beim Arbeiten mit FHIR 
// praktisch immer gebraucht wird
include FHIRHelpers version '4.0.0'

// unsere CQL Expressions werden im Patient Context definiert,
// haben somit immer einen Patienten im Scope
context Patient

// InInitialPopulation ist unsere Expression, welche die Population bestimmt
// D.h. $evaluate-measure führt diese Expression pro Patient aus und erwartet
// einen Boolean Rückgabewert, welcher besagt, ob ein Patient Teil der Population
// sein soll.
define InInitialPopulation:
  true
```

### Vereinfachte Darstellung Library/Measure Ressourcen

Aus dieser YAML Datei erstellt `blazectl` eine [Measure][1] und eine [Library][2] Ressource. Die Library Ressource enthält den CQL Library Quelltext, wohingegen die Measure Ressource beschreibt, welche Populationen gerechnet werden sollen.

```yml
# Name der CQL Library Datei
library: everyone.cql
# Gruppen der Measure Ressource
group:
- type: Patient
  population:
  - expression: InInitialPopulation
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure everyone.yml | jq -rf count.jq
```

### Ergebnis

```text
16982
```

## Geschlecht

### CQl Library

```cql
library "geschlecht"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

context Patient

define InInitialPopulation:
  Patient.gender = 'female'
```

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure geschlecht.yml | jq -rf count.jq
```

### Ergebnis

```text
8437
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
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure schaedeldachfraktur.yml | jq -rf count.jq
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
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure schaedeldachfraktur-stratifier-birth-year.yml | jq -rf stratifier-birth-year.jq
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
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure schaedelfraktur.yml | jq -rf count.jq
```

### Ergebnis

```text
411
```

## Kalium

### CQl Library

```cql
```

## NT-proBNP Units

````sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure NT-proBNP-Unit.yml | jq -rf stratifier-unit.jq
````

### Ergebnis

```csv
"unit","count"
"Mt/m3",4
"ng/L",4
"pg%",4
"pg/100mL",4
"pg/L",4
"pg/dL",8
"pg/mL",84
"pmol/L",4
"unknown",12
```

## Medication Enoxaparin

### Ausführung

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure medication-enoxaparin.yml | jq -rf count.jq
```

### Ergebnis

```text
21
```

### Gleiches Ergebnis mittels FHIR Search

#### Medication ID

```sh
curl -sH 'Accept: application/fhir+json' -u "polar:$PASSWORD" 'https://mii-agiop-polar.life.uni-leipzig.de/blaze/Medication?code=B01AB05'  | jq -r '.entry[].resource.id'
```

#### Download aller MedicationStatements und zählen aller uniqen Subject Referenzen

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" download MedicationStatement -q 'medication=Medication--132846039' | jq -r '.subject.reference' | sort -u | wc -l
```

## Medication Enoxaparin mit Inpatient Encounters mit Admission diagnosis

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure medication-enoxaparin-near-condition.yml | jq -rf count.jq
```

## Statistics

### Encounter Classes

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure stratifier-encounter-class.yml | jq -rf stratifier-encounter-class.jq
```

### Laboratory Codes

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure stratifier-lab-code.yml | jq -rf stratifier-lab-code.jq
```

### Medication ATC Codes

```sh
blazectl --server "$BASE" --user polar --password "$PASSWORD" evaluate-measure stratifier-medication-statement-medication-code.yml | jq -rf stratifier-medication-atc.jq
```

[1]: <http://hl7.org/fhir/R4B/measure.html>
[2]: <http://hl7.org/fhir/R4B/library.html>
[3]: <http://hl7.org/fhir/R4B/measurereport.html>
