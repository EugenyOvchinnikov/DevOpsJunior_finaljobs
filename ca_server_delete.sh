#!/bin/bash

yc compute instance delete --name ca-server
yc vpc subnet delete --name vpn-server-subnet-a
yc vpc network delete --name vpn-server-network