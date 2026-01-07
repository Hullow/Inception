# Notes Inception

## Container
- Une machine virtuelle est un système d'exploitation entier avec son propre noyau, drivers, programmes et applications. C'est assez lourd pour isoler le fonctionnement d'une seule application. 
- Un container est un process isolé avec tous les fichiers dont il a besoin pour tourner, qui utilise le kernel de sa machine hôte. Plusieurs containers sur une même machine utiliseront le même kernel.
- Docker utilise des features du kernel Linux pour l'isolation de process. Sur MacOS, Docker tourne dans une VM Linux.

## Concepts Docker
- **Docker** fonctionne selon une logique server-client, avec le serveur un dockerd (daemon) et le client qui fait des requêtes au dockerd par une API Rest, en passant par des sockets Unix ou une interface réseau.
(n.b.: un daemon est un process conçu pour tourner en arrière-plan. c'est un terme qu'on utilise essentiellement dans les contextes Unix)
- **Dockerd**, le *daemon*, fait le gros du travail: il gère les images, les réseaux, containers, et volumes. Il construit, fait tourner, et distribue les containers. Il peut tourner sur le même système que le client Docker ou non.
- les **Dockers registries** stockent des images Docker. Docker Hub est le registre public par défaut utilisé par Docker pour chercher des images. Les commandes `docker pull` et `docker run` vont chercher des images depuis le registre configuré, tandis que `docker push` va pousser des images vers le registre configuré.
- les **objects Docker** comprennent notamment les images, containers, réseaux, volumes, plugins, et d'autres objets. En particulier, focus sur:

### Images
Un template read-only (immutable) avec des instructions pour créer un container Docker. Deux principes importants
	- immutabilité: une fois créée, une image ne peut pas être modifiée. on peut simplement créer une nouvelle image ou ajouter des changements par-dessus
	- couches d'images: les images de containers sont composées de couches, qui sont des ensembles d'ajout, suppression ou modification de fichiers. Formellement, ce sont des changements représentés par une instruction dans le Dockerfile
Exemple: pour un container postgres, l'image contiendra les binaires, la config et d'autres dépendances.  Souvent une image est basée sur une autre image, avec de la customization additionnelle (par ex une image basée sur l'image Ubuntu avec en plus un server web Apache et notre application, ainsi que les détails de configuration pour faire tourner l'application). Pour créer ses propres images, on crée un **Dockerfile** avec une syntaxe simple qui va définir les étapes nécessaires pour créer l'image et la faire tourner. Chaque instruction dans un Dockerfile crée une couche dans l'image. Quand on change le Dockerfile et qu'on re-build l'image, seules les couches qui ont été changées sont re-build. Cela rend les images légères et rapides comparés à d'autres technologies de virtualisation.

### Containers
Sont une instance d'une image que l'on peut faire tourner. On peut créer, lancer, arrêter, déplacer ou supprimer un container avec l'API ou le CLI Docker. On peut connecter le container à un ou plusieurs réseaux, y attacher du stockage, ou même créer une image à partir de son état actuel. Par défaut, un container est relativement bien isolé des autres containers et de sa machine hôte. On peut contrôler le degré d'isolement du réseau, stockage et autres sous-sytèmes d'un container, par rapport aux autres containers ou à la machine hôte. Un container est défini par son image ainsi que toute option de configuration que l'on lui fournit à sa création ou à son lancement. Quand un container est supprimé, tous les changements de son état qui ne sont pas stocké dans un stockage persistant disparaissent.<br>
	n.b.: par défaut, les containers peuvents se connecter aux réseaux externes en utilisant la connection réseau de la machine hôte.<br>
	n.b.2: les containers utilisent des fonctionnalités du Kernel Linux et la technologie des *namespaces* pour isoler des espaces virtuels dans les *containers*.

### Volumes
> A volume is a special directory within a container that bypasses the Union File System. Volumes are designed to persist data independently of the container lifecycle. Docker supports host, anonymous, and named volumes.

### [Running multiple servies in a container](https://docs.docker.com/engine/containers/multi-service_container/)
> A container's main running process is the ENTRYPOINT and/or CMD at the end of the Dockerfile. It's best practice to separate areas of concern by using one service per container. That service may fork into multiple processes (for example, Apache web server starts multiple worker processes). It's ok to have multiple processes, but to get the most benefit out of Docker, avoid one container being responsible for multiple aspects of your overall application. You can connect multiple containers using user-defined networks and shared volumes.
> The container's main process is responsible for managing all processes that it starts. In some cases, the main process isn't well-designed, and doesn't handle "reaping" (stopping) child processes gracefully when the container exits. If your process falls into this category, you can use the --init option when you run the container. The --init flag inserts a tiny init-process into the container as the main process, and handles reaping of all processes when the container exits. Handling such processes this way is superior to using a full-fledged init process such as sysvinit or systemd to handle process lifecycle within your container.

### Docker compose
Un type de client docker qui permet de gérer des applications constituée par un ensemble de containers. Compose simplifie le contrôle de toute la stack de notre application, simplifiant la gestion des services, réseaux et volumes dans un seul fichier de configuration YAML. Avec une seule commande, on peut ensuite créer et lancer tous les services depuis notre fichier de configuration. Compose fonctionne dans tous les environnements: production, staging, développement, testing

### Attributes
`depends_on`
> With the `depends_on` attribute, you can control the order of service startup and shutdown. It is useful if services are closely coupled, and the startup sequence impacts the application's functionality.

### Dockerfile
#### [ENTRYPOINT](https://docs.docker.com/reference/dockerfile/#entrypoint)
> An ENTRYPOINT allows you to configure a container that will run as an executable. ENTRYPOINT has two possible forms:
> - The exec form, which is the preferred form: `ENTRYPOINT ["executable", "param1", "param2"]`
> - The shell form: `ENTRYPOINT command param1 param2`

From kapa.ai Docker assistant:<br>
> The container’s main running process is whatever you define with ENTRYPOINT and/or CMD in the Dockerfile; that process becomes PID 1 inside the container.

## Bibliographie / Ressources utilisées

- [What is a container | Docker Docs](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/)
- [What is Docker? | Docker Docs](https://docs.docker.com/get-started/docker-overview/)
- [What is an image | Docker Docs](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/)
- [Glossary | Docker Docs](https://docs.docker.com/reference/glossary/)
- [Docker Compose | Docker Docs](https://docs.docker.com/compose/)
- [How Compose works | Docker Docs](https://docs.docker.com/compose/intro/compose-application-model/)
- Secrets: https://docs.docker.com/reference/compose-file/secrets/%20
https://docs.docker.com/compose/how-tos/use-secrets/
- [Services | Dockers Docs](https://docs.docker.com/reference/compose-file/services/)
- [Docker (software) - Wikipedia](https://en.wikipedia.org/wiki/Docker_(software))