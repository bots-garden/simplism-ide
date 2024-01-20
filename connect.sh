#!/bin/bash
set -o allexport; source .env; set +o allexport
docker exec --workdir workspace -it simplism-ide \
/bin/bash


