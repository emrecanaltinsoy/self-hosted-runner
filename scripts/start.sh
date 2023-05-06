#!/bin/bash

docker-compose up --scale runner=${1:-1} -d
