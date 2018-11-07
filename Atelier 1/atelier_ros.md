# Atelier ROS - Élikos 2018

Par Philippe Rivest

<!-- TOC -->

- [Atelier ROS - Élikos 2018](#atelier-ros---élikos-2018)
    - [Qu’est-ce que ROS](#quest-ce-que-ros)
    - [Pourquoi ROS](#pourquoi-ros)
    - [Premiers pas](#premiers-pas)
        - [Installation de ROS](#installation-de-ros)
        - [Configuration de l’invite de commande](#configuration-de-linvite-de-commande)
        - [Configuration du _workspace_](#configuration-du-_workspace_)
        - [Configuration de l'éditeur de code](#configuration-de-léditeur-de-code)
            - [Choix de l'éditeur](#choix-de-léditeur)
            - [Configuration de CLion](#configuration-de-clion)
            - [`clion_ros`](#clion_ros)
    - [Exemple Drone + Gazebo + PX4](#exemple-drone--gazebo--px4)
        - [`rosnode`](#rosnode)
        - [`rostopic`](#rostopic)
        - [`rosservice`](#rosservice)
        - [Développement d'une _node_ ROS](#développement-dune-_node_-ros)
            - [Création d'un paquetage ROS](#création-dun-paquetage-ros)
            - [Modification de `package.xml`](#modification-de-packagexml)
            - [Modification de `CMakeLists.txt`](#modification-de-cmakeliststxt)
            - [Programmation de la _node_](#programmation-de-la-_node_)

<!-- /TOC -->

## Qu’est-ce que ROS

Un cadriciel (framework) pour le développement de code dans le domaine de la robotique. ROS offre des libraires, des outils, l’environnement d’exécution et bien plus.

## Pourquoi ROS

> Pourquoi ne pas simplement écrire un programme de A à Z sans utiliser ROS?

ROS nous permet de nous concentrer directement sur notre code et son fonctionnement interne sans nous soucier des autres sphères relative au développement et à l'exécution. Nous allons voir plus tard comment ROS nous simplifie la vie.

## Premiers pas

Pour développer avec ROS, nous avons besoin de quatre choses essentielles:

* une distribution ROS d’installée;
* une invite de commande;
* un _workspace_;
* un éditeur de code

### Installation de ROS

L’installation de ROS se fait rapidement à l’aide du [guide](https://wiki.ros.org/melodic/Installation/Ubuntu) disponible sur leur site web. Ubuntu 18.04 est mon système d’exploitation recommandé pour la version Melodic Morenia de ROS.

### Configuration de l’invite de commande

L'interpréteur par défaut d'Ubuntu est Bash. Pour lui indiquer que ROS est installé, nous allons ajouter la ligne suivante au fichier `~/.bashrc`:

```bash
source /opt/ros/melodic/setup.bash
```

Ceci, permet d'utiliser tous les outils ROS dans n'importe quelle invite de commande sans devoir le configurer à chaque fois.

### Configuration du _workspace_

Un _workspace_ est simplement un dossier contenant du code destiné à être compilé. Personnellement, j'aime l'outil `python-catkin-tools` pour la gestion de _workspaces_.

Pour la création, il suffit de faire les comandes suivantes:

```bash
mkdir -p test_ws/src    # Créer un dossier test_ws contenant un dossier src
cd test_ws              # Entrer dans le dossier test_ws
catkin init             # Initialiser le workspace
```

Le _workspace_ est maintenant prêt pour acceuillir du code.

### Configuration de l'éditeur de code

#### Choix de l'éditeur

Plusieurs solutions sont offertes aujourd'hui pour le développement de code C++ pour Ubuntu:

* Visual Studio Code
* Vim
* CLion
* etc

Chacun a ses préférences, mais pour cet atelier, j'utiliserai CLion, car ce dernier offre un support natif pour CMake et un excellent _autocomplete_.

#### Configuration de CLion

CLion atteint son plein potentiel si nous prenons le temps de le configurer correctement.

Le secret réside dans le fait que CLion fonctionne avec l'outil de compilation _CMake_ aussi utilisé par ROS. Pour permettre à CLion de « comprendre » ROS, nous devons « lier » les systèmes _CMake_ ensemble. Pour faciliter ceci, voici un script permettant la configuration d'une instance CLion pour le _workspace_ courrant.

#### `clion_ros`

```bash
#!/bin/bash
# Basic ROS setup
source /opt/ros/melodic/setup.bash
# Workspace dependant setup
if [ -f devel/setup.bash ]; then
        source devel/setup.bash
else
        echo "Invalid workspace. Won't source current directory."
fi
# Launch clion
clion
```

_N.B: ce script ne fonctionne qu'avec le script de lancement par ligne de commande de CLion. Ce script peut être créé dans le menu de Tools de CLion._

## Exemple Drone + Gazebo + PX4

Pour voir les différents outils que nous fournis ROS, nous allons utiliser la simulation Gazebo d'un drone piloté par PX4.

Tout d'abord, nous devons cloner puis compiler le code de PX4 sur [disponible sur github](https://github.com/PX4/Firmware).
_N.B: Pour l'installation des dépendances, voir `install_pxr_deps.sh`._

```bash
git clone git@github.com:PX4/Firmware.git PX4-Firmware
cd PX4-Firmware
make posix_sitl_default gazebo
```

Fermer la fenêtre Gazebo qui s'ouvre puisqu'il ne s'agit pas de la bonne simulation. Pour obtenir la bonne simulation, entrer les lignes suivantes:

```bash
source Tools/setup_gazebo.bash $(pwd) $(pwd)/build/posix_sitl_default
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)/Tools/sitl_gazebo
roslaunch px4 mavros_posix_sitl.launch
```

Ces commandes démarrent une simulation de PX4 avec MAVROS.

### `rosnode`

La commande `rosnode list` nous permet de voir les _nodes_ ROS en cours d'exécution:

```bash
> rosnode list
/gazebo
/gazebo_gui
/mavros
/rosout
```

`rosnode info {node}` nous montre en détail le foncitonnement de la _node_ spécifiée.

### `rostopic`

La commande `rostopic list` nous permet de voir les _topics_ utilisés par les _nodes_ ROS en cours d'exécution:

`rostopic echo {topic}` nous montre les messages échangés sur le topic.

`rqt_graph` nous montre les _nodes_ et les _topics_ actifs.

### `rosservice`

La commande `rosservice list` nous permet de voir les _services_ utilisés par les _nodes_ ROS en cours d'exécution:

`rosservice info {service}` nous montre en détail le foncitonnement du _service_ spécifié.

### Développement d'une _node_ ROS

#### Création d'un paquetage ROS

Dans le dossier `src` de notre _workspace_ de tout à l'heure, nous allons créer le paquetage qui contiendra notre _node_ et lancer CLion.

```bash
cd src
catkin create pkg demo_mavros
cd ..
catkin build
clion_ros
```

#### Modification de `package.xml`

Ce fichier contient toutes informations relatives à l'exécution et la compilation d'un paquetage ROS. Nous ajouterons les lignes suivantes:

```xml
<depend>roscpp</depend>
<depend>mavros_msgs</depend> 
<depend>geometry_msgs</depend>
```

#### Modification de `CMakeLists.txt`

CMakeLists contient les instructions pour la compilation de notre paquetage. Comme une makefile, mais en mieux! Pour que tout fonctionne, nous modifions le fichier existant pour obtenir:

```cmake
cmake_minimum_required(VERSION 2.8.3)
project(demo_mavros)

## Compile as C++11, supported in ROS Kinetic and newer
add_compile_options(-std=c++11)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(
        catkin REQUIRED
        COMPONENTS
        roscpp
        geometry_msgs
        mavros_msgs
)

###########
## Build ##
###########

## Specify additional locations of header files
## Your package locations should be listed before other locations
include_directories(
${catkin_INCLUDE_DIRS}
)

## Declare a C++ executable
## With catkin_make all packages are built within a single CMake context
## The recommended prefix ensures that target names across packages don't collide
add_executable(${PROJECT_NAME}_node src/demo_mavros_node.cpp)

## Add cmake target dependencies of the executable
## same as for the library above
add_dependencies(${PROJECT_NAME}_node ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS})

## Specify libraries to link a library or executable target against
target_link_libraries(${PROJECT_NAME}_node
    ${catkin_LIBRARIES}
)
```

#### Programmation de la _node_

Voir le code dans `demo_mavros_node.cpp`.