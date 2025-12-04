#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GRAFANA_URL> <GRAFANA_TOKEN> <DASHBOARD_UID>" >&2
    exit 1
fi

GRAFANA_URL="$1"
GRAFANA_TOKEN="$2"
DASHBOARD_UID="$3"

# 1. Fetch the full dashboard object
# 2. Extract only the 'dashboard' field
# 3. Transform for external sharing:
#    - Inject __inputs for datasource and job name
#    - Inject __requires
#    - Replace datasource UIDs with ${DS_PROMETHEUS}
#    - Ensure JOBNAME variable exists and is linked to input
#    - Update 'node' variable to use $JOBNAME
#    - Clean up internal IDs

curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
     "${GRAFANA_URL}/api/dashboards/uid/${DASHBOARD_UID}" | \
jq '
def walk(f): . as $in | if type == "object" then reduce keys[] as $key ({}; . + {($key):  ($in[$key] | walk(f))}) | f elif type == "array" then map( walk(f) ) | f else f end;

.dashboard 
| del(.id, .uid, .version, .iteration) 
| . + {
    "__inputs": [
      {
        "name": "DS_PROMETHEUS",
        "label": "prometheus",
        "description": "",
        "type": "datasource",
        "pluginId": "prometheus",
        "pluginName": "Prometheus"
      },
      {
        "name": "VAR_JOBNAME",
        "type": "constant",
        "label": "job_name",
        "value": "arweave",
        "description": ""
      }
    ],
    "__requires": [
      { "type": "grafana", "id": "grafana", "name": "Grafana", "version": "12.0.2" },
      { "type": "datasource", "id": "prometheus", "name": "Prometheus", "version": "1.0.0" },
      { "type": "panel", "id": "timeseries", "name": "Time series", "version": "" }
    ]
  }
| walk(
    if type == "object" and has("datasource") and (.datasource | type == "object") and (.datasource.type == "prometheus") then 
      .datasource.uid = "${DS_PROMETHEUS}" 
    else . end
  )
| .templating.list |= (
    map(
      if .name == "node" then
         .definition = "label_values({job=\"$JOBNAME\"}, instance)" |
         .query.query = "label_values({job=\"$JOBNAME\"}, instance)" |
         .datasource.uid = "${DS_PROMETHEUS}"
      else . end
    )
    | map(select(.name != "JOBNAME"))
    +
    [
      {
        "name": "JOBNAME",
        "label": "job_name",
        "type": "constant",
        "value": "${VAR_JOBNAME}",
        "query": "${VAR_JOBNAME}",
        "hide": 2,
        "skipUrlSync": true,
        "current": {
          "value": "${VAR_JOBNAME}",
          "text": "${VAR_JOBNAME}",
          "selected": false
        },
        "options": [
          {
            "value": "${VAR_JOBNAME}",
            "text": "${VAR_JOBNAME}",
            "selected": false
          }
        ]
      }
    ]
  )
| .templating.list |= map(
    if .name == "node" then
      .type = "textbox" |
      .query = "YOUR_NODE_ID" |
      .current.text = "YOUR_NODE_ID" |
      .current.value = "YOUR_NODE_ID" |
      .options = [{
        "selected": true,
        "text": "YOUR_NODE_ID",
        "value": "YOUR_NODE_ID"
      }] |
      del(.definition, .datasource, .regex, .sort, .refresh, .includeAll, .multi)
    else . end
  )
'
