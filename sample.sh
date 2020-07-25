#!/bin/sh

set -e

while [[ $# -gt 0 ]]; do
  case ${1} in
    -setup | setup | start)
      docker-compose up -d
      ;;

    -down | down | stop | end)
      docker-compose down
      ;;

    -clean)
      declare -a param_arr=()
      while [ $# -gt 0 ];
      do
          param_arr+=(${2})
          shift
      done
      docker-compose run --rm elasticsearch-migrate clean -O es7/migration/config/config.json -i "${param_arr[*]}" -t all -y
      ;;

    -plan)
      declare -a param_arr=()
      while [ $# -gt 0 ];
      do
          param_arr+=(${2})
          shift
      done
      docker-compose run --rm elasticsearch-migrate plan -O es7/migration/config/config.json -i "${param_arr[*]}"
      ;;

    -migrate)
      declare -a param_arr=()
      while [ $# -gt 0 ];
      do
          param_arr+=(${2})
          shift
      done
      docker-compose run --rm elasticsearch-migrate migrate -O es7/migration/config/config.json -i "${param_arr[*]}"
      ;;
    *)
      exit 0
      ;;
    esac
  shift
done



echo docker compose up
docker-compose up -d