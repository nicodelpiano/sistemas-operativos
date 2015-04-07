#!/bin/sh
gnome-terminal -e "./Servidor"
cd worker1
gnome-terminal -e "./Worker"
cd ..
cd worker2
gnome-terminal -e "./Worker"
cd ..
cd worker3
gnome-terminal -e "./Worker"
cd ..
cd worker4
gnome-terminal -e "./Worker"
cd ..
cd worker5
gnome-terminal -e "./Worker"
cd ..
gnome-terminal -e "./Cliente"
